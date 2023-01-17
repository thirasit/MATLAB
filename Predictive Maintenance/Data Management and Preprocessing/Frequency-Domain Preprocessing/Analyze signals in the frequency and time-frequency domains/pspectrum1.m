%%% Analyze signals in the frequency and time-frequency domains

%% Power Spectra of Sinusoids
% Generate 128 samples of a two-channel complex sinusoid.
% - The first channel has unit amplitude and a normalized sinusoid frequency of π/4 rad/sample
% - The second channel has an amplitude of 1/√2 and a normalized frequency of π/2 rad/sample.
% Compute the power spectrum of each channel and plot its absolute value. 
% Zoom in on the frequency range from 0.15π rad/sample to 0.6π rad/sample. 
% pspectrum scales the spectrum so that, if the frequency content of a signal falls exactly within a bin, its amplitude in that bin is the true average power of the signal. 
% For a complex exponential, the average power is the square of the amplitude. 
% Verify by computing the discrete Fourier transform of the signal. 
% For more details, see Measure Power of Deterministic Periodic Signals.

N = 128;
x = [1 1/sqrt(2)].*exp(1j*pi./[4;2]*(0:N-1)).';

[p,f] = pspectrum(x);

figure
plot(f/pi,abs(p))
hold on
stem(0:2/N:2-1/N,abs(fft(x)/N).^2)
hold off
axis([0.15 0.6 0 1.1])
legend("Channel 1, pspectrum","Channel 2, pspectrum", ...
    "Channel 1, fft","Channel 2, fft")
grid

% Generate a sinusoidal signal sampled at 1 kHz for 296 milliseconds and embedded in white Gaussian noise. 
% Specify a sinusoid frequency of 200 Hz and a noise variance of 0.1². 
% Store the signal and its time information in a MATLAB® timetable.
Fs = 1000;
t = (0:1/Fs:0.296)';
x = cos(2*pi*t*200)+0.1*randn(size(t));
xTable = timetable(seconds(t),x);

% Compute the power spectrum of the signal. Express the spectrum in decibels and plot it.
[pxx,f] = pspectrum(xTable);

figure
plot(f,pow2db(pxx))
grid on
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
title('Default Frequency Resolution')

% Recompute the power spectrum of the sinusoid, but now use a coarser frequency resolution of 25 Hz. 
% Plot the spectrum using the pspectrum function with no output arguments.
figure
pspectrum(xTable,'FrequencyResolution',25)

%% Two-Sided Spectra
% Generate a signal sampled at 3 kHz for 1 second. 
% The signal is a convex quadratic chirp whose frequency increases from 300 Hz to 1300 Hz during the measurement. 
% The chirp is embedded in white Gaussian noise.
fs = 3000;
t = 0:1/fs:1-1/fs;

x1 = chirp(t,300,t(end),1300,'quadratic',0,'convex') + ...
    randn(size(t))/100;

% Compute and plot the two-sided power spectrum of the signal using a rectangular window. For real signals, pspectrum plots a one-sided spectrum by default. To plot a two-sided spectrum, set TwoSided to true.
figure
pspectrum(x1,fs,'Leakage',1,'TwoSided',true)

% Generate a complex-valued signal with the same duration and sample rate. 
% The signal is a chirp with sinusoidally varying frequency content and embedded in white noise. 
% Compute the spectrogram of the signal and display it as a waterfall plot. 
% For complex-valued signals, the spectrogram is two-sided by default.
figure
x2 = exp(2j*pi*100*cos(2*pi*2*t)) + randn(size(t))/100;

[p,f,t] = pspectrum(x2,fs,'spectrogram');

waterfall(f,t,p')
xlabel('Frequency (Hz)')
ylabel('Time (seconds)')
wtf = gca;
wtf.XDir = 'reverse';
view([30 45])

%% Window Leakage and Tone Resolution
% Generate a two-channel signal sampled at 100 Hz for 2 seconds.
% 1. The first channel consists of a 20 Hz tone and a 21 Hz tone. Both tones have unit amplitude.
% 2. The second channel also has two tones. One tone has unit amplitude and a frequency of 20 Hz. The other tone has an amplitude of 1/100 and a frequency of 30 Hz.
fs = 100;
t = (0:1/fs:2-1/fs)';

x = sin(2*pi*[20 20].*t) + [1 1/100].*sin(2*pi*[21 30].*t);

% Embed the signal in white noise. Specify a signal-to-noise ratio of 40 dB. Plot the signals.
x = x + randn(size(x)).*std(x)/db2mag(40);
figure
plot(t,x)

% Compute the spectra of the two channels and display them.
figure
pspectrum(x,t)

% The default value for the spectral leakage, 0.5, corresponds to a resolution bandwidth of about 1.29 Hz. 
% The two tones in the first channel are not resolved. 
% The 30 Hz tone in the second channel is visible, despite being much weaker than the other one.
% Increase the leakage to 0.85, equivalent to a resolution of about 0.74 Hz. 
% The weak tone in the second channel is clearly visible.
figure
pspectrum(x,t,'Leakage',0.85)

% Increase the leakage to the maximum value. 
% The resolution bandwidth is approximately 0.5 Hz. 
% The two tones in the first channel are resolved. 
% The weak tone in the second channel is masked by the large window sidelobes.
figure
pspectrum(x,t,'Leakage',1)

%% Compare spectrogram and pspectrum Functions
% Generate a signal that consists of a voltage-controlled oscillator and three Gaussian atoms. The signal is sampled at f_s=2 kHz for 1 second.
fs = 2000;
tx = (0:1/fs:2);
gaussFun = @(A,x,mu,f) exp(-(x-mu).^2/(2*0.03^2)).*sin(2*pi*f.*x)*A';
s = gaussFun([1 1 1],tx',[0.1 0.65 1],[2 6 2]*100)*1.5;
x = vco(chirp(tx+.1,0,tx(end),3).*exp(-2*(tx-1).^2),[0.1 0.4]*fs,fs);
x = s+x';

% Short-Time Fourier Transforms
% Use the pspectrum function to compute the STFT.
% - Divide the N_x-sample signal into segments of length M=80 samples, corresponding to a time resolution of 80/2000=40 milliseconds.
% - Specify L=16 samples or 20% of overlap between adjoining segments.
% - Window each segment with a Kaiser window and specify a leakage ℓ=0.7.
M = 80;
L = 16;
lk = 0.7;

[S,F,T] = pspectrum(x,fs,"spectrogram", ...
    TimeResolution=M/fs,OverlapPercent=L/M*100, ...
    Leakage=lk);

% Compare to the result obtained with the spectrogram function.
% - Specify the window length and overlap directly in samples.
% - pspectrum always uses a Kaiser window as g(n). The leakage ℓ and the shape factor β of the window are related by β=40×(1−ℓ).
% - pspectrum always uses N_DFT=1024 points when computing the discrete Fourier transform. You can specify this number if you want to compute the transform over a two-sided or centered frequency range. However, for one-sided transforms, which are the default for real signals, spectrogram uses 1024/2+1=513 points. Alternatively, you can specify the vector of frequencies at which you want to compute the transform, as in this example.
% - If a signal cannot be divided exactly into k=⌊(N_x−L)/(M−L)⌋ segments, spectrogram truncates the signal whereas pspectrum pads the signal with zeros to create an extra segment. To make the outputs equivalent, remove the final segment and the final element of the time vector.
% - spectrogram returns the STFT, whose magnitude squared is the spectrogram. pspectrum returns the segment-by-segment power spectrum, which is already squared but is divided by a factor of ∑_n g(n) before squaring.
% - For one-sided transforms, pspectrum adds an extra factor of 2 to the spectrogram.
g = kaiser(M,40*(1-lk));

k = (length(x)-L)/(M-L);
if k~=floor(k)
    S = S(:,1:floor(k));
    T = T(1:floor(k));
end

[s,f,t] = spectrogram(x/sum(g)*sqrt(2),g,L,F,fs);

% Use the waterplot function to display the spectrograms computed by the two functions.
figure
subplot(2,1,1)
waterplot(sqrt(S),F,T)
title("pspectrum")

subplot(2,1,2)
waterplot(s,f,t)
title("spectrogram")

maxd = max(max(abs(abs(s).^2-S)))

%%% Power Spectra and Convenience Plots
% The spectrogram function has a fourth argument that corresponds to the segment-by-segment power spectrum or power spectral density. 
% Similar to the output of pspectrum, the ps argument is already squared and includes the normalization factor ∑_n g(n). 
% For one-sided spectrograms of real signals, you still have to include the extra factor of 2. 
% Set the scaling argument of the function to "power".
[~,~,~,ps] = spectrogram(x*sqrt(2),g,L,F,fs,"power");

max(abs(S(:)-ps(:)))

% When called with no output arguments, both pspectrum and spectrogram plot the spectrogram of the signal in decibels. 
% Include the factor of 2 for one-sided spectrograms. 
% Set the colormaps to be the same for both plots. Set the x-limits to the same values to make visible the extra segment at the end of the pspectrum plot. 
% In the spectrogram plot, display the frequency on the y-axis.
figure
subplot(2,1,1)
pspectrum(x,fs,"spectrogram", ...
    TimeResolution=M/fs,OverlapPercent=L/M*100, ...
    Leakage=lk)
title("pspectrum")
cc = clim;
xl = xlim;

subplot(2,1,2)
spectrogram(x*sqrt(2),g,L,F,fs,"power","yaxis")
title("spectrogram")
clim(cc)
xlim(xl)

%% Persistence Spectrum of Transient Signal
% Visualize an interference narrowband signal embedded within a broadband signal.
% Generate a chirp sampled at 1 kHz for 500 seconds. 
% The frequency of the chirp increases from 180 Hz to 220 Hz during the measurement.
fs = 1000;
t = (0:1/fs:500)';

x = chirp(t,180,t(end),220) + 0.15*randn(size(t));

% The signal also contains a 210 Hz sinusoid. 
% The sinusoid has an amplitude of 0.05 and is present only for 1/6 of the total signal duration.
idx = floor(length(x)/6);
x(1:idx) = x(1:idx) + 0.05*cos(2*pi*t(1:idx)*210);

% Compute the spectrogram of the signal. 
% Restrict the frequency range from 100 Hz to 290 Hz. 
% Specify a time resolution of 1 second. 
% Both signal components are visible.
figure
pspectrum(x,fs,'spectrogram', ...
    'FrequencyLimits',[100 290],'TimeResolution',1)

% Compute the power spectrum of the signal. The weak sinusoid is obscured by the chirp.
figure
pspectrum(x,fs,'FrequencyLimits',[100 290])

% Compute the persistence spectrum of the signal. Now both signal components are clearly visible.
figure
pspectrum(x,fs,'persistence', ...
    'FrequencyLimits',[100 290],'TimeResolution',1)

%% Spectrogram and Reassigned Spectrogram of Chirp
% Generate a quadratic chirp sampled at 1 kHz for 2 seconds. 
% The chirp has an initial frequency of 100 Hz that increases to 200 Hz at t = 1 second. 
% Compute the spectrogram using the default settings of the pspectrum function. 
% Use the waterfall function to plot the spectrogram.
fs = 1e3;
t = 0:1/fs:2;
y = chirp(t,100,1,200,"quadratic");
figure
[sp,fp,tp] = pspectrum(y,fs,"spectrogram");

waterfall(fp,tp,sp')
set(gca,XDir="reverse",View=[60 60])
ylabel("Time (s)")
xlabel("Frequency (Hz)")

% Compute and display the reassigned spectrogram.
figure
[sr,fr,tr] = pspectrum(y,fs,"spectrogram",Reassign=true);

waterfall(fr,tr,sr')
set(gca,XDir="reverse",View=[60 60])
ylabel("Time (s)")
xlabel("Frequency (Hz)")

% Recompute the spectrogram using a time resolution of 0.2 second. Visualize the result using the pspectrum function with no output arguments.
figure
pspectrum(y,fs,"spectrogram",TimeResolution=0.2)

% Compute the reassigned spectrogram using the same time resolution.
figure
pspectrum(y,fs,"spectrogram",TimeResolution=0.2,Reassign=true)

%% Spectrogram of Dial Tone Signal
% Create a signal, sampled at 4 kHz, that resembles pressing all the keys of a digital telephone. 
% Save the signal as a MATLAB® timetable.
fs = 4e3;
t = 0:1/fs:0.5-1/fs;

ver = [697 770 852 941];
hor = [1209 1336 1477];

tones = [];

for k = 1:length(ver)
    for l = 1:length(hor)
        tone = sum(sin(2*pi*[ver(k);hor(l)].*t))';
        tones = [tones;tone;zeros(size(tone))];
    end
end

% To hear, type soundsc(tones,fs)

S = timetable(seconds(0:length(tones)-1)'/fs,tones);

% Compute the spectrogram of the signal. 
% Specify a time resolution of 0.5 second and zero overlap between adjoining segments. 
% Specify the leakage as 0.85, which is approximately equivalent to windowing the data with a Hann window.
figure
pspectrum(S,'spectrogram', ...
    'TimeResolution',0.5,'OverlapPercent',0,'Leakage',0.85)

% The spectrogram shows that each key is pressed for half a second, with half-second silent pauses between keys. 
% The first tone has a frequency content concentrated around 697 Hz and 1209 Hz, corresponding to the digit '1' in the DTMF standard.

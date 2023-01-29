%%% Spectrogram using short-time Fourier transform

%% Default Values of Spectrogram
% Generate N_x=1024 samples of a signal that consists of a sum of sinusoids. 
% The normalized frequencies of the sinusoids are 2π/5 rad/sample and 4π/5 rad/sample. 
% The higher frequency sinusoid has 10 times the amplitude of the other sinusoid.
N = 1024;
n = 0:N-1;

w0 = 2*pi/5;
x = sin(w0*n)+10*sin(2*w0*n);

% Compute the short-time Fourier transform using the function defaults. Plot the spectrogram.
s = spectrogram(x);

figure
spectrogram(x,'yaxis')

% Repeat the computation.
% - Divide the signal into sections of length nsc=⌊N_x/4.5⌋.
% - Window the sections using a Hamming window.
% - Specify 50% overlap between contiguous sections.
% - To compute the FFT, use max(256,2^p) points, where p=⌈log_2nsc⌉.
% Verify that the two approaches give identical results.
Nx = length(x);
nsc = floor(Nx/4.5);
nov = floor(nsc/2);
nff = max(256,2^nextpow2(nsc));

t = spectrogram(x,hamming(nsc),nov,nff);

maxerr = max(abs(abs(t(:))-abs(s(:))))

% Divide the signal into 8 sections of equal length, with 50% overlap between sections. 
% Specify the same FFT length as in the preceding step. 
% Compute the short-time Fourier transform and verify that it gives the same result as the previous two procedures.
ns = 8;
ov = 0.5;
lsc = floor(Nx/(ns-(ns-1)*ov));

t = spectrogram(x,lsc,floor(ov*lsc),nff);

maxerr = max(abs(abs(t(:))-abs(s(:))))

%% Compare spectrogram Function and STFT Definition
% Generate a signal that consists of a complex-valued convex quadratic chirp sampled at 600 Hz for 2 seconds. 
% The chirp has an initial frequency of 250 Hz and a final frequency of 50 Hz.
fs = 6e2;
ts = 0:1/fs:2;
x = chirp(ts,250,ts(end),50,"quadratic",0,"convex","complex");

% spectrogram Function
% Use the spectrogram function to compute the STFT of the signal.
% - Divide the signal into segments, each M=49 samples long.
% - Specify L=11 samples of overlap between adjoining segments.
% - Discard the final, shorter segment.
% - Window each segment with a Bartlett window.
% Evaluate the discrete Fourier transform of each segment at N_DFT=1024 points. 
% By default, spectrogram computes two-sided transforms for complex-valued signals.
M = 49;
L = 11;
g = bartlett(M);
Ndft = 1024;

[s,f,t] = spectrogram(x,g,L,Ndft,fs);

% Use the waterplot function to compute and display the spectrogram, defined as the magnitude squared of the STFT.
figure
waterplot(s,f,t)

figure
imshow("Opera Snapshot_2023-01-28_070904_www.mathworks.com.png")

[segs,~] = buffer(1:length(x),M,L,"nodelay");

X = fft(x(segs).*g,Ndft);

% Compute the time and frequency ranges for the STFT.
% - To find the time values, divide the time vector into overlapping segments. The time values are the midpoints of the segments, with each segment treated as an interval open at the lower end.
% - To find the frequency values, specify a Nyquist interval closed at zero frequency and open at the lower end.
tbuf = ts(segs);
tint = mean(tbuf(2:end,:));

fint = 0:fs/Ndft:fs-fs/Ndft;

% Compare the output of spectrogram to the definition. Display the spectrogram.
maxdiff = max(max(abs(s-X)))

figure
waterplot(X,fint,tint)

%% Compare spectrogram and stft Functions
% Generate a signal consisting of a chirp sampled at 1.4 kHz for 2 seconds. 
% The frequency of the chirp decreases linearly from 600 Hz to 100 Hz during the measurement time.
fs = 1400;
x = chirp(0:1/fs:2,600,2,100);

% stft Defaults
% Compute the STFT of the signal using the spectrogram and stft functions. Use the default values of the stft function:
% - Divide the signal into 128-sample segments and window each segment with a periodic Hann window.
% - Specify 96 samples of overlap between adjoining segments. This length is equivalent to 75% of the window length.
% - Specify 128 DFT points and center the STFT at zero frequency, with the frequency expressed in hertz.
% Verify that the two results are equal.
M = 128;
g = hann(M,"periodic");
L = 0.75*M;
Ndft = 128;

[sp,fp,tp] = spectrogram(x,g,L,Ndft,fs,"centered");

[s,f,t] = stft(x,fs);

dff = max(max(abs(sp-s)))

% Use the mesh function to plot the two outputs.
figure
subplot(2,1,1)
mesh(tp,fp,abs(sp).^2)
title("spectrogram")
view(2), axis tight
subplot(2,1,2)
mesh(t,f,abs(s).^2)
title("stft")
view(2), axis tight

figure
imshow("Opera Snapshot_2023-01-28_071424_www.mathworks.com.png")

M = floor(length(x)/4.5);
g = hamming(M);
L = floor(M/2);
Ndft = max(256,2^nextpow2(M));

[sx,fx,tx] = spectrogram(x);

[st,ft,tt] = stft(x,Window=g,OverlapLength=L,FFTLength=Ndft,FrequencyRange="onesided");

dff = max(max(sx-st))

% Use the waterplot function to plot the two outputs. Divide the frequency axis by π in both cases. For the stft output, divide the sample numbers by the effective sample rate, 2π.
figure
subplot(2,1,1)
waterplot(sx,fx/pi,tx)
title("spectrogram")
subplot(2,1,2)
waterplot(st,ft/pi,tt/(2*pi))
title("stft")

%% Spectrogram and Instantaneous Frequency
% Use the spectrogram function to measure and track the instantaneous frequency of a signal.
% Generate a quadratic chirp sampled at 1 kHz for two seconds. 
% Specify the chirp so that its frequency is initially 100 Hz and increases to 200 Hz after one second.
fs = 1000;
t = 0:1/fs:2-1/fs;
y = chirp(t,100,1,200,'quadratic');

% Estimate the spectrum of the chirp using the short-time Fourier transform implemented in the spectrogram function. 
% Divide the signal into sections of length 100, windowed with a Hamming window. 
% Specify 80 samples of overlap between adjoining sections and evaluate the spectrum at ⌊100/2+1⌋=51 frequencies.
figure
spectrogram(y,100,80,100,fs,'yaxis')

% Track the chirp frequency by finding the time-frequency ridge with highest energy across the ⌊(2000−80)/(100−80)⌋=96 time points. 
% Overlay the instantaneous frequency on the spectrogram plot.
[~,f,t,p] = spectrogram(y,100,80,100,fs);

[fridge,~,lr] = tfridge(p,f);

hold on
plot3(t,fridge,abs(p(lr)),'LineWidth',4)
hold off

%% Spectrogram of Complex Signal
% Generate 512 samples of a chirp with sinusoidally varying frequency content.
N = 512;
n = 0:N-1;

x = exp(1j*pi*sin(8*n/N)*32);

% Compute the centered two-sided short-time Fourier transform of the chirp. Divide the signal into 32-sample segments with 16-sample overlap. Specify 64 DFT points. Plot the spectrogram.
[scalar,fs,ts] = spectrogram(x,32,16,64,'centered');
figure
spectrogram(x,32,16,64,'centered','yaxis')

% Obtain the same result by computing the spectrogram on 64 equispaced frequencies over the interval (−π,π]. The 'centered' option is not necessary.
fintv = -pi+pi/32:pi/32:pi;

[vector,fv,tv] = spectrogram(x,32,16,fintv);

figure
spectrogram(x,32,16,fintv,'yaxis')

%% Compare spectrogram and pspectrum Functions
% Generate a signal that consists of a voltage-controlled oscillator and three Gaussian atoms. 
% The signal is sampled at f_s=2 kHz for 1 second.
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

figure
imshow("Opera Snapshot_2023-01-28_072234_www.mathworks.com.png")

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

figure
imshow("Opera Snapshot_2023-01-28_072414_www.mathworks.com.png")

[~,~,~,ps] = spectrogram(x*sqrt(2),g,L,F,fs,"power");

max(abs(S(:)-ps(:)))

% When called with no output arguments, both pspectrum and spectrogram plot the spectrogram of the signal in decibels. 
% Include the factor of 2 for one-sided spectrograms. 
% Set the colormaps to be the same for both plots. 
% Set the x-limits to the same values to make visible the extra segment at the end of the pspectrum plot. 
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

%% Reassigned Spectrogram of Quadratic Chirp
% Generate a chirp signal sampled for 2 seconds at 1 kHz. 
% Specify the chirp so that its frequency is initially 100 Hz and increases to 200 Hz after 1 second.
Fs = 1000;
t = 0:1/Fs:2;
y = chirp(t,100,1,200,'quadratic');

% Estimate the reassigned spectrogram of the signal.
% - Divide the signal into sections of length 128, windowed with a Kaiser window with shape parameter β=18.
% - Specify 120 samples of overlap between adjoining sections.
% - Evaluate the spectrum at ⌊128/2⌋=65 frequencies and ⌊(length(x)−120)/(128−120)⌋=235 time bins.
figure
spectrogram(y,kaiser(128,18),120,128,Fs,'reassigned','yaxis')

%% Spectrogram with Threshold
% Generate a chirp signal sampled for 2 seconds at 1 kHz. 
% Specify the chirp so that its frequency is initially 100 Hz and increases to 200 Hz after 1 second.
Fs = 1000;
t = 0:1/Fs:2;
y = chirp(t,100,1,200,'quadratic');

figure
imshow("Opera Snapshot_2023-01-28_073053_www.mathworks.com.png")

[~,~,~,pxx,fc,tc] = spectrogram(y,kaiser(128,18),120,128,Fs, ...
    'MinThreshold',-30);

% Plot the nonzero elements as functions of the center-of-gravity frequencies and times.
figure
plot(tc(pxx>0),fc(pxx>0),'.')

%% Compute Centered and One-Sided Spectrograms
% Generate a signal that consists of a real-valued chirp sampled at 2 kHz for 2 seconds.
fs = 2000;
tx = 0:1/fs:2;
x = vco(-chirp(tx,0,tx(end),2).*exp(-3*(tx-1).^2),[0.1 0.4]*fs,fs).*hann(length(tx))';

figure
imshow("Opera Snapshot_2023-01-28_073228_www.mathworks.com.png")

M = 73;
L = 24;
g = flattopwin(M);
Ndft = 895;
neven = ~mod(Ndft,2);

[stwo,f,t] = spectrogram(x,g,L,Ndft,fs,"twosided");

% Use the spectrogram function with no output arguments to plot the two-sided spectrogram.
figure
spectrogram(x,g,L,Ndft,fs,"twosided","power","yaxis");

% Compute the two-sided spectrogram using the definition. 
% Divide the signal into M-sample segments with L samples of overlap between adjoining segments. 
% Window each segment and compute its discrete Fourier transform at N_DFT points.
[segs,~] = buffer(1:length(x),M,L,"nodelay");

Xtwo = fft(x(segs).*g,Ndft);

% Compute the time and frequency ranges.
% - To find the time values, divide the time vector into overlapping segments. The time values are the midpoints of the segments, with each segment treated as an interval open at the lower end.
% - To find the frequency values, specify a Nyquist interval closed at zero frequency and open at the upper end.
tbuf = tx(segs);
ttwo = mean(tbuf(2:end,:));

ftwo = 0:fs/Ndft:fs*(1-1/Ndft);

% Compare the outputs of spectrogram to the definitions. 
% Use the waterplot function to display the spectrograms.
diffs = [max(max(abs(stwo-Xtwo))) max(abs(f-ftwo')) max(abs(t-ttwo))]

figure
subplot(2,1,1)
waterplot(Xtwo,ftwo,ttwo)
title("Two-Sided, Definition")
subplot(2,1,2)
waterplot(stwo,f,t)
title("Two-Sided, spectrogram Function")

figure
imshow("Opera Snapshot_2023-01-28_073541_www.mathworks.com.png")

tcen = ttwo;

if ~neven
    Xcen = fftshift(Xtwo,1);
    fcen = -fs/2*(1-1/Ndft):fs/Ndft:fs/2;
else
    Xcen = fftshift(circshift(Xtwo,-1),1);
    fcen = (-fs/2*(1-1/Ndft):fs/Ndft:fs/2)+fs/Ndft/2;
end

[scen,f,t] = spectrogram(x,g,L,Ndft,fs,"centered");

diffs = [max(max(abs(scen-Xcen))) max(abs(f-fcen')) max(abs(t-tcen))]

clf
figure
subplot(2,1,1)
waterplot(Xcen,fcen,tcen)
title("Centered, Definition")
subplot(2,1,2)
waterplot(scen,f,t)
title("Centered, spectrogram Function")

figure
imshow("Opera Snapshot_2023-01-28_073655_www.mathworks.com.png")

tone = ttwo;

if ~neven
    Xone = Xtwo(1:(Ndft+1)/2,:);
else
    Xone = Xtwo(1:Ndft/2+1,:);
end

fone = 0:fs/Ndft:fs/2;

[sone,f,t] = spectrogram(x,g,L,Ndft,fs);

diffs = [max(max(abs(sone-Xone))) max(abs(f-fone')) max(abs(t-tone))]

clf
figure
subplot(2,1,1)
waterplot(Xone,fone,tone)
title("One-Sided, Definition")
subplot(2,1,2)
waterplot(sone,f,t)
title("One-Sided, spectrogram Function")

%% Compute Segment PSDs and Power Spectra
% The spectrogram function has a matrix containing either the power spectral density (PSD) or the power spectrum of each segment as the fourth output argument. 
% The power spectrum is equal to the PSD multiplied by the equivalent noise bandwidth (ENBW) of the window.

% Generate a signal that consists of a logarithmic chirp sampled at 1 kHz for 1 second. 
% The chirp has an initial frequency of 400 Hz that decreases to 10 Hz by the end of the measurement.
fs = 1000;
tt = 0:1/fs:1-1/fs;
y = chirp(tt,400,tt(end),10,"logarithmic");

% Segment PSDs and Power Spectra with Sample Rate
% Divide the signal into 102-sample segments and window each segment with a Hann window. Specify 12 samples of overlap between adjoining segments and 1024 DFT points.
M = 102;
g = hann(M);
L = 12;
Ndft = 1024;

% Compute the spectrogram of the signal with the default PSD spectrum type. Output the STFT and the array of segment power spectral densities.
[s,f,t,p] = spectrogram(y,g,L,Ndft,fs);

% Repeat the computation with the spectrum type specified as "power". Output the STFT and the array of segment power spectra.
[r,~,~,q] = spectrogram(y,g,L,Ndft,fs,"power");

% Verify that the spectrogram is the same in both cases. Plot the spectrogram using a logarithmic scale for the frequency.
max(max(abs(s).^2-abs(r).^2))

figure
waterfall(f,t,abs(s)'.^2)
set(gca,XScale="log",...
    XDir="reverse",View=[30 50])

% Verify that the power spectra are equal to the power spectral densities multiplied by the ENBW of the window.
max(max(abs(q-p*enbw(g,fs))))

% Verify that the matrix of segment power spectra is proportional to the spectrogram. The proportionality factor is the square of the sum of the window elements.
max(max(abs(s).^2-q*sum(g)^2))

% Segment PSDs and Power Spectra with Normalized Frequencies
% Repeat the computation, but now work in normalized frequencies. The results are the same when you specify the sample rate as 2π.
[~,~,~,pn] = spectrogram(y,g,L,Ndft);
[~,~,~,qn] = spectrogram(y,g,L,Ndft,"power");

max(max(abs(qn-pn*enbw(g,2*pi))))

%% Track Chirps in Audio Signal
% Load an audio signal that contains two decreasing chirps and a wideband splatter sound. 
% Compute the short-time Fourier transform. 
% Divide the waveform into 400-sample segments with 300-sample overlap. 
% Plot the spectrogram.
load splat

% To hear, type soundsc(y,Fs)

sg = 400;
ov = 300;

figure
spectrogram(y,sg,ov,[],Fs,"yaxis")
colormap bone

% Use the spectrogram function to output the power spectral density (PSD) of the signal.
[s,f,t,p] = spectrogram(y,sg,ov,[],Fs);

% Track the two chirps using the medfreq function. To find the stronger, low-frequency chirp, restrict the search to frequencies above 100 Hz and to times before the start of the wideband sound.
f1 = f > 100;
t1 = t < 0.75;

m1 = medfreq(p(f1,t1),f(f1));

% To find the faint high-frequency chirp, restrict the search to frequencies above 2500 Hz and to times between 0.3 seconds and 0.65 seconds.
f2 = f > 2500;
t2 = t > 0.3 & t < 0.65;

m2 = medfreq(p(f2,t2),f(f2));

% Overlay the result on the spectrogram. Divide the frequency values by 1000 to express them in kHz.
hold on
plot(t(t1),m1/1000,LineWidth=4)
plot(t(t2),m2/1000,LineWidth=4)
hold off

%% 3D Spectrogram Visualization
% Generate two seconds of a signal sampled at 10 kHz. 
% Specify the instantaneous frequency of the signal as a triangular function of time.
fs = 10e3;
t = 0:1/fs:2;
x1 = vco(sawtooth(2*pi*t,0.5),[0.1 0.4]*fs,fs);

% Compute and plot the spectrogram of the signal. 
% Use a Kaiser window of length 256 and shape parameter β=5. 
% Specify 220 samples of section-to-section overlap and 512 DFT points. 
% Plot the frequency on the y-axis. 
% Use the default colormap and view.
figure
spectrogram(x1,kaiser(256,5),220,512,fs,'yaxis')

% Change the view to display the spectrogram as a waterfall plot. Set the colormap to bone.
figure
view(-45,65)
colormap bone

%%% Spectral entropy of signal

%% Plot Spectral Entropy of Signal
% Plot the spectral entropy of a signal expressed as a timetable and as a time series.
% Generate a random series with normal distribution (white noise).
xn = randn(1000,1);

% Create time vector t and convert to duration vector tdur. Combine tdur and xn in a timetable.
fs = 10;
ts = 1/fs;
t = 0.1:ts:100;
tdur = seconds(t);
xt = timetable(tdur',xn);

% Plot the spectral entropy of the timetable xt.
figure
pentropy(xt)
title('Spectral Entropy of White Noise Signal Timetable')

% Plot the spectral entropy of the signal, using time-point vector t and the form which returns se and associated time te. Match the x-axis units and grid to the pentropy-generated plots for comparison.
figure
[se,te] = pentropy(xn,t');
te_min = te/60;
plot(te_min,se)
title('Spectral Entropy of White Noise Signal Vector')
xlabel('Time (mins)')
ylabel('Spectral Entropy')
grid on

% Both yield the same result.
% The second input argument for pentropy can represent either frequency or time. The software interprets according to the data type of the argument. Plot the spectral entropy of the signal, using sample rate scalar fs instead of time vector t.
figure
pentropy(xn,fs)
title('Spectral Entropy of White Noise Signal Vector using Sample Rate')

% This plot matches the previous plots.

%% Plot Spectral Entropy of Speech Signal
% Plot the spectral entropy of a speech signal and compare it to the original signal. 
% Visualize the spectral entropy on a color map by first creating a power spectrogram, and then taking the spectral entropy of frequency bins within the bandwidth of speech.
% Load the data x, which contains a two-channel recording of the word "Hello" embedded by low-level white noise. x consists of two columns representing the two channels. Use only the first channel.
% Define the sample rate and the time vector. 
% Augment the first channel of x with white noise to achieve a signal-to-noise ratio of about 5 to 1.
load Hello x
fs = 44100;
t = 1/fs*(0:length(x)-1);
x1 = x(:,1) + 0.01*randn(length(x),1);

% Find the spectral entropy. Visualize the data for the original signal and for the spectral entropy.
figure
[se,te] = pentropy(x1,fs);

subplot(2,1,1)
plot(t,x1)
ylabel("Speech Signal")
xlabel("Time")

subplot(2,1,2)
plot(te,se)
ylabel("Spectral Entropy")
xlabel("Time")

% The spectral entropy drops when "Hello" is spoken. This is because the signal spectrum has changed from almost a constant (white noise) to the distribution of a human voice. 
% The human-voice distribution contains more information and has lower spectral entropy.

% Compute the power spectrogram p of the original signal, returning frequency vector fp and time vector tp as well. 
% For this case, specifying a frequency resolution of 20 Hz provides acceptable clarity in the result.
[p,fp,tp] = pspectrum(x1,fs,"spectrogram",FrequencyResolution=20);

% The frequency vector of the power spectrogram goes to 22,050 Hz, but the range of interest with respect to speech is limited to the telephony bandwidth of 300–3400 Hz. 
% Divide the data into five frequency bins by defining start and end points, and compute the spectral entropy for each bin.
flow = [300 628 1064 1634 2394];
fup = [627 1060 1633 2393 3400];
 
se2 = zeros(length(flow),size(p,2));
for i = 1:length(flow)
    se2(i,:) = pentropy(p,fp,tp,FrequencyLimits=[flow(i) fup(i)]);
end

% Visualize the data in a color map that shows ascending frequency bins, and compare with the original signal.
figure
subplot(2,1,1)
plot(t,x1)
xlabel("Time (seconds)")
ylabel("Speech Signal")

subplot(2,1,2)
imagesc(tp,[],flip(se2))                % Flip se2 so its plot corresponds to the 
                                        % ascending frequency bins.
h = colorbar(gca,"NorthOutside");
ylabel(h,"Spectral Entropy")
yticks(1:5)
set(gca,YTickLabel=num2str((5:-1:1).')) % Label the ticks for the ascending bins.
xlabel("Time (seconds)")
ylabel("Frequency Bin")

%% Use Spectral Entropy to Detect Sine Wave in White Noise
% Create a signal that combines white noise with a segment that consists of a sine wave. 
% Use spectral entropy to detect the existence and position of the sine wave.

% Generate and plot the signal, which contains three segments. 
% The middle segment contains the sine wave along with white noise. 
% The other two segments are pure white noise.
fs = 100;
t = 0:1/fs:10;
sin_wave = 2*sin(2*pi*20*t')+randn(length(t),1);
x = [randn(1000,1);sin_wave;randn(1000,1)];
t3 = 0:1/fs:30;

figure
plot(t3,x)
title("Sine Wave in White Noise")

% Plot the spectral entropy.
figure
pentropy(x,fs)
title("Spectral Entropy of Sine Wave in White Noise")

% The plot clearly differentiates the segment with the sine wave from the white-noise segments. 
% This is because the sine wave contains information. 
% Pure white noise has the highest spectral entropy.
% The default for pentropy is to return or plot the instantaneous spectral entropy for each time point, as the previous plot displays. 
% You can also distill the spectral entropy information into a single number that represents the entire signal by setting Instantaneous to false. 
% Use the form that returns the spectral entropy value if you want to directly use the result in other calculations. 
% Otherwise, pentropy returns the spectral entropy in ans.
se = pentropy(x,fs,Instantaneous=false)

% A single number characterizes the spectral entropy, and therefore the information content, of the signal. 
% You can use this number to efficiently compare this signal with other signals.

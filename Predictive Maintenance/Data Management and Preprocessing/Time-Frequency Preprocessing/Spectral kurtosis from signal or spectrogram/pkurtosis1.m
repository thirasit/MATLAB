%%% Spectral kurtosis from signal or spectrogram

%% Plot Spectral Kurtosis of Nonstationary Signal Using Different Confidence Levels
% Plot the spectral kurtosis of a chirp signal in white noise, and see how the nonstationary non-Gaussian regime can be detected. 
% Explore the effects of changing the confidence level, and of invoking normalized frequency.

% Create a chirp signal, add white Gaussian noise, and plot.
fs = 1000;
t = 0:1/fs:10;
f1 = 300;
f2 = 400;

xc = chirp(t,f1,10,f2);
x = xc + randn(1,length(t));

figure
plot(t,x)
title('Chirp Signal with White Gaussian Noise')

% Plot the spectral kurtosis of the signal.
figure
pkurtosis(x,fs)
title('Spectral Kurtosis of Chirp Signal with White Gaussian Noise')

% The plot shows a clear extended excursion from 300–400 Hz. 
% This excursion corresponds to the signal component which represents the nonstationary chirp. 
% The area between the two horizontal red-dashed lines represents the zone of probable stationary and Gaussian behavior, as defined by the 0.95 confidence interval. 
% Any kurtosis points falling within this zone are likely to be stationary and Gaussian. 
% Outside of the zone, kurtosis points are flagged as nonstationary or non-Gaussian. Below 300 Hz, there are a few additional excursions slightly above the above the zone threshold. 
% These excursions represent false positives, where the signal is stationary and Gaussian, but because of the noise, has exceeded the threshold.

% Investigate the impact of the confidence level by changing it from the default 0.95 to 0.85.
figure
pkurtosis(x,fs,'ConfidenceLevel',0.85)
title('Spectral Kurtosis of Chirp Signal with Noise at Confidence Level of 0.85')

% The lower confidence level implies more sensitive detection of nonstationary or non-Gaussian frequency components. 
% Reducing the confidence level shrinks the thresh-delimited zone. 
% Now the low-level excursions — false alarms — have increased in both number and amount. 
% Setting the confidence level is a balancing act between achieving effective detection and limiting the number of false positives.

% You can accurately determine and compare the zone width for the two cases by using the pkurtosis form that returns it.
[sk1,~,thresh95] = pkurtosis(x);
[sk2,~,thresh85] = pkurtosis(x,'ConfidenceLevel',0.85);
thresh = [thresh95 thresh85]

% Plot the spectral kurtosis again, but this time, omit the sample time information so that pkurtosis plots normalized frequency.
figure 
pkurtosis(x,'ConfidenceLevel',0.85)
title('Spectral Kurtosis using Normalized Frequency')

% The frequency axis has changed from Hz to a scale from 0 to π rad/sample.

%% Plot Spectral Kurtosis Using a Customized Window Size
% The pkurtosis function uses the default pspectrum window size (time resolution). 
% You can specify the window size to use instead. 
% In this example, use the function kurtogram to return an optimal window size and use that result for pkurtosis.

% Create a chirp signal with white Gaussian noise.
fs = 1000;
t = 0:1/fs:10;
f1 = 300;
f2 = 400;
x = chirp(t,f1,10,f2)+randn(1,length(t));

% Plot the spectral kurtosis with the default window size.
figure
pkurtosis(x,fs)
title('Spectral Kurtosis with Default Window Size')

% Now compute the optimal window size using kurtogram.
figure
kurtogram(x,fs)

% The kurtogram plot also illustrates the chirp between 300 and 400 Hz, and shows that the optimum window size is 256. 
% Feed w0 into pkurtosis.
figure
w0 = 256;
pkurtosis(x,fs,w0)
title('Spectral Kurtosis with Optimum Window Size of 256')

% The main excursion has higher kurtosis values. 
% The higher values improve the differentiation between stationary and nonstationary components, and enhance your ability to extract the nonstationary component as a feature.

%% Plot Spectral Kurtosis Using a Customized Spectrogram
% When using signal input data, pkurtosis generates a spectrogram by using pspectrum with default options. 
% You can also create the spectrogram yourself if you want to customize the options.

% Create a chirp signal with white Gaussian noise.
fs = 1000;
t = 0:1/fs:10;
f1 = 300;
f2 = 400;
x = chirp(t,f1,10,f2)+randn(1,length(t));

% Generate a spectrogram that uses your specification for window, overlap, and number of FFT points. Then use that spectrogram in pkurtosis.
window = 256;
overlap = round(window*0.8);
nfft = 2*window;
[s,f,t] = spectrogram(x,window,overlap,nfft,fs);
figure
pkurtosis(s,fs,f,window)

% The magnitude of the excursion is higher, and therefore better differentiated, than with default inputs in previous examples. 
% However, the excursion magnitude here is not as high as it is in the kurtogram-optimized window example.

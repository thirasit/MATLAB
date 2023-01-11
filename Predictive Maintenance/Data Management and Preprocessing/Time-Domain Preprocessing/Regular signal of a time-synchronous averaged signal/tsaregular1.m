%%% Regular signal of a time-synchronous averaged signal

%% Find and Visualize the Regular Signal of a Compound TSA Signal
% Consider a drivetrain with six gears driven by a motor that is fitted with a vibration sensor, as depicted in the figure below. 
% Gear 1 on the motor shaft meshes with gear 2 with a gear ratio of 17:1. 
% The final gear ratio, that is, the ratio between gears 1 and 2 and gears 3 and 4, is 51:1. 
% Gear 5, also on the motor shaft, meshes with gear 6 with a gear ratio of 10:1. 
% The motor is spinning at 180 RPM, and the sampling rate of the vibration sensor is 50 KHz. 
% To retain the signal containing the meshing components of the gears 1 and 2, gears 3 and 4 and, the shaft rotation, specify their gear ratios of 17 and 51 in orderList. 
% The signal components corresponding to the shaft rotation (order = 1) is always implicitly included in the computation.

figure
imshow("FindAndVisualizeTheRegularSignalOfACompoundTSASignalE.png")

rpm = 180;                                          
fs = 50e3;                                          
t = (0:1/fs:(1/3)-1/fs)';                           % sample times
orderList = [17 51];                                
f = rpm/60*[1 orderList 10];

% In practice, you would use measured data such as vibration signals obtained from an accelerometer. For this example, generate TSA signal X, which is the simulated data from the vibration sensor mounted on the motor.
X = sin(2*pi*f(1)*t) + sin(2*pi*2*f(1)*t) + ...     % motor shaft rotation and harmonic
    3*sin(2*pi*f(2)*t) + 3*sin(2*pi*2*f(2)*t) + ... % gear mesh vibration and harmonic for gears 1 and 2
    4*sin(2*pi*f(3)*t) + 4*sin(2*pi*2*f(3)*t) + ... % gear mesh vibration and harmonic for gears 3 and 4
    2*sin(2*pi*10*f(1)*t);                          % gear mesh vibration for gears 5 and 6

% Compute the regular signal of the TSA signal using the sample time, rpm, and the mesh orders to be retained.
Y = tsaregular(X,t,rpm,orderList);

% The output Y is a vector containing everything except the gear mesh signal and harmonics for gears 5 and 6.
% Visualize the regular signal, the raw TSA signal, and their amplitude spectrum on a plot.
figure
tsaregular(X,fs,rpm,orderList)

% From the amplitude spectrum plot, observe the following components:
% - The retained component at the 17th order and its harmonic at the 34th order
% - The second retained component at the 51st order and its harmonic at the 102nd order
% - The filtered mesh components for gears 5 and 6 at the 10th order
% - The retained shaft component at the 1st and 2nd orders
% - The amplitudes on the spectrum plot match the amplitudes of individual signals

%% Compute Regular Signal and Amplitude Spectrum of a TSA Signal
% In this example, sineWavePhaseMod.mat contains the data of a phase modulated sine wave. 
% XT is a timetable with the sine wave data and rpm used is 60 RPM. 
% The sine wave has a frequency of 32 Hz and to recover the unmodulated sine wave, use 32 as the orderList.

% Load the data and the required variables.
load('sineWavePhaseMod.mat','XT','rpm','orders')
head(XT,4)

% Note that the time values in XT are strictly increasing, equidistant, and finite.
% Compute the regular signal and its amplitude spectrum. Set the value of 'Domain' to 'frequency' since the orders are in Hz.
[Y,S] = tsaregular(XT,rpm,orders,'Domain','frequency')

% The output Y is a timetable that contains the regular signal, that is, the unmodulated sine wave, while S is a vector that contains the amplitude spectrum of the regular signal Y.

%% Visualize the Regular Signal and Amplitude Spectrum of a TSA Signal
% In this example, sineWaveAmpMod.mat contains the data of an amplitude modulated sine wave. 
% X is a vector with the amplitude modulated sine wave data obtained at a shaft speed of 60 RPM. 
% The unmodulated sine wave has a frequency of 32 Hz and amplitude of 1.0 units.

% Load the data, and plot the regular signal of the amplitude modulated TSA signal X. 
% To retain the unmodulated signal, specify the frequency of 32 Hz in orderList. 
% Set the value of 'Domain' to 'frequency'.
load('sineWaveAmpMod.mat','X','t','rpm','orderList')
figure
tsaregular(X,t,rpm,orderList,'Domain','frequency');

% From the plot, observe the waveform and amplitude spectrum of the regular and raw signals, respectively. 
% Observe that the regular signal contains the unmodulated sine wave with an amplitude of 1.0 units and frequency of 32 Hz.

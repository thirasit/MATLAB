%%% Track and extract order magnitudes from vibration signal

%% Order Magnitudes of Chirp with Four Orders
% Create a simulated signal sampled at 600 Hz for 5 seconds. 
% The system that is being tested increases its rotational speed from 10 to 40 revolutions per second (or, equivalently, from 600 to 2400 revolutions per minute) during the observation period.
% Generate the tachometer readings.
fs = 600;
t1 = 5;
t = 0:1/fs:t1;

f0 = 10;
f1 = 40;
rpm = 60*linspace(f0,f1,length(t));

% The signal consists of four harmonically related chirps with orders 1, 0.5, 4, and 6. The amplitudes of the chirps are 1, 1/2, √2, and 2, respectively. To generate the chirps, use the trapezoidal rule to express the phase as the integral of the rotational speed.
o1 = 1;
o2 = 0.5;
o3 = 4;
o4 = 6;

a1 = 1;
a2 = 0.5;
a3 = sqrt(2);
a4 = 2;

ph = 2*pi*cumtrapz(rpm/60)/fs;

x = [a1 a2 a3 a4]*cos([o1 o2 o3 o4]'*ph);

% Extract and visualize the magnitudes of the orders.
figure
ordertrack(x,fs,rpm,[o1 o2 o3 o4])

%% Track Crossing Orders
% Create a simulated vibration signal consisting of two crossing orders corresponding to two different motors. 
% The signal is sampled at 300 Hz for 3 seconds. 
% The first motor increases its rotational speed from 10 to 100 revolutions per second (or, equivalently, from 600 to 6000 revolutions per minute) during the measurement. 
% The second motor increases its rotational speed from 50 to 70 revolutions per second (or 3000 to 4200 revolutions per minute) during the same period.
fs = 300;
nsamp = 3*fs;

rpm1 = linspace(10,100,nsamp)'*60;
rpm2 = linspace(50,70,nsamp)'*60;

% The measured signal is of order 1.2 and amplitude 2√2 with respect to the first motor. 
% With respect to the second motor, the signal is of order 0.8 and amplitude 4√2.
x = [2 4]*sqrt(2).*cos(2*pi*cumtrapz([1.2*rpm1 0.8*rpm2]/60)/fs);

% Make the first motor excite a resonance at the middle of the frequency range.
rs = [1+1./(1+linspace(-10,10,nsamp).^4)'/2 ones(nsamp,1)];
x = sum(rs.*x,2);

% Visualize the orders using rpmfreqmap.
rpmfreqmap(x,fs,rpm1)

% Compute the order magnitudes for both motors as a function of RPM. Use the Vold-Kalman algorithm to decouple the crossing orders.
figure
ordertrack(x,fs,[rpm1 rpm2],[1.2 0.8],[1 2],'Decouple',true)

%% Track Orders of Helicopter Vibration Data
% Analyze simulated data from an accelerometer placed in the cockpit of a helicopter.

% Load the helicopter data. 
% The vibrational measurements, vib, are sampled at a rate of 500 Hz for 10 seconds. 
% Inspection of the data reveals that it has a linear trend. 
% Remove the trend to prevent it from degrading the quality of the order estimation.
load('helidata.mat')

vib = detrend(vib);

% Compute the order-RPM map. Specify an order resolution of 0.005.
[map,order,rpm,time,res] = rpmordermap(vib,fs,rpm,0.005);

% Compute and plot the average order spectrum of the signal. 
% Find the three highest peaks of the spectrum.
figure
[spectrum,specorder] = orderspectrum(map,order);

[~,pkords] = findpeaks(spectrum,specorder,'SortStr','descend','Npeaks',3);

findpeaks(spectrum,specorder,'SortStr','descend','Npeaks',3)

% Track the amplitudes of the three highest peaks.
figure
ordertrack(map,order,rpm,time,pkords)

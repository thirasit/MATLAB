%%% Empirical mode decomposition

%% Perform Empirical Mode Decomposition and Visualize Hilbert Spectrum of Signal
% Load and visualize a nonstationary continuous signal composed of sinusoidal waves with a distinct change in frequency. The vibration of a jackhammer and the sound of fireworks are examples of nonstationary continuous signals. The signal is sampled at a rate fs.
load('sinusoidalSignalExampleData.mat','X','fs')
figure
t = (0:length(X)-1)/fs;
plot(t,X)
xlabel('Time(s)')

% The mixed signal contains sinusoidal waves with different amplitude and frequency values.
% To create the Hilbert spectrum plot, you need the intrinsic mode functions (IMFs) of the signal. Perform empirical mode decomposition to compute the IMFs and residuals of the signal. Since the signal is not smooth, specify 'pchip' as the interpolation method.
[imf,residual,info] = emd(X,'Interpolation','pchip');

% The table generated in the command window indicates the number of sift iterations, the relative tolerance, and the sift stop criterion for each generated IMF. This information is also contained in info. You can hide the table by adding the 'Display',0 name value pair.
% Create the Hilbert spectrum plot using the imf components obtained using empirical mode decomposition.
figure
hht(imf,fs)

% The frequency versus time plot is a sparse plot with a vertical color bar indicating the instantaneous energy at each point in the IMF. 
% The plot represents the instantaneous frequency spectrum of each component decomposed from the original mixed signal. 
% Three IMFs appear in the plot with a distinct change in frequency at 1 second.

%% Zero Crossings and Extrema in Intrinsic Mode Function of Sinusoid
% This trigonometric identity presents two different views of the same physical signal:
figure
imshow("Opera Snapshot_2023-01-31_062450_www.mathworks.com.png")
% Generate two sinusoids, s and z, such that s is the sum of three sine waves and z is a single sine wave with a modulated amplitude. 
% Verify that the two signals are equal by calculating the infinity norm of their difference.
t = 0:1e-3:10;
omega1 = 2*pi*100;
omega2 = 2*pi*20;
s = 0.25*cos((omega1-omega2)*t) + 2.5*cos(omega1*t) + 0.25*cos((omega1+omega2)*t);
z = (2+cos(omega2/2*t).^2).*cos(omega1*t);

norm(s-z,Inf) 

% Plot the sinusoids and select a 1-second interval starting at 2 seconds.
figure
plot(t,[s' z'])
xlim([2 3])
xlabel('Time (s)')
ylabel('Signal')

% Obtain the spectrogram of the signal. The spectrogram shows three distinct sinusoidal components. Fourier analysis sees the signals as a superposition of sine waves.
figure
pspectrum(s,1000,'spectrogram','TimeResolution',4)

% Use emd to compute the intrinsic mode functions (IMFs) of the signal and additional diagnostic information. 
% The function by default outputs a table that indicates the number of sifting iterations, the relative tolerance, and the sifting stop criterion for each IMF. 
% Empirical mode decomposition sees the signal as z.
[imf,~,info] = emd(s);

% The number of zero crossings and local extrema differ by at most one. This satisfies the necessary condition for the signal to be an IMF.
info.NumZerocrossing - info.NumExtrema

% Plot the IMF and select a 0.5-second interval starting at 2 seconds. The IMF is an AM signal because emd views the signal as amplitude modulated.
figure
plot(t,imf)
xlim([2 2.5])
xlabel('Time (s)')
ylabel('IMF')

%% Compute Intrinsic Mode Functions of Vibration Signal
% Simulate a vibration signal from a damaged bearing. 
% Perform empirical mode decomposition to visualize the IMFs of the signal and look for defects.
% A bearing with a pitch diameter of 12 cm has eight rolling elements. 
% Each rolling element has a diameter of 2 cm. 
% The outer race remains stationary as the inner race is driven at 25 cycles per second. 
% An accelerometer samples the bearing vibrations at 10 kHz.
fs = 10000;
f0 = 25;
n = 8;
d = 0.02;
p = 0.12;

figure
imshow("ComputeIntrinsicModeFunctionsOfVibrationSignalExample_01.png")

% The vibration signal from the healthy bearing includes several orders of the driving frequency.
t = 0:1/fs:10-1/fs;
yHealthy = [1 0.5 0.2 0.1 0.05]*sin(2*pi*f0*[1 2 3 4 5]'.*t)/5;

% A resonance is excited in the bearing vibration halfway through the measurement process.
yHealthy = (1+1./(1+linspace(-10,10,length(yHealthy)).^4)).*yHealthy;

% The resonance introduces a defect in the outer race of the bearing that results in progressive wear. The defect causes a series of impacts that recur at the ball pass frequency outer race (BPFO) of the bearing:
figure
imshow("Opera Snapshot_2023-01-31_063111_www.mathworks.com.png")
% where f_0 is the driving rate, n is the number of rolling elements, d is the diameter of the rolling elements, p is the pitch diameter of the bearing, and θ is the bearing contact angle. Assume a contact angle of 15° and compute the BPFO.
ca = 15;
bpfo = n*f0/2*(1-d/p*cosd(ca));

% Use the pulstran function to model the impacts as a periodic train of 5-millisecond sinusoids. Each 3 kHz sinusoid is windowed by a flat top window. Use a power law to introduce progressive wear in the bearing vibration signal.
fImpact = 3000;
tImpact = 0:1/fs:5e-3-1/fs;
wImpact = flattopwin(length(tImpact))'/10;
xImpact = sin(2*pi*fImpact*tImpact).*wImpact;

tx = 0:1/bpfo:t(end);
tx = [tx; 1.3.^tx-2];

nWear = 49000;
nSamples = 100000;
yImpact = pulstran(t,tx',xImpact,fs)/5;
yImpact = [zeros(1,nWear) yImpact(1,(nWear+1):nSamples)];

% Generate the BPFO vibration signal by adding the impacts to the healthy signal. Plot the signal and select a 0.3-second interval starting at 5.0 seconds.
yBPFO = yImpact + yHealthy;

xLimLeft = 5.0;
xLimRight = 5.3;
yMin = -0.6;
yMax = 0.6;

figure
plot(t,yBPFO)

hold on
[limLeft,limRight] = meshgrid([xLimLeft xLimRight],[yMin yMax]);
plot(limLeft,limRight,'--')
hold off

% Zoom in on the selected interval to visualize the effect of the impacts.
figure
plot(t,yBPFO)

hold on
[limLeft,limRight] = meshgrid([xLimLeft xLimRight],[yMin yMax]);
plot(limLeft,limRight,'--')
hold off
xlim([xLimLeft xLimRight])

% Add white Gaussian noise to the signals. Specify a noise variance of 1/150^2.
rn = 150;
yGood = yHealthy + randn(size(yHealthy))/rn;
yBad = yBPFO + randn(size(yHealthy))/rn;

figure
plot(t,yGood,t,yBad)
xlim([xLimLeft xLimRight])
legend('Healthy','Damaged')

% Use emd to perform an empirical mode decomposition of the healthy bearing signal. Compute the first five intrinsic mode functions (IMFs). Use the 'Display' name-value pair to show a table with the number of sifting iterations, the relative tolerance, and the sifting stop criterion for each IMF.
imfGood = emd(yGood,'MaxNumIMF',5,'Display',1);

% Use emd without output arguments to visualize the first three modes and the residual.
emd(yGood,'MaxNumIMF',5)

% Compute and visualize the IMFs of the defective bearing signal. The first empirical mode reveals the high-frequency impacts. This high-frequency mode increases in energy as the wear progresses. The third mode shows the resonance in the vibration signal.
imfBad = emd(yBad,'MaxNumIMF',5,'Display',1);

emd(yBad,'MaxNumIMF',5)

% The next step in the analysis is to compute the Hilbert spectrum of the extracted IMFs. 
% For more details, see the Compute Hilbert Spectrum of Vibration Signal example.

%% Visualize Residual and Intrinsic Mode Functions of Signal
% Load and visualize a nonstationary continuous signal composed of sinusoidal waves with a distinct change in frequency. The vibration of a jackhammer and the sound of fireworks are examples of nonstationary continuous signals. The signal is sampled at a rate fs.
load('sinusoidalSignalExampleData.mat','X','fs')
t = (0:length(X)-1)/fs;
figure
plot(t,X)
xlabel('Time(s)')

% The mixed signal contains sinusoidal waves with different amplitude and frequency values.
% Perform empirical mode decomposition to plot the intrinsic mode functions and residual of the signal. Since the signal is not smooth, specify 'pchip' as the interpolation method.
emd(X,'Interpolation','pchip','Display',1)

% emd generates an interactive plot with the original signal, the first 3 IMFs, and the residual. The table generated in the command window indicates the number of sift iterations, the relative tolerance, and the sift stop criterion for each generated IMF. You can hide the table by removing the 'Display' name-value pair or specifying it as 0.
% Right-click on the white space in the plot to open the IMF selector window. Use IMF selector to selectively view the generated IMFs, the original signal, and the residual.
figure
imshow("VisualizeIntrinsicModeFunctionsOfNonStationarySignalExample_03.png")

% Select the IMFs to be displayed from the list. Choose whether to display the original signal and residual on the plot.
figure
imshow("VisualizeIntrinsicModeFunctionsOfNonStationarySignalExample_04.png")

% The selected IMFs are now displayed on the plot.
figure
imshow("VisualizeIntrinsicModeFunctionsOfNonStationarySignalExample_05.png")

% Use the plot to visualize individual components decomposed from the original signal along with the residual. Note that the residual is computed for the total number of IMFs, and does not change based on the IMFs selected in the IMF selector window.

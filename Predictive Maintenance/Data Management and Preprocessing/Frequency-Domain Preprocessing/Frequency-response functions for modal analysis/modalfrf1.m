%%% Frequency-response functions for modal analysis

%% Frequency-Response Function of Hammer Excitation
% Visualize the frequency-response function of a single-input/single-output hammer excitation.
% Load a data file that contains:
% - Xhammer — An input excitation signal consisting of five hammer blows delivered periodically.
% - Yhammer — The response of a system to the input. Yhammer is measured as a displacement.
% The signals are sampled at 4 kHz. Plot the excitation and output signals.
load modaldata

figure
subplot(2,1,1)
plot(thammer,Xhammer(:))
ylabel('Force (N)')
subplot(2,1,2)
plot(thammer,Yhammer(:))
ylabel('Displacement (m)')
xlabel('Time (s)')

% Compute and display the frequency-response function. Window the signals using a rectangular window. Specify that the window covers the period between hammer blows.
winlen = size(Xhammer,1);
figure
modalfrf(Xhammer(:),Yhammer(:),fs,winlen,'Sensor','dis')

%% MIMO Frequency-Response Functions
% Compute the frequency-response functions for a two-input/two-output system excited by random noise.
% Load a data file that contains Xrand, the input excitation signal, and Yrand, the system response. 
% Compute the frequency-response functions using a 5000-sample Hann window and 50% overlap between adjoining data segments. 
% Specify that the output measurements are displacements.
load modaldata
winlen = 5000;

frf = modalfrf(Xrand,Yrand,fs,hann(winlen),0.5*winlen,'Sensor','dis');

% Use the plotting functionality of modalfrf to visualize the responses.
figure
modalfrf(Xrand,Yrand,fs,hann(winlen),0.5*winlen,'Sensor','dis')

%% Frequency-Response Function of SISO System
% Estimate the frequency-response function for a simple single-input/single-output system and compare it to the definition.
% A one-dimensional discrete-time oscillating system consists of a unit mass, m, attached to a wall by a spring with elastic constant k=1. 
% A sensor samples the displacement of the mass at F_s=1 Hz. 
% A damper impedes the motion of the mass by exerting on it a force proportional to speed, with damping constant b=0.01.

figure
imshow("FrequencyResponseFunctionOfSISOSystemExample_01.png")

% Generate 3000 time samples. Define the sampling interval Δt=1/F_s.
Fs = 1;
dt = 1/Fs;
N = 3000;
t = dt*(0:N-1);
b = 0.01;

figure
imshow("Opera Snapshot_2023-01-20_110520_www.mathworks.com.png")

Ac = [0 1;-1 -b];
A = expm(Ac*dt);

Bc = [0;1];
B = Ac\(A-eye(2))*Bc;

C = [1 0];
D = 0;

% The mass is driven by random input for the first 2000 seconds and then left to return to rest. 
% Use the state-space model to compute the time evolution of the system starting from an all-zero initial state. 
% Plot the displacement of the mass as a function of time.
rng default
u = randn(1,N)/2;
u(2001:end) = 0;

y = 0;
x = [0;0];
for k = 1:N
    y(k) = C*x + D*u(k);
    x = A*x + B*u(k);
end
figure
plot(t,y)

% Estimate the modal frequency-response function of the system. 
% Use a Hann window half as long as the measured signals. 
% Specify that the output is the displacement of the mass.
wind = hann(N/2);

[frf,f] = modalfrf(u',y',Fs,wind,'Sensor','dis');

% The frequency-response function of a discrete-time system can be expressed as the Z-transform of the time-domain transfer function of the system, evaluated at the unit circle. 
% Compare the modalfrf estimate with the definition.
[b,a] = ss2tf(A,B,C,D);

nfs = 2048;
fz = 0:1/nfs:1/2-1/nfs;
z = exp(2j*pi*fz);
ztf = polyval(b,z)./polyval(a,z);

figure
plot(f,20*log10(abs(frf)))
hold on
plot(fz*Fs,20*log10(abs(ztf)))
hold off
grid
ylim([-60 40])

% Estimate the natural frequency and the damping ratio for the vibration mode.
[fn,dr] = modalfit(frf,f,Fs,1,'FitMethod','PP')

% Compare the natural frequency to 1/2π, which is the theoretical value for the undamped system.
theo = 1/(2*pi)

%% Modal Parameters of Two-Body Oscillator
% Estimate the frequency-response function and modal parameters of a simple multi-input/multi-output system.

% An ideal one-dimensional oscillating system consists of two masses, m_1 and m_2, confined between two walls. 
% The units are such that m_1=1 and m_2=μ. 
% Each mass is attached to the nearest wall by a spring with an elastic constant k. 
% An identical spring connects the two masses. 
% Three dampers impede the motion of the masses by exerting on them forces proportional to speed, with damping constant b. 
% Sensors sample r_1 and r_2, the displacements of the masses, at F_s=50 Hz.

figure
imshow("ModalAnalysisOfTwoBodyOscillatorExample_01.png")

% Generate 30,000 time samples, equivalent to 600 seconds. Define the sampling interval Δt=1/F_s.
Fs = 50;
dt = 1/Fs;
N = 30000;
t = dt*(0:N-1);

figure
imshow("Opera Snapshot_2023-01-20_111141_www.mathworks.com.png")

k = 400;
b = 0.1;
m = 1/10;

Ac = [0 1 0 0;-2*k -2*b k b;0 0 0 1;k/m b/m -2*k/m -2*b/m];
A = expm(Ac*dt);
Bc = [0 0;1 0;0 0;0 1/m];
B = Ac\(A-eye(4))*Bc;
C = [1 0 0 0;0 0 1 0];
D = zeros(2);

% The masses are driven by random input throughout the measurement. 
% Use the state-space model to compute the time evolution of the system starting from an all-zero initial state.
rng default
u = randn(2,N);

y = [0;0];
x = [0;0;0;0];
for kk = 1:N
    y(:,kk) = C*x + D*u(:,kk);
    x = A*x + B*u(:,kk);
end

% Use the input and output data to estimate the transfer function of the system as a function of frequency. 
% Use a 15000-sample Hann window with 9000 samples of overlap between adjoining segments. 
% Specify that the measured outputs are displacements.
wind = hann(15000);
nove = 9000;
[FRF,f] = modalfrf(u',y',Fs,wind,nove,'Sensor','dis');

% Compute the theoretical transfer function as the Z-transform of the time-domain transfer function, evaluated at the unit circle.
nfs = 2048;
fz = 0:1/nfs:1/2-1/nfs;
z = exp(2j*pi*fz);

[b1,a1] = ss2tf(A,B,C,D,1);
[b2,a2] = ss2tf(A,B,C,D,2);

frf(1,:,1) = polyval(b1(1,:),z)./polyval(a1,z);
frf(1,:,2) = polyval(b1(2,:),z)./polyval(a1,z);
frf(2,:,1) = polyval(b2(1,:),z)./polyval(a2,z);
frf(2,:,2) = polyval(b2(2,:),z)./polyval(a2,z)

% Plot the estimates and overlay the theoretical predictions.
figure
for jk = 1:2
    for kj = 1:2
        subplot(2,2,2*(jk-1)+kj)
        plot(f,20*log10(abs(FRF(:,jk,kj))))
        hold on
        plot(fz*Fs,20*log10(abs(frf(jk,:,kj))))
        hold off
        axis([0 Fs/2 -100 0])
        title(sprintf('Input %d, Output %d',jk,kj))
    end
end

% Plot the estimates by using the syntax of modalfrf with no output arguments.
figure
modalfrf(u',y',Fs,wind,nove,'Sensor','dis')

% Estimate the natural frequencies, damping ratios, and mode shapes of the system. Use the peak-picking method for the calculation.
[fn,dr,ms] = modalfit(FRF,f,Fs,2,'FitMethod','pp');
fn

% Compare the natural frequencies to the theoretical predictions for the undamped system.
undamped = sqrt(eig([2*k -k;-k/m 2*k/m]))/2/pi

%% Frequency-Response Function Using Subspace Method
% Compute the frequency-response function of a two-input/six-output data set corresponding to a steel frame.
% Load a structure containing the input excitations and the output accelerometer measurements. The system is sampled at 1024 Hz for about 3.9 seconds.
load modaldata SteelFrame
X = SteelFrame.Input;
Y = SteelFrame.Output;
fs = SteelFrame.Fs;

% Use the subspace method to compute the frequency-response functions. Divide the input and output signals into nonoverlapping, 1000-sample segments. Window each segment using a rectangular window. Specify a model order of 36.
[frf,f] = modalfrf(X,Y,fs,1000,'Estimator','subspace','Order',36);

% Visualize the stabilization diagram for the system. Identify up to 15 physical modes.
figure
modalsd(frf,f,fs,'MaxModes',15)

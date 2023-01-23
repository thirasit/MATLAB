%%% Generate fault frequency bands for spectral feature extraction

%% Frequency Bands of Electrical Mains Supply
% For this example, generate frequency bands for analyzing the signal components around the first 5 harmonics of the mains supply frequency.

% With the fundamental frequency of 60 Hz, the frequency of the alternating current in the mains power supply, use faultBands to generate the first 5 harmonics of the mains supply.
F0 = 60;
N0 = 1:5;
FB = faultBands(F0,N0)

figure
imshow("Opera Snapshot_2023-01-23_094349_www.mathworks.com.png")

%% Frequency Bands of Faulty Induction Motor
% For this example, consider an induction motor with broken rotor bars. 
% Under normal operation with load, the rotor speed always lags the speed of the magnetic field allowing the rotor bars to cut magnetic lines of force and produce useful torque. 
% This difference is called slip. Considering a slip value of 0.03 in the system with broken rotors, construct frequency bands for sideband components around the fundamental frequency of 60 Hz.
F0 = 60;
N0 = 1:2;
slip = 0.03;
F1 = 2*slip*F0;
N1 = 1:3;
[FB,info] = faultBands(F0,N0,F1,N1)

%% Visualize Frequency Bands and Harmonics of the Electrical Mains Supply
% Construct frequency bands for analyzing the signal components around the first three harmonics of the electrical mains supply frequency.
% With the fundamental frequency of 60 Hz, the alternating current in the mains power supply, use faultBands to visualize the first 3 harmonics of the mains supply.
figure
F0 = 60;
N0 = 1:3;
faultBands(F0,N0)

% From the plot, observe the following:
% - The fundamental frequency, which is also the first harmonic, 1F0 at 60 Hz
% - The second harmonic, 2F0 at 120 Hz
% - The third harmonic, 3F0 at 180 Hz
% To better capture the expected variations of the actual system signals around the nominal fault frequencies, set the widths of each band to 10 Hz.
figure
faultBands(F0,N0,'Width',10)

%% Folding Negative Fault Frequencies
% For this example, consider an induction motor with static and dynamic rotor eccentricities. 
% Construct and visualize the frequency bands for the 4 sideband components of an induction motor with 4 pole pairs around the fundamental frequency due to the rotor eccentricities.
F0 = 60;
N0 = 1;
slip = 0.029;
polePairs = 4;
F1 = 2*F0*(1-slip)/polePairs

figure
N1 = 0:4;
faultBands(F0,N0,F1,N1)

% To avoid truncating negative fault frequency bands, set 'Folding' to true to fold them onto the positive frequency axis.
figure
faultBands(F0,N0,F1,N1,'Folding',true)

% Observe that the sideband frequencies 1F0-3F1 and 1F0-4F1 are now visible on the positive axis.

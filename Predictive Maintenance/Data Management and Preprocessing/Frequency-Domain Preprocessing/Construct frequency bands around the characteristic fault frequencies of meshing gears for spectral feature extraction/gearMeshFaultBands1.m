%%% Construct frequency bands around the characteristic fault frequencies of meshing gears for spectral feature extraction

%% Frequency Bands of Pinion and Gear Mesh
% For this example, consider a simple gear set with an 8-toothed pinion on the input shaft meshing with a 42-toothed spur gear on the output shaft. 
% Assume that the input shaft is spinning at 20 rpm. 
% Construct the gear mesh frequency bands using the physical characteristics of the gear set.
Ni = 8;
No = 42;
FR = 20;
[FB,info] = gearMeshFaultBands(FR,Ni,No)

% FB is a 5x2 array which includes the primary frequencies 1Fi, 1Fo, 1Fa and 1Fm respectively. 
% The structure info contains the center frequencies and labels of each frequency range in FB.

%% Frequency Bands and Spectral Metrics of Gear Train
% For this example, consider a simple gear set with an 8-toothed pinion on the input shaft meshing with a 42-toothed spur gear on the output shaft. 
% Assume that the input shaft is driven at 20 Hz. 
% The dataset motorSignal.mat contains vibration data for the gear mesh sampled at 1500 Hz.

% First, construct the gear mesh frequency bands using the physical characteristics of the gear set. 
% Construct the frequency bands with the first 3 sidebands.
Ni = 8;
No = 42;
FR = 20;
FB = gearMeshFaultBands(FR,Ni,No,'Sidebands',1:3)

% FB is a 15x2 array which includes the primary frequencies and their sidebands.
% Load the vibration data and compute PSD and frequency grid using pspectrum. 
% Use a frequency resolution of 0.5.
load('motorSignal.mat','C');
fs = 1500;
[psd,freqGrid] = pspectrum(C,fs,'FrequencyResolution',0.5);

% Now, use the frequency bands and PSD data to compute the spectral metrics.
spectralMetrics = faultBandMetrics(psd,freqGrid,FB)

% spectralMetrics is a 1x46 table with peak amplitude, peak frequency and band power calculated for each frequency range in FB. 
% The last column in spectralMetrics is the total band power, computed across all 15 frequencies in FB.

%% Visualize Frequency Bands for Pinion and Gear Set
% For this example, consider a simple pinion and gear set with an input shaft speed of 1800 rpm. 
% Considering that the pinion on the input shaft has 6 teeth and the gear on the output shaft has 8 teeth, visualize the frequency bands for the gear mesh.
figure
FR = 1800;
Ni = 6;
No = 8;
gearMeshFaultBands(FR,Ni,No)

% From the plot, observe the following:
% - Output shaft defect frequency, 1Fo at 1350 Hz
% - Input shaft defect frequency, 1Fi at 1800 Hz
% - Assembly phase defect frequency, 1Fa at 5400 Hz
% - Gear mesh defect frequency, 1Fm at 10800 Hz

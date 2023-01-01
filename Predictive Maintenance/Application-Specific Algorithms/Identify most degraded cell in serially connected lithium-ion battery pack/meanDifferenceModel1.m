%%% Identify most degraded cell in serially connected lithium-ion battery pack

%% Identify Worst Cell in Serially Connected Battery Pack
% Load the data, which represents an operating profile for an eight-cell battery pack in which one cell is experiencing an internal short circuit. The profile includes standby, driving, charging, and balancing phases. The data consists of 10 columns that contain the sample time (column 1), battery voltages (columns 2–9), and pack current (column 10).
load internalShortCircuit.mat internalShortCircuit

% Plot the battery voltages and the pack current together.
figure
plot(internalShortCircuit(:,2:9))
hold on
plot(internalShortCircuit(:,10))
legend('Voltages (V)','Current (A)')
title('internalShortCircuit Datasets - Voltages and Pack Current')
ylabel('Voltage (V) and Current (A) Values')
hold off

% The voltages appear to track closely, but at this scale it is hard to differentiate them.
% Zoom into the region after t = 4000 to show the individual voltages more clearly.
figure
xlim([4000 4010])
ylim([3.4 3.6])
title('Voltage Separation')
ylabel('Voltages (V)')

% The voltages track closely together. There is no cell that is obviously degrading relative to the others.
% Identify the worst cell using meanDifferenceModel.
figure
meanDifferenceModel(internalShortCircuit(:,2:end))

% The mean difference model clearly differentiates cell 5.

%% Specify Time and Current Variables
% Load the data, which is contained in a table, and show the first two rows.
load internalShortCircuitTbl.mat internalShortCircuitTbl
head(internalShortCircuitTbl,2)

data = internalShortCircuitTbl;

% Use meanDifferenceModel to identify the worst cell, specifying the time and current variables. Use Time to specify the time variable. Use CurrentVariable to specify the current variable.
figure
meanDifferenceModel(data(:,2:end),Time=data.Time,CurrentVariable="Current")

% The plot identifies the worst cell.

%% Obtain Model Analysis Results
% Load the data, which is contained in a table.
load internalShortCircuitTbl.mat internalShortCircuitTbl
data = internalShortCircuitTbl;

% Run meanDifferenceModel, using output arguments to store the analysis results.
[worstcell,deltae,deltar0] = meanDifferenceModel(data(:,2:end),Time=data.Time,CurrentVariable="Current");

% Identify the worst cell.
iwc = worstcell

% Plot the estimated internal resistance deviations.
figure
time = data.Time;
plot(data.Time,deltar0.Variables)
title('Estimated Internal Resistance Deviation from Mean')
legend("Cell 1","Cell 2","Cell 3","Cell 4","Cell 5","Cell 6","Cell 7","Cell 8")
ylabel('deltaR0')

% Cell 5, which the function identifies as the worst cell, has the largest internal resistance deviation.

%%% Generate ensemble data by running a Simulink model

%% Generate Ensemble of Fault Data
% Generate a simulation ensemble datastore of data representing a machine operating under fault conditions by simulating a Simulink® model of the machine while varying a fault parameter.
% Load the Simulink model. 
% This model is a simplified version of the gear-box model described in Using Simulink to Generate Fault Data. 
% For this example, only one fault mode is modeled, a gear-tooth fault.
mdl = 'TransmissionCasingSimplified';
open_system(mdl)

% The gear-tooth fault is modeled as a disturbance in the Gear Tooth fault subsystem. 
% The magnitude of the disturbance is controlled by the model variable ToothFaultGain, where ToothFaultGain = 0 corresponds to no gear-tooth fault (healthy operation). 
% To generate the ensemble of fault data, you use generateSimulationEnsemble to simulate the model at different values of ToothFaultGain, ranging from -2 to zero. 
% This function uses an array of Simulink.SimulationInput objects to configure the Simulink model for each member in the ensemble. 
% Each simulation generates a separate member of the ensemble in its own data file. 
% Create such an array, and use setVariable to assign a tooth-fault gain value for each run.
toothFaultValues  = -2:0.5:0; % 5 ToothFaultGain values 

for ct = numel(toothFaultValues):-1:1
    simin(ct) = Simulink.SimulationInput(mdl);
    simin(ct) = setVariable(simin(ct),'ToothFaultGain',toothFaultValues(ct));
end

% For this example, the model is already configured to log certain signal values, Vibration and Tacho (see Export Signal Data Using Signal Logging (Simulink)). generateSimulationEnsemble further configures the model to:
% - Save logged data to files in the folder you specify.
% - Use the timetable format for signal logging.
% - Store each Simulink.SimulationInput object in the saved file with the corresponding logged data.
% Specify a location for the generated data. For this example, save the data to a folder called Data within your current folder. The indicator status is 1 (true) if all the simulations complete without error.
mkdir Data
location = fullfile(pwd,'Data');
[status,E] = generateSimulationEnsemble(simin,location);

% Inside the Data folder, examine one of the files. Each file is a MAT-file containing the following MATLAB® variables:
% - SimulationInput — The Simulink.SimulationInput object that was used to configure the model for generating the data in the file. You can use this to extract information about the conditions (such as faulty or healthy) under which this simulation was run.
% - logsout — A Dataset object containing all the data that the Simulink model is configured to log.
% - PMSignalLogName — The name of the variable that contains the logged data ('logsout' in this example). The simulationEnsembleDatastore command uses this name to parse the data in the file.
% - SimulationMetadata — Other information about the simulation that generated the data logged in the file.
% Now you can create the simulation ensemble datastore using the generated data. The resulting simulationEnsembleDatastore object points to the generated data. The object lists the data variables in the ensemble, and by default all the variables are selected for reading. Examine the DataVariables and SelectedVariables properties of the ensemble to confirm these designations.
ensemble = simulationEnsembleDatastore(location)

ensemble.DataVariables

ensemble.SelectedVariables

% You can now use ensemble to read and analyze the generated data in the ensemble datastore. See simulationEnsembleDatastore for more information.

% Set up and Run Model Script for the Automatic Cruise Control (ACC) Example
%
% This script initializes the ACC example model. It loads necessary control
% constants and sets up the buses required for the referenced model
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2017 The MathWorks, Inc.

%% General Model parameters
Ts = 0.1;               % Simulation sample time                (s)

%% Scenario Authoring
% Create scenario object from ACCTestBenchScenario function
% Comment out the following line if you wish to create a new scenario using
% the helperScenarioAuthoring function
[scenario,egoVehicle] = ACCTestBenchScenario;

% Define road curvature
R           = 760;      % Radius of curvature for the road      (m)

% Uncomment the following line and edit helperScenarioAuthoring to author
% a new scenario 
% [scenario,egoVehicle] = helperScenarioAuthoring(R, true);

%% Tracking and Sensor Fusion Parameters                        Units
clusterSize = 4;        % Distance for clustering               (m)
assigThresh = 50;       % Tracker assignment threshold          (N/A)
M           = 2;        % Tracker M value for M-out-of-N logic  (N/A)
N           = 3;        % Tracker M value for M-out-of-N logic  (N/A)
numCoasts   = 5;        % Number of track coasting steps        (N/A)
numTracks   = 20;       % Maximum number of tracks              (N/A)
numSensors  = 2;        % Maximum number of sensors             (N/A)

% Position and velocity selectors from track state
% The filter initialization function used in this example is initcvekf that 
% defines a state that is: [x;vx;y;vy;z;vz]. 
posSelector = [1,0,0,0,0,0; 0,0,1,0,0,0]; % Position selector   (N/A)
velSelector = [0,1,0,0,0,0; 0,0,0,1,0,0]; % Velocity selector   (N/A)

%% Ego Car 
% Dynamics modeling parameters
m       = 1575;     % Total mass of vehicle                          (kg)
Iz      = 2875;     % Yaw moment of inertia of vehicle               (m*N*s^2)
lf      = 1.2;      % Longitudinal distance from c.g. to front tires (m)
lr      = 1.6;      % Longitudinal distance from c.g. to rear tires  (m)
Cf      = 19000;    % Cornering stiffness of front tires             (N/rad)
Cr      = 33000;    % Cornering stiffness of rear tires              (N/rad)
tau     = 0.5;      % Longitudinal time constant                     (N/A)

% Initial condition for the ego car
v0_ego = 20.6;         % Initial speed of the ego car           (m/s)
x0_ego = 0;            % Initial x position of ego car          (m)
y0_ego = -R+2.2;       % Initial y position of ego car          (m)

%Ego Vehicle Actor ID
egoID = egoVehicle.ActorID;
  
% Linear model for ACC design
G = helperACCLinearModel(m,Iz,lf,lr,Cf,Cr,tau,v0_ego);     

%% Automatic Cruise Control (ACC) Controller Parameters
v_set           = 21.5; % ACC set speed                         (m/s)
time_gap        = 1.5;  % ACC time gap                          (s)
default_spacing = 5;    % ACC default spacing                   (m)
verr_gain       = 0.5;  % ACC velocity error gain               (N/A)
xerr_gain       = 0.2;  % ACC spacing error gain                (N/A)
vx_gain         = 0.4;  % ACC relative velocity gain            (N/A)
max_ac          = 2;    % Maximum acceleration                  (m/s^2)
min_ac          = -3;   % Minimum acceleration                  (m/s^2)

%% Driver steering control paramaters
driver_P        = 0.2;  % Proportional gain                     (N/A)
driver_I        = 0.1;  % Integral gain                         (N/A)
yawerr_gain     = 2;    % Yaw error gain                        (N/A)

%% Enabling variants
% This sets up the classical control variant.  
% Uncomment line 82 to run the MPC based ACC.
controller_type = 1;    % Select classical MPC ACC              (N/A)
% controller_type = 2;    % Select MPC ACC                      (N/A)

%% Check MPC license and add MPC data
% To run the second variant of the controller, a Model Predictive Control
% license is required.
hasMPCLicense = license('checkout','MPC_Toolbox');
if ~hasMPCLicense
   disp('Note: a license to the Model Predictive Control product is required to run the MPC controller variant (controller_type == 2) but no license was not detected.')
end

%% Bus Creation
% Create the bus of actors from the scenario reader
modelName = 'ACCTestBenchExample';
wasModelLoaded = bdIsLoaded(modelName);
if ~wasModelLoaded
    load_system(modelName)
end
blk=find_system(modelName,'System','driving.scenario.internal.ScenarioReader');
s = get_param(blk{1},'PortHandles');
get(s.Outport(1),'SignalHierarchy');

% Create bus for detections (Input to the referenced model)
blk=find_system(modelName,'System','visionDetectionGenerator');
visionDetectionGenerator.createBus(blk{1});
blk=find_system(modelName,'System','drivingRadarDataGenerator');
radarDetectionGenerator.createBus(blk{1});

% Create the bus of tracks (output from referenced model)
refModel = 'ACCWithSensorFusionMdlRef';
wasReModelLoaded = bdIsLoaded(refModel);
if ~wasReModelLoaded
    load_system(refModel)
    blk=find_system(refModel,'MatchFilter', @Simulink.match.allVariants,'System','multiObjectTracker');
    multiObjectTracker.createBus(blk{1});
    close_system(refModel)
else
    blk=find_system(refModel,'MatchFilter', @Simulink.match.allVariants,'System','multiObjectTracker');
    multiObjectTracker.createBus(blk{1});
end

if ~wasModelLoaded
    close_system(modelName)
end

%% Code generation
% Uncomment this if you would like to generate code.
% rtwbuild(refModel);
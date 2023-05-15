% Setup script for the Lane Change Example
%
% This script initializes the Lane Change Example model and loads
% necessary control constants.
%
%   This is a helper for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.

%% General Model Parameters
Ts = 0.1;               % Simulation sample time  (s)
tau = 0.5;
PredictionHorizon = 30;

%% Create driving scenario
% Scenario files created by the Driving Scenario Designer
scenarioFileNames = {
    'doubleLaneChangeScenario.mat',...
    'additionalScenario.mat',...
    };
% Names of scenario functions exported from the Driving Scenario Designer
scenarioFcnNames = {
    'doubleLaneChangeScenario',...
    'additionalScenario',...
    };

% Select scenario
scenarioId = 1;

% Function name for selected scenario
scenarioFcnName = scenarioFcnNames{scenarioId};
% File name for selected scenario
scenarioFileName = scenarioFileNames{scenarioId};

% Set file name in Scenario Reader block
set_param('LaneChangeExample/Vehicle and Environment/Scenario Reader',...
    'ScenarioFileName',scenarioFileName)

% Initial conditions of ego car and actor profiles
[scenario,egoCar,actor_Profiles] = helperSessionToScenario(scenarioFileName);

% Initial condition for the ego car in ISO 8855 coordinates
v_set = egoCar.v0;          % ACC set speed (m/s)
v0_ego = egoCar.v0;         % Initial speed of the ego car (m/s)
x0_ego = egoCar.x0;         % Initial x position of ego car (m)
y0_ego = egoCar.y0;         % Initial y position of ego car (m)
yaw0_ego = egoCar.yaw0;     % Initial yaw angle of ego car (rad)

% Convert ISO 8855 to SAE J670E coordinates
y0_ego = -y0_ego;
yaw0_ego = -yaw0_ego;

% Get the maximum stop time from scenario
vehiclePoses = record(scenario);
stopTime = vehiclePoses(end).SimulationTime;

% Define a simulation stop time For the scenarios available with this
% example,10 seconds of simulation is sufficient to capture the lane change
% behavior, this can be changed based on custom scenarios. Parameter
% 'stopTime' is to extract simulation time for shorter scenarios.
simStopTime = min(10,stopTime);  

%% Ego Car Parameters
% Dynamics modeling parameters
m = 1575;      % Total mass of vehicle (kg)
Iz = 2875;     % Yaw moment of inertia of vehicle (kgm^2)
lf = 1.2;      % Longitudinal distance from c.g. to front tires (m)
lr = 1.6;      % Longitudinal distance from c.g. to rear tires (m)
Cf = 19000;    % Cornering stiffness of front tires (N/rad)
Cr = 33000;    % Cornering stiffness of rear tires (N/rad)

%% Bus Creation
% Load the Actors bus used by scenario reader
helperCreateBusActorsLC;

% Create buses for lane boundaries
helperCreateLaneBoundariesLC;

%% Design Non Linear MPC controller for lane change control
nlobj = helperCreateNLmpcObjLC;

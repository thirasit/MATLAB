function [scenario, egoVehicle] = doubleLaneChangeScenario()
% Part of set up script for the Lane Change Example
%
% This function generates the double lane change driving scenario.
%
%   This is a helper for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.

% Construct a drivingScenario object.
scenario = drivingScenario('StopTime', 35, ...
    'SampleTime', 0.1);

% Add all road segments
roadCenters = [0 3.6 0;
    1400 3.6 0];
laneSpecification = lanespec(4);
road(scenario, roadCenters, 'Lanes', laneSpecification);

% Add the ego vehicle
egoVehicle = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [200 1.8 0]);
waypoints = [200 1.8 0;
    240.5 1.8 0;
    267 1.8 0;
    268 1.8 0;
    297 5.4 0;
    298 5.4 0;
    359 5.4 0;
    360 5.4 0;
    400 9 0;
    401 9 0;
    1400 9 0];
speed = [15;15;15;15;20;20;20;20;26;26;26];
trajectory(egoVehicle, waypoints, speed);

% Add the non-ego actors
egoFront1 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [238 1.4 0]);
waypoints = [238 1.4 0;
    300 1.8 0;
    340 1.8 0;
    400 1.8 0;
    500 1.8 0;
    550 1.8 0;
    600 1.8 0;
    1400 1.8 0];
speed = 0.2;
trajectory(egoFront1, waypoints, speed);

leftRear1 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [140 5.4 0]);
waypoints = [140 5.4 0;
    360 5.4 0;
    361 5.4 0;
    410 9 0;
    411 9 0;
    1400 9 0];
speed = 15;
trajectory(leftRear1, waypoints, speed);

leftFront1 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [269 5.2 0]);
waypoints = [269 5.2 0;
    370.2 5.4 0;
    650 5.4 0;
    700 5.4 0;
    751 5.4 0;
    1400 5.4 0];
speed = 10;
trajectory(leftFront1, waypoints, speed);

right1 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [186 -1.8 0]);
waypoints = [186 -1.8 0;
    250.4 -1.8 0;
    1400 -1.8 0];
speed = 12;
trajectory(right1, waypoints, speed);

right2 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [222 -1.8 0]);
waypoints = [222 -1.8 0;
    286 -1.8 0;
    1400 -1.8 0];
speed = 12;
trajectory(right2, waypoints, speed);

right3 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [258 -1.8 0]);
waypoints = [258 -1.8 0;
    332.3 -1.8 0;
    1400 -1.8 0];
speed = 12;
trajectory(right3, waypoints, speed);

right4 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [294 -1.8 0]);
waypoints = [294 -1.8 0;
    340.6 -1.8 0;
    1400 -1.9 0];
speed = 12;
trajectory(right4, waypoints, speed);

leftRear2 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [100 5.4 0]);
waypoints = [100 5.4 0;
    640 5.4 0;
    641 5.4 0;
    680 9 0;
    681 9 0;
    1400 9 0];
speed = 15;
trajectory(leftRear2, waypoints, speed);

farLeft1 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [10 9 0]);
waypoints = [60 9 0;
    1400 9 0];
speed = 26;
trajectory(farLeft1, waypoints, speed);

farLeft2 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [100 9 0]);
waypoints = [100 9 0;
    1400 9 0];
speed = 30;
trajectory(farLeft2, waypoints, speed);


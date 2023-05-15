function [scenario, egoVehicle] = additionalScenario()
% Part of set up script for the Lane Change Example
%
% This function generates the additional driving scenario.
%
%   This is a helper for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.

% Construct a drivingScenario object.
scenario = drivingScenario('StopTime', 35, ...
    'SampleTime', 0.1);

% Add all road segments
roadCenters = [-10.4 0 0;
    188.1 0.4 0];
laneSpecification = lanespec(5);
road(scenario, roadCenters, 'Lanes', laneSpecification);

% Add the ego vehicle
egoVehicle = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [-3.4 7.5 0]);
waypoints = [-3.4 7.5 0;
    9.4 7.7 0;
    21.1 7.7 0;
    38.9 8 0;
    70 7.5 0;
    85.8 7.7 0;
    103.9 7.7 0;
    130.1 8 0;
    151.5 7.5 0;
    175.5 6.9 0];
speed = 15;
trajectory(egoVehicle, waypoints, speed);

% Add the non-ego actors
car1 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [37.5 6.8 0]);
waypoints = [37.5 6.8 0;
    48.3 7 0;
    68.5 6.6 0;
    83 6.2 0;
    96.2 3.6 0;
    116.1 3.6 0;
    141.1 3.6 0;
    158.4 3.6 0];
speed = 4;
trajectory(car1, waypoints, speed);

car2 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [36.5 3.5 0]);
waypoints = [36.5 3.5 0;
    58 4.2 0;
    89.4 2.9 0;
    114.1 3.1 0;
    134.7 3.4 0;
    181.6 3.1 0];
speed = 13;
trajectory(car2, waypoints, speed);

car4 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [28.6 -3.6 0]);
waypoints = [28.6 -3.6 0;
    40.17 -3.31 0.01;
    50.9 -2.8 0.01;
    109.61 -3.1 0.01;
    131.1 -3.3 0;
    146.5 -2.8 0;
    180.9 -3 0];
speed = 12.5;
trajectory(car4, waypoints, speed);

car5 = vehicle(scenario, ...
    'ClassID', 1, ...
    'Position', [28.3 -7.15 0.01]);
waypoints = [28.3 -7.15 0.01;
    37.8 -6.82 0.01;
    59.1 -6.3 0;
    82.5 -6.7 0;
    96.8 -6.8 0;
    123.2 -6.8 0;
    144.7 -7.2 0;
    173.6 -6.8 0];
speed = 10;
trajectory(car5, waypoints, speed);


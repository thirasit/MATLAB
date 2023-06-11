function varargout = helperScenarioAuthoring(radius, toDisplay)
%helperScenarioAuthoring Author a curved road scenario
%
%   This is a helper function for example purposes and may be removed or
%   modified in the future.
%
% helperScenarioAuthoring(radius, toDisplay) creates driving scenario that
% contains a road with radius of curvature, radius. You can set the flag
% toDisplay to true in order to visualize the scenario.
%
% scenario = helperScenarioAuthoring(...), in addition, allows you to
% output the driving scenario object.
%
%   Inputs:                                                     Defaults
%       R         - Radius of curvature (in meters)             760
%       toDisplay - a logical flag. True for scenario display   false
%
%   Output:
%       scenario  - the generated driving scenario

% Copyright 2017 The MathWorks, Inc.

%% Inputs and defaults
if nargin < 2
    toDisplay = false;
    if nargin < 1
        radius = 760;
    end
end
validateattributes(radius, {'numeric'}, {'real', 'positive', 'scalar'}, mfilename, 'radius')
validateattributes(toDisplay, {'numeric','logical'}, {'binary', 'scalar'}, mfilename, 'toDisplay')


%% Define a scenario
scenario = drivingScenario;
scenario.SampleTime = 0.1;

%% Define Scenario Plots 
if toDisplay
    hFigure = figure;
    hAxes = axes(hFigure);
    plot(scenario,'Parent',hAxes,'Centerline','on','Waypoints','off','RoadCenters','off');
end

%% Road Definition
% Define a road with a constant radius of curvature, R
roadTurn = pi/3;    % Create a road that turns 60 degrees
roadWidth = 7.2;    % Road width is two lanes, 3.6 meters each
bankAngle = 0;      % Banking angle for the road
numSamples = 200;   % Define the road with sample points
samples = linspace(0,roadTurn,numSamples)';
road1Centers = radius*[sin(samples),-cos(samples),zeros(numSamples,1)];
road(scenario,road1Centers,roadWidth,bankAngle);

% Define another road parallel to the first
% offSet = [0,8,0];
road2Centers = (radius-8)*[sin(samples),-cos(samples),zeros(numSamples,1)];
road(scenario,road2Centers,roadWidth,bankAngle);

%% Define Vehicles 

numVehicles = 5;

% Define egoVehicle
egoVehicle = vehicle(scenario, ...
    'ClassID', 1, ...
    'Mesh', driving.scenario.carMesh, ...
    'Name', 'Vehicle Under Test');

% Here you define all the vehicles other than the ego
for i = 1:numVehicles-1
    vehicles(i) = vehicle(scenario, ...
    'ClassID', 1, ...
    'Mesh', driving.scenario.carMesh);
end

% Define the path and velocity of each vehicle
% Fast car in left lane, ahead
trajectory(vehicles(1), road1Centers(round(0.15*numSamples):end,:) +[0,2,0], 19.4);

% Slow car in right lane
trajectory(vehicles(2), road1Centers(round(0.25*numSamples):end,:)+[0,-2,0], 11.1);

% Passing car. Starts in right lane, then passes slower car on the left
n = 20; % Number of road samples needed to change lanes
inRight1 = repmat([0,-2,0],[round(0.2*numSamples),1]);         % In right lane
toLeft = [zeros(n,1),(-2:4/(n-1):2)',zeros(n,1)];              % Moving to left lane
inLeft = repmat([0,+2,0],[round(0.15*numSamples)-n,1]);        % In left lant
toRight = [zeros(n,1), (2:-4/(n-1):-2)', zeros(n,1)];          % Moving to right lane
inRight2 = repmat([0,-2,0],[round(0.5*numSamples)+1-n,1]);     % In right lane again
passingOffset = [inRight1; toLeft; inLeft; toRight; inRight2]; % Overall offset
trajectory(vehicles(3), road1Centers(round(0.15*numSamples):end,:)+passingOffset, 16.6);

% Car traveling on the opposite side of the road
trajectory(vehicles(4), flip(road2Centers)+[0,2,0], 19.9);

if nargout == 2
    varargout = {scenario,egoVehicle};
elseif nargout == 1
    varargout = {scenario};    
else
    varargout = {};
end
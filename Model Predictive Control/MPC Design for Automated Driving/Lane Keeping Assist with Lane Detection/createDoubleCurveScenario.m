function [scenario,egoCar] = createDoubleCurveScenario(plotScenario) 
% Create scenario and road specifications

if nargin < 1
    plotScenario = false;
end

% Design parameters
R = 250;          % radius (m) of curve
dev = [-3 3 -3];  % waypoint deviation (m) from the center of roads for
                  % each change of curvature point
speed = 13.9;     % ego speed (m/s), 13.9 m/s = 50 kph
sampleTime = 0.1; % simulation sample time (sec)

straightSegmentLength = 60;   % length of straight road segment
pointsPerSegment = 5;         % number of points per road segment

% Construct a drivingScenario object.
scenario = drivingScenario(...
    'SampleTime', sampleTime);

% Road segment #1: straight
road1X = linspace(0,straightSegmentLength,pointsPerSegment);
road1Y = zeros(size(road1X));  

% Road segment #2: left curve (counter clock wise)
theta = linspace(0,45,(pointsPerSegment+1));
theta = theta(2:end);
radiusCenterX = road1X(end);
radiusCenterY = road1Y(end) + R;
road2X = radiusCenterX + R * sin(deg2rad(theta));
road2Y = radiusCenterY - R * cos(deg2rad(theta));

% Road segment #3: right curve (clock wise)
radiusCenterX = radiusCenterX + 2*R*sin(deg2rad(45));
radiusCenterY = radiusCenterY - 2*R*cos(deg2rad(45));
road3X = radiusCenterX - R * sin(deg2rad(45 - theta));
road3Y = radiusCenterY + R * cos(deg2rad(45 - theta));   

% Road segment #4 : straight
road4X = road3X(end) + road1X(2:end);
road4Y = road3Y(end) + road1Y(2:end);

roadCenters = [road1X road2X road3X road4X;...
               road1Y road2Y road3Y road4Y]';
           
% Waypoints of ego car
waypoints = roadCenters; % follow the road
% Deviate at straight to left curve
index = numel(road1X) + 1;
waypoints(index,2) = waypoints(index,2) + dev(1);  

% Deviate at left curve to right curve (45 degrees)
index = index + numel(road2X);
waypoints(index,1) = waypoints(index,1) - sqrt(0.5)*dev(2); 
waypoints(index,2) = waypoints(index,2) + sqrt(0.5)*dev(2);

% Deviate at right curve to straight
index = index + numel(road3X);
waypoints(index,2) = waypoints(index,2) + dev(3); 

% Create lanes
laneSpecification = lanespec(3);
road(scenario, roadCenters, 'Lanes', laneSpecification);

% Add ego car
egoCar = vehicle(scenario, ...
    'ClassID', 1);
trajectory(egoCar, waypoints, speed);

if plotScenario
    plot(scenario,'Waypoints','on');
end
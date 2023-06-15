function [driverPath, x0, y0, v0, yaw0, simStopTime] = ...
    createDriverPath(scenario,egoID,subsample)
% Create driver path

% v0    % Initial speed of the ego car           (m/s)
% x0    % Initial x position of ego car          (m)
% y0    % Initial y position of ego car          (m)
% yaw0  % Initial yaw angle of ego car           (degrees)

if nargin < 2
    subsample = 4;
end

% Extract ego pose information
x0 = scenario.Actors(egoID).Position(1);
y0 = scenario.Actors(egoID).Position(2);
v0 = norm(scenario.Actors(egoID).Velocity(:));
yaw0 = deg2rad(scenario.Actors(egoID).Yaw);

% Driver path is a subsampled version of ego poses
restart(scenario);
poses = record(scenario);
numPoints = floor(numel(poses)/subsample);

driverPath = zeros(numPoints,2);
for n = 1:numPoints
    poseIndex = 1 + (n-1) * subsample;
    driverPath(n,:) = poses(poseIndex).ActorPoses(1).Position(1:2);
end

simStopTime = poses(poseIndex).SimulationTime;

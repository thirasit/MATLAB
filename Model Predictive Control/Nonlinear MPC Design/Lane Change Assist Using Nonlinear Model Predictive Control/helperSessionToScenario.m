function [scenario,egoCar, profiles] = helperSessionToScenario(scenarioFile, addEgoCar)
%   This is a helper for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.

% Do not add egoCar as default 
if nargin < 2
    addEgoCar = false;
end

d = load(scenarioFile);

% Make that the file passed is valid
if ~isfield(d, 'data') || ~isfield(d, 'tag')
    error('File is not a scenario file.')
end
if strcmp(d.tag, 'sensors')
    error('File contains only sensor data');
end
actors  = d.data.ActorSpecifications;
roads   = d.data.RoadSpecifications;
classes = driving.internal.scenarioApp.ClassSpecifications(d.data.ClassSpecifications);
if isempty(actors)
    error('File contains no actors');
end

% Create the scenario
scenario = drivingScenario('SampleTime', d.data.SampleTime);
if strcmp(d.data.StopCondition, 'time')
    scenario.StopTime = d.data.StopTime;
end

% Add the roads
for indx = 1:numel(roads)
    applyToScenario(roads(indx), scenario);
end

% Add the actors
% By default, in the DSD app, actor IDs are in the increasing order of how
% they are defined and cannot be tweaked by user. Preserve this ordering
% when sending back the profiles information.
actorIDs = 1:numel(actors);
for indx = 1:numel(actors)
    if indx == d.data.EgoCarId % Populate initial conditions for egoCar
        egoCar.v0   = d.data.ActorSpecifications(indx).Speed(1);
        egoCar.x0   = d.data.ActorSpecifications(indx).Position(1);
        egoCar.y0   = d.data.ActorSpecifications(indx).Position(2);
        egoCar.yaw0 = deg2rad(d.data.ActorSpecifications(indx).Yaw);
        
        if addEgoCar
            applyToScenario(actors(indx), scenario, classes);
        else
            actorIDs(actorIDs == d.data.EgoCarId) = [];
        end
    else
        applyToScenario(actors(indx), scenario, classes);
    end
end

profiles = actorProfiles(scenario);
for kndx = 1:length(profiles)
    profiles(kndx).ActorID = actorIDs(kndx);
end

% [EOF]
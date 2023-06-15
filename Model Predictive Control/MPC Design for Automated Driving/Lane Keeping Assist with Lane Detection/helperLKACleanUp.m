% Clean up script for the Lane Keep Assist with Lane Detection Example
%
% This script cleans up the LKA example model. It is triggered by the
% CloseFcn callback.
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.

clear blk
clear Cf
clear Cr
clear driverPath
clear egoID
clear egoVehicle
clear Iz
clear LaneSensor
clear LaneSensorBoundaries
clear laneSpecification
clear lf
clear lr
clear m
clear modelName
clear PredictionHorizon
clear roadCenters
clear s
clear scenario
clear simStopTime
clear Ts
clear v0_ego
clear wasModelLoaded
clear x0_ego
clear y0_ego
clear yaw0_ego

clearBuses({...
    'BusActors1',...
    'BusActors1Actors',...
    'BusLaneBoundaries1',...
    'BusLaneBoundaries1LaneBoundar',...
    'BusVision',...
    'BusVisionLaneBoundaries'});

% If ans was created by the model, clean it too
if exist('ans','var') && isstruct(ans) %#ok<NOANS>
    clear ans
end

function clearBuses(buses)
matlabshared.tracking.internal.DynamicBusUtilities.removeDefinition(buses);
end
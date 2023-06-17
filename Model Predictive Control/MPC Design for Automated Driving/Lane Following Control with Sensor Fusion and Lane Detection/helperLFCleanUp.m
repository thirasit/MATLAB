% Clean up script for the Lane Following Test Bench Example
%
% This script cleans up the LF example model. It is triggered by the
% CloseFcn callback.
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019-2020 The MathWorks, Inc.

clearBuses({...
    'BusActors1',...
    'BusActors1Actors',...
    'BusDetectionConcatenation1',...
    'BusDetectionConcatenation1Detect',...
    'BusDetectionConcatenation1DetectionsMeasurementParameters',...
    'BusLaneBoundaries1',...
    'BusLaneBoundaries1LaneBoundaries',...
    'BusLanes',...
    'BusLanesLaneBoundaries',...
    'BusMultiObjectTracker1',...
    'BusMultiObjectTracker1Tracks',...
    'BusRadar',...
    'BusRadarDetections',...
    'BusRadarDetectionsMeasurementParameters',...
    'BusRadarDetectionsObjectAttributes',...
    'BusVision',...
    'BusVisionDetections',...
    'BusVisionDetectionsMeasurementParameters',...
    'BusVisionDetectionsObjectAttributes'});

clear Cf
clear Cr
clear Iz
clear LaneSensor
clear LaneSensorBoundaries
clear M
clear N
clear PredictionHorizon
clear Ts
clear assigThresh
clear default_spacing
clear egoCarID
clear lf
clear logsout
clear lr
clear m
clear max_ac
clear max_steer
clear min_ac
clear min_steer
clear numCoasts
clear numSensors
clear numTracks
clear posSelector
clear scenario
clear simStopTime
clear tau
clear time_gap
clear tout
clear v0_ego
clear v_set
clear velSelector
clear x0_ego
clear y0_ego
clear yaw0_ego

% If ans was created by the model, clean it too
if exist('ans','var') && ischar(ans) && (strcmpi(ans,'BusMultiObjectTracker1')) %#ok<NOANS>
    clear ans
end

function clearBuses(buses)
matlabshared.tracking.internal.DynamicBusUtilities.removeDefinition(buses);
end
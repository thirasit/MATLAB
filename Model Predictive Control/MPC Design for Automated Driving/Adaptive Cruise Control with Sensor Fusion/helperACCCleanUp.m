% Clean up script for the Automatic Cruise Control (ACC) Example
%
% This script cleans up the ACC example model. It is triggered by the
% CloseFcn callback.
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2017 The MathWorks, Inc.

clear assigThresh
clear blk

clearBuses({'BusActors',...
            'BusActorsActors',...
            'BusDetectionConcatenation1',...
            'BusDetectionConcatenation1Detections',...
            'BusDetectionConcatenation1DetectionsMeasurementParameters',...
            'BusMultiObjectTracker1',...
            'BusMultiObjectTracker1Tracks',...
            'BusRadar',...
            'BusRadarDetections',...
            'BusRadarDetectionsMeasurementParameters',...
            'BusRadarDetectionsObjectAttributes',...
            'BusVision',...
            'BusVisionDetections',...
            'BusVisionDetectionsMeasurementParameters',...
            'BusVisionDetectionsObjectAttributes',...
            'BusMultiObjectTracker1'})

clear Cf
clear clusterSize
clear controller_type
clear Cr
clear default_spacing
clear driver_I
clear driver_P
clear G
clear hasMPCLicense
clear Iz
clear lf
clear lr
clear m
clear M
clear max_ac
clear min_ac
clear modelName
clear N
clear numCoasts
clear numSensors
clear numTracks
clear posSelector
clear R
clear refModel
clear s
clear tau
clear time_gap
clear Ts
clear v0_ego
clear v_set
clear velSelector
clear verr_gain
clear vx_gain
clear wasModelLoaded
clear wasReModelLoaded
clear x0_ego
clear xerr_gain
clear y0_ego
clear yawerr_gain

function clearBuses(buses)
matlabshared.tracking.internal.DynamicBusUtilities.removeDefinition(buses);
end

% Clean up script for the Lane Change Assist with NMPC Example
%
% This script cleans up the LC example model. It is triggered by the
% CloseFcn callback.
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.

clearBuses({...
    'BusActors1',...
    'BusActors1Actors',...
    'BusLaneBoundaries1',...
    'BusLaneBoundaries1LaneBoundaries'});

clear actor_Profiles
clear Cf
clear Cr
clear ControlHorizon
clear egoCar
clear Iz
clear lf
clear lr
clear m
clear nlobj
clear out
clear PredictionHorizon
clear scenario
clear scenarioFcnName
clear scenarioFcnNames
clear scenarioFileName
clear scenarioFileNames
clear scenarioId
clear scenarioNames
clear simStopTime
clear tau
clear Ts
clear v0_ego
clear v_set
clear x0_ego
clear y0_ego
clear yaw0_ego
clear stopTime
clear vehiclePoses


function clearBuses(buses)
matlabshared.tracking.internal.DynamicBusUtilities.removeDefinition(buses);
end



function helperSLCreateUtilityBus(varargin) 
% This file is the same as in the "AutomatedParkingValetSimulinkExample".

% helperSLCreateUtilityBus define Simulink buses used in the model.

% Copyright 2017-2019 The MathWorks, Inc.

if nargin == 1
    is3DSimulation = varargin{1};
else
    is3DSimulation = false;
end

% Speed configuration
elemsSpeedConfig(1)                  = Simulink.BusElement;
elemsSpeedConfig(1).Name             = 'StartSpeed';
elemsSpeedConfig(1).Dimensions       = 1;
elemsSpeedConfig(1).DimensionsMode   = 'Fixed';
elemsSpeedConfig(1).DataType         = 'double';
elemsSpeedConfig(1).SampleTime       = -1;
elemsSpeedConfig(1).Complexity       = 'real';

elemsSpeedConfig(2)                  = Simulink.BusElement;
elemsSpeedConfig(2).Name             = 'EndSpeed';
elemsSpeedConfig(2).Dimensions       = 1;
elemsSpeedConfig(2).DimensionsMode   = 'Fixed';
elemsSpeedConfig(2).DataType         = 'double';
elemsSpeedConfig(2).SampleTime       = -1;
elemsSpeedConfig(2).Complexity       = 'real';

elemsSpeedConfig(3)                  = Simulink.BusElement;
elemsSpeedConfig(3).Name             = 'MaxSpeed';
elemsSpeedConfig(3).Dimensions       = 1;
elemsSpeedConfig(3).DimensionsMode   = 'Fixed';
elemsSpeedConfig(3).DataType         = 'double';
elemsSpeedConfig(3).SampleTime       = -1;
elemsSpeedConfig(3).Complexity       = 'real';

speedConfigBus                       = Simulink.Bus;
speedConfigBus.Elements              = elemsSpeedConfig;

% Planner configuration
elemsPlannerConfig(1)                = Simulink.BusElement;
elemsPlannerConfig(1).Name           = 'ConnectionDistance';
elemsPlannerConfig(1).Dimensions     = 1;
elemsPlannerConfig(1).DimensionsMode = 'Fixed';
elemsPlannerConfig(1).DataType       = 'double';
elemsPlannerConfig(1).SampleTime     = -1;
elemsPlannerConfig(1).Complexity     = 'real';

elemsPlannerConfig(2)                = Simulink.BusElement;
elemsPlannerConfig(2).Name           = 'MinIterations';
elemsPlannerConfig(2).Dimensions     = 1;
elemsPlannerConfig(2).DimensionsMode = 'Fixed';
elemsPlannerConfig(2).DataType       = 'double';
elemsPlannerConfig(2).SampleTime     = -1;
elemsPlannerConfig(2).Complexity     = 'real';

elemsPlannerConfig(3)                = Simulink.BusElement;
elemsPlannerConfig(3).Name           = 'GoalTolerance';
elemsPlannerConfig(3).Dimensions     = [1 3];
elemsPlannerConfig(3).DimensionsMode = 'Fixed';
elemsPlannerConfig(3).DataType       = 'double';
elemsPlannerConfig(3).SampleTime     = -1;
elemsPlannerConfig(3).Complexity     = 'real';

elemsPlannerConfig(4)                = Simulink.BusElement;
elemsPlannerConfig(4).Name           = 'MinTurningRadius';
elemsPlannerConfig(4).Dimensions     = 1;
elemsPlannerConfig(4).DimensionsMode = 'Fixed';
elemsPlannerConfig(4).DataType       = 'double';
elemsPlannerConfig(4).SampleTime     = -1;
elemsPlannerConfig(4).Complexity     = 'real';

if is3DSimulation
    elemsPlannerConfig(5)                = Simulink.BusElement;
    elemsPlannerConfig(5).Name           = 'IsParkManeuver';
    elemsPlannerConfig(5).Dimensions     = 1;
    elemsPlannerConfig(5).DimensionsMode = 'Fixed';
    elemsPlannerConfig(5).DataType       = 'boolean';
    elemsPlannerConfig(5).SampleTime     = -1;
    elemsPlannerConfig(5).Complexity     = 'real';
end

plannerConfigBus                     = Simulink.Bus;
plannerConfigBus.Elements            = elemsPlannerConfig;

% Vehicle info 
elemsVehicleInfo(1)                 = Simulink.BusElement;
elemsVehicleInfo(1).Name            = 'CurrPose';
elemsVehicleInfo(1).Dimensions      = [1 3];
elemsVehicleInfo(1).DimensionsMode  = 'Fixed';
elemsVehicleInfo(1).DataType        = 'double';
elemsVehicleInfo(1).SampleTime      = -1;
elemsVehicleInfo(1).Complexity      = 'real';

elemsVehicleInfo(2)                 = Simulink.BusElement;
elemsVehicleInfo(2).Name            = 'CurrVelocity';
elemsVehicleInfo(2).Dimensions      = 1;
elemsVehicleInfo(2).DimensionsMode  = 'Fixed';
elemsVehicleInfo(2).DataType        = 'double';
elemsVehicleInfo(2).SampleTime      = -1;
elemsVehicleInfo(2).Complexity      = 'real';

elemsVehicleInfo(3)                 = Simulink.BusElement;
elemsVehicleInfo(3).Name            = 'CurrYawRate';
elemsVehicleInfo(3).Dimensions      = 1;
elemsVehicleInfo(3).DimensionsMode  = 'Fixed';
elemsVehicleInfo(3).DataType        = 'double';
elemsVehicleInfo(3).SampleTime      = -1;
elemsVehicleInfo(3).Complexity      = 'real';

elemsVehicleInfo(4)                 = Simulink.BusElement;
elemsVehicleInfo(4).Name            = 'CurrSteer';
elemsVehicleInfo(4).Dimensions      = 1;
elemsVehicleInfo(4).DimensionsMode  = 'Fixed';
elemsVehicleInfo(4).DataType        = 'double';
elemsVehicleInfo(4).SampleTime      = -1;
elemsVehicleInfo(4).Complexity      = 'real';

elemsVehicleInfo(5)                 = Simulink.BusElement;
elemsVehicleInfo(5).Name            = 'Direction';
elemsVehicleInfo(5).Dimensions      = 1;
elemsVehicleInfo(5).DimensionsMode  = 'Fixed';
elemsVehicleInfo(5).DataType        = 'double';
elemsVehicleInfo(5).SampleTime      = -1;
elemsVehicleInfo(5).Complexity      = 'real';

if is3DSimulation % Used in 3D Simulation
    elemsVehicleInfo(6)                 = Simulink.BusElement;
    elemsVehicleInfo(6).Name            = 'CurrPoseCenter';
    elemsVehicleInfo(6).Dimensions      = [1 3];
    elemsVehicleInfo(6).DimensionsMode  = 'Fixed';
    elemsVehicleInfo(6).DataType        = 'double';
    elemsVehicleInfo(6).SampleTime      = -1;
    elemsVehicleInfo(6).Complexity      = 'real';
end

vehicleInfoBus                      = Simulink.Bus;
vehicleInfoBus.Elements             = elemsVehicleInfo;

% Costmap configuration
elemsCostmapConfig(1)                  = Simulink.BusElement;
elemsCostmapConfig(1).Name             = 'FreeThreshold';
elemsCostmapConfig(1).Dimensions       = [1 1];
elemsCostmapConfig(1).DimensionsMode   = 'Fixed';
elemsCostmapConfig(1).DataType         = 'double';
elemsCostmapConfig(1).SampleTime       = -1;
elemsCostmapConfig(1).Complexity       = 'real';

elemsCostmapConfig(2)                  = Simulink.BusElement;
elemsCostmapConfig(2).Name             = 'OccupiedThreshold';
elemsCostmapConfig(2).Dimensions       = [1 1];
elemsCostmapConfig(2).DimensionsMode   = 'Fixed';
elemsCostmapConfig(2).DataType         = 'double';
elemsCostmapConfig(2).SampleTime       = -1;
elemsCostmapConfig(2).Complexity       = 'real';

elemsCostmapConfig(3)                  = Simulink.BusElement;
elemsCostmapConfig(3).Name             = 'MapLocation';
elemsCostmapConfig(3).Dimensions       = [1 2];
elemsCostmapConfig(3).DimensionsMode   = 'Fixed';
elemsCostmapConfig(3).DataType         = 'double';
elemsCostmapConfig(3).SampleTime       = -1;
elemsCostmapConfig(3).Complexity       = 'real';

elemsCostmapConfig(4)                  = Simulink.BusElement;
elemsCostmapConfig(4).Name             = 'CellSize';
elemsCostmapConfig(4).Dimensions       = [1 1];
elemsCostmapConfig(4).DimensionsMode   = 'Fixed';
elemsCostmapConfig(4).DataType         = 'double';
elemsCostmapConfig(4).SampleTime       = -1;
elemsCostmapConfig(4).Complexity       = 'real';

elemsCostmapConfig(5)                  = Simulink.BusElement;
elemsCostmapConfig(5).Name             = 'C';
elemsCostmapConfig(5).Dimensions       = [100 150];
elemsCostmapConfig(5).DimensionsMode   = 'Fixed';
elemsCostmapConfig(5).DataType         = 'double';
elemsCostmapConfig(5).SampleTime       = -1;
elemsCostmapConfig(5).Complexity       = 'real';

costmapBus                       = Simulink.Bus;
costmapBus.Elements              = elemsCostmapConfig;

clear elemsCostmapConfig elemsPlannerConfig elemsVehicleInfo;
assignin('base','speedConfigBus',   speedConfigBus);
assignin('base','plannerConfigBus', plannerConfigBus);
assignin('base','vehicleInfoBus',   vehicleInfoBus);
assignin('base','costmapBus',       costmapBus);

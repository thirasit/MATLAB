function output = helperSLCreateUtilityStruct(obj)
% helperSLCreateUtilityStruct create struct from object.
% This file is modified from the "AutomatedParkingValetSimulinkExample".

% Copyright 2019 The MathWorks, Inc.


    
if isa(obj, 'vehicleCostmap')
    
    costmapStruct                   = struct;
    costmapStruct                   = helperSLMatchStructFields(costmapStruct, obj);
    costmapStruct                   = rmfield(costmapStruct, 'CollisionChecker');
    costmapStruct.InflationRadius   = obj.CollisionChecker.InflationRadius;
    costmapStruct.Costs             = getCosts(obj);
    
    vehicleDimsStruct               = struct;
    vehicleDimsStruct               = helperSLMatchStructFields(vehicleDimsStruct, obj.CollisionChecker.VehicleDimensions);
    vehicleDimsStruct.WorldUnits    = uint8(vehicleDimsStruct.WorldUnits);
    output                          = costmapStruct;    
else
    error('Invalid obj data type.');
end



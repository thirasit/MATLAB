function pg = helperVehiclePolyshape(varargin)
% This file is the same as in the "AutomatedParkingValetSimulinkExample".


%helperVehiclePolyshape create a polyshape array for a vehicle.
%
%   PG = helperVehiclePolyshape(vehiclePose, vehicleDims) creates a vehicle
%   with dimensions vehicleDims and located at vehiclePose, as an array of
%   polygons PG. vehiclePose is the pose of the vehicle in world
%   coordinates, specified as [x, y, theta]. Dimensions of the vehicle are
%   specified as vehicleDims, a vehicleDimensions object. PG is an array of
%   polyshape objects.
%
%   PG = helperVehiclePolyshape(vehiclePose, vehicleDims, steer)
%   additionally specifies a steering angle, steer (in degrees), of the
%   front wheels.
%
%   See also vehicleDimensions, polyshape.

% Copyright 2017-2019 The MathWorks, Inc.

[vehiclePose, vehicleDims, steer] = parseInputs(varargin{:});

bodyShape   = createVehicleBody(vehicleDims);
axles       = createVehicleAxles(vehicleDims);
wheels      = createVehicleWheels(vehicleDims, steer);

bodyShape   = moveToPose(bodyShape, vehiclePose);
axles       = moveToPose(axles, vehiclePose);
wheels      = moveToPose(wheels, vehiclePose);

pg = [bodyShape,axles,wheels];
end

%--------------------------------------------------------------------------
function bodyShape = createVehicleBody(vehicleDims)

% Create a polyshape object, with origin at rear-axle.
ro = vehicleDims.RearOverhang;
fo = vehicleDims.FrontOverhang;
wb = vehicleDims.Wheelbase;
hw = vehicleDims.Width/2;

% Create a polyshape object, with origin at rear-axle.
X = [-ro wb+fo wb+fo -ro]';
Y = [-hw   -hw    hw  hw]';
bodyShape = polyshape( X, Y);
end

%--------------------------------------------------------------------------
function axles = createVehicleAxles(vehicleDims)
axleLength = vehicleDims.Length/50;
hw = vehicleDims.Width/2;
wb = vehicleDims.Wheelbase;

% Create a polyshape object for rear and front axles.
X = [-axleLength/2 -axleLength/2 axleLength/2 axleLength/2]';
Y = [-hw hw hw -hw]';
axles  = polyshape(X, Y);
axles(end+1) = axles(1).translate([wb,0]);
end

%--------------------------------------------------------------------------
function wheels = createVehicleWheels(vehicleDims, steer)

wheelLength = vehicleDims.Length/10;
wheelWidth  = vehicleDims.Length/50;
hw = vehicleDims.Width/2;
wb = vehicleDims.Wheelbase;

X = [-wheelLength/2 -wheelLength/2 wheelLength/2 wheelLength/2]';
Y = [-hw-wheelWidth -hw -hw -hw-wheelWidth]';

wheels = polyshape(X,Y);
wheels(end+1) = wheels(1).translate([0,vehicleDims.Width+wheelWidth]);
wheels(end+1) = wheels(1).translate([wb,0]);
wheels(end+1) = wheels(2).translate([wb,0]);
wheels(3) = rotateWheel(wheels(3), steer);
wheels(4) = rotateWheel(wheels(4), steer);
end

%--------------------------------------------------------------------------
function rotWheel = rotateWheel(wheel, angle)
[cx,cy] = centroid(wheel);
rotWheel = rotate(wheel, angle, [cx,cy]);
end

%--------------------------------------------------------------------------
function shape = moveToPose(shape, pose)

shape = rotate( ...
    translate(shape, [pose(1), pose(2)]), pose(3), [pose(1), pose(2)] );
end

%--------------------------------------------------------------------------
function [pose, dims, steer] = parseInputs(varargin)

p = inputParser;
p.FunctionName = mfilename;

p.addRequired('vehiclePose',        @validatePose);
p.addRequired('vehicleDims',        @validateVehicleDimensions);
p.addOptional('steer',          0,  @validateSteer);

p.parse(varargin{:});

res = p.Results;

pose    = res.vehiclePose;
dims    = res.vehicleDims;
steer   = res.steer;
end

%--------------------------------------------------------------------------
function validatePose(pose)
validateattributes(pose, {'single', 'double'}, ...
    {'real', 'row', 'numel', 3, 'finite'}, mfilename, 'vehiclePose');
end

%--------------------------------------------------------------------------
function validateVehicleDimensions(dims)

validateattributes(dims, {'vehicleDimensions'}, {'scalar'}, mfilename, ...
    'vehicleDims');
end

%--------------------------------------------------------------------------
function validateSteer(steer)
validateattributes(steer, {'single','double'}, {'real','scalar','finite'}, ...
    mfilename, 'steer');
end

function pg = helperTruckPolyshape(vehiclePose,vehicleDims,steer)
%helperTruckPolyshape create a polyshape array for a truck with trailer

% Copyright 2021 The MathWorks, Inc.

arguments
    vehiclePose (1,4) double {mustBeNumeric}
    vehicleDims (1,1) struct
    steer (1,1) double {mustBeNumeric}
end

bodyShape = createVehicleBody(vehicleDims ,vehiclePose);
axles = createVehicleAxles(vehicleDims, vehiclePose);
wheels = createVehicleWheels(vehicleDims, steer, vehiclePose);
hitch = createVehicleHitch(vehicleDims);

bodyShape = moveToPose(bodyShape, vehiclePose);
axles = moveToPose(axles, vehiclePose);
wheels = moveToPose(wheels, vehiclePose);
hitch = moveToPose(hitch, vehiclePose);

pg = [bodyShape,axles,wheels,hitch];
end

%--------------------------------------------------------------------------
function bodyShape = createVehicleBody(vehicleDims, vehiclePose)
L1 = vehicleDims.L1;
L2 = vehicleDims.L2;
M1 = vehicleDims.M1;
W1 = vehicleDims.W1;
W2 = vehicleDims.W2;
beta = vehiclePose(4);

% Create a polyshape object for the trailer, with origin at rear-axle.
X = [0 0 L2+M1 L2+M1]';
Y = [W2/2 -W2/2 -W2/2 W2/2]';
bodyShape = polyshape( X, Y);
% Create a polyshape object for the truck
X = [L2 L2 L2+L1+M1 L2+L1+M1]';
Y = [W1/2 -W1/2 -W1/2 W1/2]';
bodyShape(2) = rotate(polyshape( X, Y),beta,[L2,0]);
end

%--------------------------------------------------------------------------
function axles = createVehicleAxles(vehicleDims, vehiclePose)
L1 = vehicleDims.L1;
L2 = vehicleDims.L2;
M1 = vehicleDims.M1;
W1 = vehicleDims.W1;
W2 = vehicleDims.W2;
beta = vehiclePose(4);

% Create a polyshape object for rear and front axles.
X = [-L2/2/50 -L2/2/50 L2/2/50 L2/2/50]';
Y = [W2/2 -W2/2 -W2/2 W2/2]';
axles  = polyshape(X, Y);
X = [L2+M1-L2/2/50 L2+M1-L2/2/50 L2+M1+L2/2/50 L2+M1+L2/2/50]';
Y = [W1/2 -W1/2 -W1/2 W1/2]';
axles(2)  = polyshape(X, Y);
axles(3) = axles(2).translate([L1,0]);
axles(2) = rotate(axles(2),beta,[L2,0]);
axles(3) = rotate(axles(3),beta,[L2,0]);
end

%--------------------------------------------------------------------------
function wheels = createVehicleWheels(vehicleDims, steer, vehiclePose)

wheelLength = vehicleDims.Lwheel;
wheelWidth  = vehicleDims.Wwheel;
L1 = vehicleDims.L1;
L2 = vehicleDims.L2;
M1 = vehicleDims.M1;
W1 = vehicleDims.W1;
W2 = vehicleDims.W2;
beta = vehiclePose(4);

X = [-wheelLength/2 -wheelLength/2 wheelLength/2 wheelLength/2]';
Y = [-W2/2+wheelWidth/2 -W2/2-wheelWidth/2 ...
    -W2/2-wheelWidth/2 -W2/2+wheelWidth/2]';

wheels = polyshape(X,Y);
wheels(2) = wheels(1).translate([0,W2]);

X = [L2+M1-wheelLength/2 L2+M1-wheelLength/2 L2+M1+wheelLength/2 ...
    L2+M1+wheelLength/2]';
Y = [-W1/2+wheelWidth/2 -W1/2-wheelWidth/2 ...
    -W2/2-wheelWidth/2 -W1/2+wheelWidth/2]';
wheels(3) = polyshape(X,Y);
wheels(4) = wheels(3).translate([0,W1]);
wheels(5) = wheels(3).translate([L1,0]);
wheels(6) = wheels(4).translate([L1,0]);
wheels(5) = rotateWheel(wheels(5), steer);
wheels(6) = rotateWheel(wheels(6), steer);

wheels(3) = rotate(wheels(3),beta,[L2,0]);
wheels(4) = rotate(wheels(4),beta,[L2,0]);
wheels(5) = rotate(wheels(5),beta,[L2,0]);
wheels(6) = rotate(wheels(6),beta,[L2,0]);
end

%--------------------------------------------------------------------------
function hitch = createVehicleHitch(vehicleDims)

L2 = vehicleDims.L2;

X = [L2-L2/100 L2-L2/100 L2+L2/100 L2+L2/100];
Y = [L2/100 -L2/100 -L2/100 L2/100];
hitch = polyshape(X,Y);
end

%--------------------------------------------------------------------------
function rotWheel = rotateWheel(wheel, angle)
[cx,cy] = centroid(wheel);
rotWheel = rotate(wheel, angle, [cx,cy]);
end

%--------------------------------------------------------------------------
function shape = moveToPose(shape, pose)

shape = rotate( ...
    translate(shape, [pose(1), pose(2)]), pose(3), ...
    [pose(1), pose(2)] );
end
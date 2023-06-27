function dxdt = parkingVehicleStateFcnRRT(x, u)
% State equations for parking: 
% state variables x, y and yaw angle theta.
% control variables v and steering angle delta.

% Copyright 2019 The MathWorks, Inc.

%%
% Parameters
wb = 2.8;

% Variables
theta = x(3);
v = u(1);
delta = u(2);

% State equations
dxdt = zeros(3,1);
dxdt(1) = v*cos(theta);
dxdt(2) = v*sin(theta);
dxdt(3) = v/wb*tan(delta);

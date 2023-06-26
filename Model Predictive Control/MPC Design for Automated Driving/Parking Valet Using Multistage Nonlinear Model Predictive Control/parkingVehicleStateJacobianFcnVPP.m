function [A, B] = parkingVehicleStateJacobianFcnVPP(x, u)
% Jacobian of model equations for parking.
% state variables x, y and yaw angle theta.
% control variables v and steering angle delta.

% Copyright 2019-2022 The MathWorks, Inc.

%%
% Parameters
wb = 2.8;

% Variables
theta = x(3);
v = u(1);
delta = u(2);

% Linearize the state equations at the current condition
A = zeros(3,3);
B = zeros(3,2);

A(1,3) = -v*sin(theta);
B(1,1) = cos(theta);

A(2,3) = v*cos(theta);
B(2,1) = sin(theta);

B(3,1) = 1/wb*tan(delta);
B(3,2) = 1/wb*(v*(1+tan(delta)^2));

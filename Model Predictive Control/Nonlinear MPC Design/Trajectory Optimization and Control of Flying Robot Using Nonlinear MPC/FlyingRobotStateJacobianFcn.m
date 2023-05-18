function [A, B] = FlyingRobotStateJacobianFcn(x, u)
% Jacobian of model equations for the free-flying robot example.
%
% States:
%   x(1)  x inertial coordinate of center of mass
%   x(2)  y inertial coordinate of center of mass
%   x(3)  theta, thrust direction
%   x(4)  vx, velocity of x
%   x(5)  vy, velocity of y
%   x(6)  omega, angular velocity of theta
%
% Inputs:
%   u(1), u(2), u(3), u(4) are thrusts

% Copyright 2018-2021 The MathWorks, Inc.

% Parameters
alpha = 0.2;
beta  = 0.2;

% Variables
theta = x(3);
T1 = u(1) - u(2);
T2 = u(3) - u(4);

% Linearize the state equations at the current condition
A = zeros(6,6);
A(1,4) = 1;
A(2,5) = 1;
A(3,6) = 1;
A(4,3) = -(T1 + T2)*sin(theta);
A(5,3) =  (T1 + T2)*cos(theta);
B = zeros(6,4);
B(4,:) = cos(theta)*[1 -1 1 -1];
B(5,:) = sin(theta)*[1 -1 1 -1];
B(6,:) = [alpha*[1 -1], -beta*[1 -1]];

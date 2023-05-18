function dxdt = FlyingRobotStateFcn(x, u)
% State equations of the flying robot.
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

% State equations
dxdt = zeros(6,1);
dxdt(1) = x(4);
dxdt(2) = x(5);
dxdt(3) = x(6);
dxdt(4) = (T1 + T2)*cos(theta);
dxdt(5) = (T1 + T2)*sin(theta);
dxdt(6) = alpha*T1 - beta*T2;

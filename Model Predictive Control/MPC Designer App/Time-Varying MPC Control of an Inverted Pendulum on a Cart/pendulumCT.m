function [dxdt, y, A, B, C, D] = pendulumCT(x, u)
%% Continuous-time nonlinear dynamic model of a pendulum on a cart
%
% 4 states (x): 
%   cart position (z)
%   cart velocity (z_dot): when positive, cart moves to right
%   angle (theta): when 0, pendulum is at upright position
%   angular velocity (theta_dot): when positive, pendulum moves anti-clockwisely
% 
% 1 inputs: (u)
%   force (F): when positive, force pushes cart to right 
%
% 4 outputs: (y)
%   same as states (i.e. all the states are measureable)
%
% dxdt is the derivative of the states.
% [A B C D] are state space matrices linearized at the current operating point.
%
% Copyright 2016 The MathWorks, Inc.

%#codegen

%% parameters
mCart = 1;  % cart mass
mPend = 1;  % pendulum mass
g = 9.81;   % gravity of earth
L = 0.5;    % pendulum length
Kd = 10;    % cart damping
%% Obtain x, u and y
% x
z_dot = x(2);
theta = x(3);
theta_dot = x(4);
% u
F = u;
% y
y = x;
%% Compute dxdt
dxdt = x;
% z_dot
dxdt(1) = z_dot;
% z_dot_dot
dxdt(2) = (F - Kd*z_dot - mPend*L*theta_dot^2*sin(theta) + mPend*g*sin(theta)*cos(theta)) / (mCart + mPend*sin(theta)^2);
% theta_dot
dxdt(3) = theta_dot;
% theta_dot_dot
dxdt(4) = ((F - Kd*z_dot - mPend*L*theta_dot^2*sin(theta))*cos(theta)/(mCart + mPend) + g*sin(theta)) / (L - mPend*L*cos(theta)^2/(mCart + mPend));
%% Obtain A/B/C/D from Jacobian
Den = (mCart+sin(theta)^2*mPend);
% used by A
ddx2dx2 = -Kd/Den;
ddx2dx3 = (mPend*(theta_dot^2*L*mPend*cos(theta)-2*g*mCart-g*mPend)*sin(theta)^2-2* ...
    (-(z_dot*Kd-F)*mPend)*cos(theta)*sin(theta)-theta_dot^2*L*mPend*mCart*cos(theta)+g*mPend*mCart)/ ...
    (mPend*sin(theta)^2+mCart)^2;
ddx2dx4 = -2*sin(theta)*L*mPend*theta_dot/Den;
ddx4dx2 = ddx2dx2*cos(theta)/L;
ddx4dx3 = (1/L)*((ddx2dx3 + g)*cos(theta) - dxdt(2)*sin(theta));
ddx4dx4 = ddx2dx4*cos(theta)/L;
% used by B
ddx2du = 1/Den;
ddx4du = ddx2du*cos(theta)/L;
% LTI
A = [0 1 0 0
     0 ddx2dx2 ddx2dx3 ddx2dx4
     0 0 0 1
     0 ddx4dx2 ddx4dx3 ddx4dx4];
B = [0;ddx2du;0;ddx4du];
C = eye(4);
D = zeros(4,1);


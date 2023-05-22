function dxdt = pendulumCT0(x, u)
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
% Copyright 2018 The MathWorks, Inc.

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
%% Compute dxdt
dxdt = [z_dot;...
        (F - Kd*z_dot - mPend*L*theta_dot^2*sin(theta) + mPend*g*sin(theta)*cos(theta)) / (mCart + mPend*sin(theta)^2);...
        theta_dot;...
        ((F - Kd*z_dot - mPend*L*theta_dot^2*sin(theta))*cos(theta)/(mCart + mPend) + g*sin(theta)) / (L - mPend*L*cos(theta)^2/(mCart + mPend))];

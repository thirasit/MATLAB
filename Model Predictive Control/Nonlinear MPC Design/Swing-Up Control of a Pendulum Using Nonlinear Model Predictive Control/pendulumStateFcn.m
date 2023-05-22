function xk1 = pendulumStateFcn(xk, u)
%% Discrete-time nonlinear dynamic model of a pendulum on a cart at time k
%
% 4 states (xk): 
%   cart position (z)
%   cart velocity (z_dot): when positive, cart moves to right
%   angle (theta): when 0, pendulum is at upright position
%   angular velocity (theta_dot): when positive, pendulum moves anti-clockwisely
% 
% 1 inputs: (uk)
%   force (F): when positive, force pushes cart to right 
%
% 4 outputs: (yk)
%   same as states (i.e. all the states are measureable)
%
% xk1 is the states at time k+1.
%
% Copyright 2016 The MathWorks, Inc.

%#codegen

uk = u(1);
Ts = u(2);
xk1 = pendulumDT0(xk, uk, Ts);

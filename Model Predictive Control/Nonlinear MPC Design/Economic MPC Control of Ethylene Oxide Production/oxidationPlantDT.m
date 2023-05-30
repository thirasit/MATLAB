function xk1 = oxidationPlantDT(xk, uk)
%% Discrete-time nonlinear dynamic model of an ethylene oxidation plant at time k
%
% 4 states (x): 
%   Gas density in reactor
%   C2H4 (reactant) concentration in reactor
%   C2H4O (product) concentration in reactor
%   Temperature in reactor
% 
% 3 inputs: (u)
%   C2H4 concentration in the feed (MV)
%   Reactor cooling jacket temperature (MD)
%   C2H4 feed rate (MD)
%
% xk1 is the states at time k+1.

% Copyright 2016-2022 The MathWorks, Inc.

%#codegen

% Repeat application of Euler method sampled at Ts/M.
Ts = 25;
M = Ts/0.01;
delta = Ts/M;
xk1 = xk;
for ct=1:M
    xk1 = xk1 + delta*oxidationPlantCT(xk1,uk);
end
% Note that we choose the Euler method (first order Runge-Kutta method)
% because it is more efficient for plants with nonstiff ODEs. You can
% choose other ODE solvers such as ode23, ode45 for better accuracy or
% ode15s and ode23s for stiff ODEs. These solvers are available from
% MATLAB.

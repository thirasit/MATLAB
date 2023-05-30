function dxdt = oxidationPlantCT(x,u)
%% Continuous-time nonlinear dynamic model of an ethylene oxidation plant
% Oxidation of ethylene (E) to ethylene oxide (EO) occurs in a
% nonisothermal continuously-stirred tank reactor (CSTR).
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
% dxdt is the derivative of the states.
%
% For convenience, all variables in the model are pre-scaled to be
% dimensionless.
%
% EO production rate can be computed as u3/u1*x3*x4.
%
% The ODEs are stiff and a stiff solver should be used for best results.

% Copyright 2017-2022 The MathWorks, Inc.

%% Parameters
gam1 = -8.13;
gam2 = -7.12;
gam3 = -11.07;
A1 = 92.80;
A2 = 12.66;
A3 = 2412.71;
B1 = 7.32;
B2 = 10.39;
B3 = 2170.57;
B4 = 7.02;

%% Kinetic rate expressions
r1 = exp(gam1/x(4))*(x(2)*x(4))^0.5;
r2 = exp(gam2/x(4))*(x(2)*x(4))^0.25;
r3 = exp(gam3/x(4))*(x(3)*x(4))^0.5;

%% ODEs from mass and energy balances
% total volumetric feed flow rate
V = u(3)/u(1); 
dxdt = zeros(4,1);
dxdt(1) = V*(1 - x(1)*x(4));
dxdt(2) = V*(u(1) - x(2)*x(4)) - A1*r1 - A2*r2;
dxdt(3) = -V*x(3)*x(4) + A1*r1 - A3*r3;
dxdt(4) = (V*(1 - x(4)) + B1*r1 + B2*r2 + B3*r3 - B4*(x(4) - u(2)))/x(1);

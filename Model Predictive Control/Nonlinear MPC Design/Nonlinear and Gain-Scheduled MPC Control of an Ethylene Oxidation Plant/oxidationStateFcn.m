function dxdt = oxidationStateFcn(x,u)
%% Continuous-time nonlinear dynamic model of an ethylene oxidation plant
% Oxidation of ethylene to ethylene oxide occurs in a nonisothermal
% continuously-stirred tank reactor (CSTR).
%
% 4 states (x): 
%   Gas density in reactor
%   Ethylene (reactant) concentration in reactor
%   Ethylene oxide (product) concentration in reactor
%   Temperature in reactor
% 
% 2 input: (u)
%   Volumetric feed flow rate
%   Ethylene concentration in the feed flow
%
% 1 output: (y)  
%   Ethylene oxide concentration in the effluent flow (equivalent to x3)
%
% dxdt is the derivative of the states.
%
% For convenience, all variables in the model are pre-scaled to be
% dimensionless.
%
% The oxidation plant is a gas-phase process. Due to the low density, the
% reacting mass contained in the reactor is often negligible relative to
% the feed rate. Therefore, the transient in mass accumulation happens very
% rapidly and it is a good approximation to assume mass feed rate equals
% mass effluent rate at all times.
%
% Copyright 2016-2018 The MathWorks, Inc.

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
Tc = 1.0;

%% Initialization
dxdt = zeros(4,1);

%% Kinetic rate expressions
r1 = exp(gam1/x(4))*(x(2)*x(4))^0.5;
r2 = exp(gam2/x(4))*(x(2)*x(4))^0.25;
r3 = exp(gam3/x(4))*(x(3)*x(4))^0.5;

%% ODEs from mass and energy balances
dxdt(1) = u(1)*(1 - x(1)*x(4));
dxdt(2) = u(1)*(u(2) - x(2)*x(4)) - A1*r1 - A2*r2;
dxdt(3) = -u(1)*x(3)*x(4) + A1*r1 - A3*r3;
dxdt(4) = (u(1)*(1 - x(4)) + B1*r1 + B2*r2 + B3*r3 - B4*(x(4) - Tc))/x(1);

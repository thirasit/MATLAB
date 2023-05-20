function dxdt = exocstrStateFcnCT(x,u)
% Continuous-time state equations for the exothermic CSTR
%
% The states of the CSTR model are:
%
%   x(1) = T        Reactor temperature [K]
%   x(2) = CA       Concentration of A in reactor tank [kgmol/m^3]
%   x(3) = Dist     State of unmeasured output disturbance
%
% The inputs of the CSTR model are:
%
%   u(1) = CA_i     Concentration of A in inlet feed stream [kgmol/m^3]
%   u(2) = T_i      Inlet feed stream temperature [K]
%   u(3) = T_c      Jacket coolant temperature [K]
%   u(4) = WN       White noise

% Copyright 1990-2018 The MathWorks, Inc.

% states
T = x(1);
CA = x(2);
% inputs
CA_i = u(1);
T_i = u(2);
T_c = u(3);
% parameters
FoV = 1;
UA = 0.3;
Hr = -11.92;
k0 = 27944640;      % intentional modeling error with truth of 34930800
EaR = 5894.14;      % intentional modeling error with truth of 5963.6
% state equations
dxdt = zeros(3,1);
k = k0*exp(-EaR/T);
r = k*CA;
dxdt(1) = FoV*(T_i - T) + UA*(T_c - T) - Hr*r;
dxdt(2) = FoV*(CA_i - CA) - r;
dxdt(3) = u(4);
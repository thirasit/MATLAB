function xk1 = exocstrStateFcnDT(xk,uk)
% Discrete-time state equations for the exothermic CSTR with sample time of
% 0.5, using multistep forward Euler integration method
%
% Continuous-time state equations for the exothermic CSTR
%
% The states of the CSTR model are:
%
%   x(1) = T        Reactor temperature [K]
%   x(2) = CA       Concentration of A in reactor tank [kgmol/m^3]
%   x(3) = dist     State of unmeasured output disturbance
%
% The inputs of the CSTR model are:
%
%   u(1) = CA_i     Concentration of A in inlet feed stream [kgmol/m^3]
%   u(2) = T_i      Inlet feed stream temperature [K]
%   u(3) = T_c      Jacket coolant temperature [K]
%
% When calling prediction state function, augment input with u(4) = 0 as
% the white noise input to the unmeasured disturbance channel.

% Copyright 1990-2018 The MathWorks, Inc.

Ts = 0.5;
xk1 = xk(:);
N = 10;  % Number of integration time steps for Euler method
dt = Ts/N;
uk1 = [uk(:);0];
for i = 1:N
    xk1 = xk1 + dt*exocstrStateFcnCT(xk1,uk1);
end
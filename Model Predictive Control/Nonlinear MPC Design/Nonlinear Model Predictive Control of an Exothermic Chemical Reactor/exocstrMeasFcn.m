function y = exocstrMeasFcn(x)
% Output is the reactor concentration plus the unmeasured disturbance
%
% The states of the CSTR model are:
%
%   x(1) = T        Reactor temperature [K]
%   x(2) = CA       Concentration of A in reactor tank [kgmol/m^3]
%   x(3) = Dist     State of unmeasured output disturbance

% Copyright 1990-2018 The MathWorks, Inc.
y = x(2) + x(3);
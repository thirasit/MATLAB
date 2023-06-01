function up = getPassivityInputQuadrupleTank(x,u)
% This is the input function of the passivity constraint for the
% quadruple-tank example. 
%
% Inputs of this function:
%       x: heights of the tanks (4-by-1). 
%       u: flow of the pumps (2-by-1).
% Outputs of this function:
%       up: passivity input.

% Copyright 2022 The MathWorks, Inc.


% equilibrium point
xs = [28.1459,17.8230,18.3991,25.1192]';
us = [37,38]';

% passivity input
deltaU1 = u(1) -us(1);
deltaU2 = u(2) -us(2);

up = [deltaU2;deltaU1];
end
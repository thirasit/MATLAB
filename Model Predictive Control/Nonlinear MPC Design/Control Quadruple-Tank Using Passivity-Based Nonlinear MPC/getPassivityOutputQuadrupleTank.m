function yp = getPassivityOutputQuadrupleTank(x,u)
% This is the output function of the passivity constraint for the
% quadruple-tank example. 
%
% Inputs of this function:
%       x: heights of the tanks (4-by-1). 
%       u: flow of the pumps (2-by-1).
% Outputs of this function:
%       yp: passivity output.

% Copyright 2022 The MathWorks, Inc.

% equilibrium point
xs = [28.1459,17.8230,18.3991,25.1192]';
us = [37,38]';

% passivity output
deltaX3 = x(3) -xs(3);
deltaX4 = x(4) -xs(4);

yp = [deltaX3;deltaX4];
end
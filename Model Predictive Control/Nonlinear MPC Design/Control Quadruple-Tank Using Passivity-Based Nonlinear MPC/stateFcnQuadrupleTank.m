function dxdt = stateFcnQuadrupleTank(x,u)
% This is the state function for quadruple-tank example.  
%
% Inputs of this function:
%       x: heights of the tanks (4-by-1). 
%       u: flow of the pumps (2-by-1).

% Copyright 2022 The MathWorks, Inc.


%% parameters
A1 = 50;
A2 = 50;
A3 = 28;
A4 = 28;
a1 = 0.16;
a2 = 0.2;
a3 = 0.12;
a4 = 0.1;
gamma1 = 0.4;
gamma2 = 0.4;
g = 981;

%% dynamics
fx = zeros(4,1);
fx(1) = -a1/A1*sqrt(2*g*x(1)) + a3/A1*sqrt(2*g*x(3));
fx(2) = -a2/A2*sqrt(2*g*x(2)) + a4/A2*sqrt(2*g*x(4));
fx(3) = -a3/A3*sqrt(2*g*x(3));
fx(4) = -a4/A4*sqrt(2*g*x(4));

gx = zeros(4,2);
gx(1,1) = gamma1/A1;
gx(2,2) = gamma2/A2;
gx(3,2) = (1-gamma2)/A3;
gx(4,1) = (1-gamma1)/A4;

dxdt = fx + gx*u;

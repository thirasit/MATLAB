function y = fedbatch_OutputFcn(x, u)
% Output function for the fed-batch reactor.
%
% The manipulated variables are:
%       u1 = u_B, flow rate of B feed, containing c_Bin mol/L of B
%       u2 = Tsp, reactor temperature target, deg C
%
% The measured disturbance is:
%       u3 = c_Bin, concentration of B in the B feed flow
%
% States are:
%       x1 = V*c_A, mol of A in the reactor
%       x2 = V*(c_A + c_C), mol of A + C in the reactor
%       x3 = V, liquid volume in the reactor
%       x4 = T, reactor temperature, K
%
% Outputs are:
%       y1 = c_C*V, amount of product C in the reactor
%       y2 = q_r, heat removal rate
%       y3 = V, liquid volume in reactor

% Copyright 2018 The MathWorks, Inc.

x1 = x(1);
x2 = x(2);
V  = x(3);
T  = x(4);

c_Bin = u(3);

y = zeros(3,1);

% Parameters
R = 8.31;
V0 = 1;
c_A0 = 10;
c_B0 = 1.167;
k_10 = 4;
k_20 = 800;
E1 = 6e3;
E2 = 20e3;
delH1 = -3e4;
delH2 = -1e4;

% Model equations
k1 = k_10*exp(-E1/(R*T));
k2 = k_20*exp(-E2/(R*T));
c_A = x1/V;
c_B = (1/V)*(c_Bin*V + x1 + V0*(c_B0 - c_A0 - c_Bin));
c_C = (x2 - x1)/V;

y(1) = V*c_C;
y(2) = -V*(delH1*k1*c_A*c_B + delH2*k2*c_C);
y(3) = V;

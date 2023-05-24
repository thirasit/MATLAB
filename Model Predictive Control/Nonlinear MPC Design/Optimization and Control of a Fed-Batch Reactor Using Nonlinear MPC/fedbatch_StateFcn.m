function dxdt = fedbatch_StateFcn(x, u)
% ODE model representing a well-mixed fed-batch reactor as descrubed in
% B. Srinivasan et al., Computers & Chemical Engineering, Vol. 27, pp.
% 1-26, 2003 (see Section 6.4).
%
% Reactions are:
%       A + B => C => D
% where C is the desired product.  Reactions are exothermic and first-order
% in the reactants. Reactor design allows its temperature to be adjusted
% rapidly (but not instantaneously, as assumed in the above paper).
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
%
% Note that: (1) the authors define four states (concentrations of A, B and
% C and liquid volume in the reactor) and show that these reduce to three
% independent state equations; (2) the heat removal rate, y2, is a
% nonlinear function of the states and the reactor temperature.  To prevent
% y2 from being affected instantaneously by an MV, which violates NLMPC and
% MPC requirements, we instead assume that reactor temperature is
% controlled by feedback such that it adjusts rapidly (but not
% instantaneously) to changes in temperature setpoint, MV(2).  The reator
% temperature becomes the 4th state.  

% Copyright 2018 The MathWorks, Inc.

% Initialize variables
x1 = x(1);
x2 = x(2);
V = x(3);
T  = x(4);

u_B = u(1);
Tsp = u(2) + 273.15; % Reactor temperature setpoint
c_Bin = u(3);

dxdt = zeros(4,1);

% Parameters
R = 8.31;
V0 = 1;
c_A0 = 10;
c_B0 = 1.167;
k_10 = 4;
k_20 = 800;
E1 = 6e3;
E2 = 20e3;


% Model equations
k1 = k_10*exp(-E1/(R*T));
k2 = k_20*exp(-E2/(R*T));
c_B = (1/V)*(c_Bin*V + x1 + V0*(c_B0 - c_A0 - c_Bin));

dxdt(1) = -k1*x1*c_B;
dxdt(2) =  k2*(x1 - x2);
dxdt(3) = u_B;
dxdt(4) = 1000*(Tsp - T);  % Fast adjustment of reactor temperature

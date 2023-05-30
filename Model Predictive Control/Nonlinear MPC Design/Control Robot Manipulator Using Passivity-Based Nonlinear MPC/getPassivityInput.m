function u = getPassivityInput(x,tau)
% This is the input function of the passivity constraint for the
% two-link robot manipulator example. 
%
% Inputs of this function:
%       x: joint angles and velocities. 
%       tau: torque.
% Outputs of this function:
%       u: passivity input.

% Copyright 2022 The MathWorks, Inc.

%%

% States
q1 = x(1);
q2 = x(2);
q1dot = x(3);
q2dot = x(4);
% Desired states
qd = [1;1;0;0];
% Error gain
K = 5;

% Model parameters
I2 = 7/12;
m1 = 11;
m2 = 7;
l1 = 1;
l2 = 1;
lc1 = 0.5;
lc2 = 0.5;
I1 = 11/12;
g = 9.81;

% Relation u = g(tau,x)
G = zeros(2,1);
G(1) = m1*lc1*g*cos(q1) + m2*g*(l2*cos(q1+q2)+l1*cos(q1));
G(2) = m2*lc2*g*cos(q1+q2);

err = zeros(2,1);
err(1) = x(1) - qd(1);
err(2) = x(2) - qd(2);

u = tau - G + K*err;
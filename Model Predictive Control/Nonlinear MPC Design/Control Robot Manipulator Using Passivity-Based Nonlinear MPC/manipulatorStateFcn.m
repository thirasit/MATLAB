function dxdt = manipulatorStateFcn(x,tau)
% State-space function for the two-link robot manipulator example. The
% states x are joint angles and velocities. The control input is the torque
% tau.

% Copyright 2021-2022 The MathWorks, Inc.

%%

% States
q1 = x(1);
q2 = x(2);
q1dot = x(3);
q2dot = x(4);

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

% Model matrices
H = zeros(2,2);
H(1,1) = m1*lc1^2 + I1 + m2*(l1^2+lc2^2+2*l1*lc2*cos(q2)) + I2;
H(1,2) = m2*l1*lc2*cos(q2) + m2*lc2^2 + I2;
H(2,1) = H(1,2);
H(2,2) = m2*lc2^2 + I2;

h = m2*l1*lc2*sin(q2);
C = zeros(2,2);
C(1,1) = -h*q2dot;
C(1,2) = -h*q1dot - h*q2dot;
C(2,1) = h*q1dot;


G = zeros(2,1);
G(1) = m1*lc1*g*cos(q1) + m2*g*(l2*cos(q1+q2)+l1*cos(q1));
G(2) = m2*lc2*g*cos(q1+q2);

% Model equation
qddot = H\(tau-C*[q1dot;q2dot]-G);

dxdt = zeros(4,1);
dxdt(1) = q1dot;
dxdt(2) = q2dot;
dxdt(3:4) = qddot;




 
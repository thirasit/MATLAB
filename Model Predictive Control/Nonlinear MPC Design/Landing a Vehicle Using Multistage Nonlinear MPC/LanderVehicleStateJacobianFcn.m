function [A, B] = LanderVehicleStateJacobianFcn(x,u)
% In a 2D environment with standard XY axis, the vehicle is a circular disc
% (20 meters in diamater).  Two thrusts are to the left and right of the
% center.  Tilting (theta) is defined as positive to left and negative to
% the right (0 means robot is vertical).
%
% x: (1) x position of the center of gravity in m
%    (2) y position of the center of gravity in m
%    (3) theta (tilt with respect to the center of gravity) in radian
%    (4) dxdt
%    (5) dydt
%    (6) dthetadt
%
% u: (1) thrust on the left, in Newton
%    (2) thrust on the right, in Newton
%
% The continuous-time model is valid only if the vehicle above or at the
% ground (y>=10).

% Copyright 2023 The MathWorks, Inc.

% mass of vehicle (kg)
m = 1;
% center of gravity to top/bottom end (m)
L1 = 10;
% center of gravity to left/right thrust (m)
L2 =  5;      
% gravity (m/s^2)
g = 9.806;
% inertia for a flat disk
I = 0.5*m*L1^2;
% get force and torgue
Tfwd   = u(2) + u(1);
Ttwist = u(2) - u(1);
% treat as "falling" mass
A = [0 0 0 1 0 0
     0 0 0 0 1 0
     0 0 0 0 0 1
     0 0 -cos(x(3))*Tfwd/m 0 0 0
     0 0 -sin(x(3))*Tfwd/m 0 0 0
     0 0 0 0 0 0
    ];
B = [0 0
     0 0
     0 0
     -sin(x(3))/m -sin(x(3))/m
     cos(x(3))/m cos(x(3))/m
     -L2/I L2/I
    ];
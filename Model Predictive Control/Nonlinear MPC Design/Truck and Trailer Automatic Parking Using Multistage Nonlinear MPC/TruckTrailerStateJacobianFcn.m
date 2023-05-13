function [A, B] = TruckTrailerStateJacobianFcn(x, u, p)
% Jacobian of the truck with one semi-trailer dynamic system:
%
% Truck with one semi-trailer dynamic system:
%
%   States:
%       1: x (center of the trailer's rear axle, global x position)
%       2: y (center of the trailer's rear axle, global y position)
%       3: theta (trailer orientation, global angle, 0 = east)
%       4: beta (truck orientation with respect to trailer, 0 = aligned)
%
%   Inputs:
%       1: alpha (truck steering angle)
%       2: v (truck longitudinal velocity)
%
%   Parameters:
%       p(1): M (hitch length)
%       p(2): L1 (truck length)
%       p(3): L2 (trailer length)
%
%   Units: length/position in "m", velocity in "m/s" and angle in "radian".
%
%   All angles are set positive counter-clockwise.
%
%   It returns A and B such that "dxdt = Ax + Bu" is the linearized plant
%   at {x, u}.

% Copyright 2020-2023 The MathWorks, Inc.

%#codegen
theta = x(3);  
beta = x(4);
alpha = u(1);
v = u(2);
M = p(1);
L1 = p(2);
L2 = p(3);
% Linearize the state equations at the current condition
A = zeros(4,4);
B = zeros(4,2);
A(1,3) = v*cos(beta)*(1 + M/L1*tan(beta)*tan(alpha))*(-sin(theta));
A(1,4) = v*(-sin(beta) + M/L1*cos(beta)*tan(alpha))*cos(theta);
A(2,3) = v*cos(beta)*(1 + M/L1*tan(beta)*tan(alpha))*cos(theta);
A(2,4) = v*(-sin(beta) + M/L1*cos(beta)*tan(alpha))*sin(theta);
A(3,4) = v*(cos(beta)/L2 + M/L1/L2*sin(beta)*tan(alpha));
A(4,4) = v*(-cos(beta)/L2 - M/L1/L2*sin(beta)*tan(alpha));
B(1,1) = v*cos(beta)*M/L1*tan(beta)/cos(alpha)^2*cos(theta);
B(2,1) = v*cos(beta)*M/L1*tan(beta)/cos(alpha)^2*sin(theta);
B(3,1) = v*(-M/L1/L2*cos(beta)/cos(alpha)^2);
B(4,1) = v*(1/cos(alpha)^2/L1 + M/L1/L2*cos(beta)/cos(alpha)^2);
B(1,2) = cos(beta)*(1 + M/L1*tan(beta)*tan(alpha))*cos(theta);
B(2,2) = cos(beta)*(1 + M/L1*tan(beta)*tan(alpha))*sin(theta);
B(3,2) = sin(beta)/L2 - M/L1/L2*cos(beta)*tan(alpha);
B(4,2) = tan(alpha)/L1 - sin(beta)/L2 + M/L1/L2*cos(beta)*tan(alpha);

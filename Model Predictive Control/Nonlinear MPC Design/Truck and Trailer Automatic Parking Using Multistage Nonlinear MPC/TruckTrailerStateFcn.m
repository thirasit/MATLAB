function dxdt = TruckTrailerStateFcn(x,u,p)
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

% Copyright 2020-2023 The MathWorks, Inc.

%#codegen
theta = x(3);  
beta = x(4);
alpha = u(1);
v = u(2);
M = p(1);
L1 = p(2);
L2 = p(3);
dxdt = zeros(4,1);
dxdt(1) = v*cos(beta)*(1 + M/L1*tan(beta)*tan(alpha))*cos(theta);
dxdt(2) = v*cos(beta)*(1 + M/L1*tan(beta)*tan(alpha))*sin(theta);
dxdt(3) = v*(sin(beta)/L2 - M/L1/L2*cos(beta)*tan(alpha));
dxdt(4) = v*(tan(alpha)/L1 - sin(beta)/L2 + M/L1/L2*cos(beta)*tan(alpha));
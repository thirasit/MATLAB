function [A,B] = stateJacobianFcnTruck(x,u,p)
% This is the state Jacobian function for parking of the truck-trailer
% system example.
%
%   States:
%       x(1): x2 (center of trailer end, global x position)
%       x(2): y2 (center of trailer end, global y position)
%       x(3): theta2 (trailer orientation, global angle, 0 = east)
%       x(4): beta2 (truck orientation in terms of trailer, 0 = aligned)
%
%   Inputs:
%       u(1): alpha (truck steering angle)
%       u(2): v (truck longitudinal velocity)
%
%   Parameters:
%       M1: hitch length
%       L1: truck length
%       L2: trailer length
%
%   Units: length/position/velocity in meters and angle in radians
%
%   All angles are set positive counterclockwise.

% Copyright 2021 The MathWorks, Inc.

%%
theta2 = x(3);  
beta2 = x(4);
alpha = u(1);
v = u(2);
M1 = p(1);
L1 = p(2);
L2 = p(3);

% Linearize the state equations at the current condition.
A = zeros(4,4);
B = zeros(4,2);
A(1,3) = v*cos(beta2)*(1 + M1/L1*tan(beta2)*tan(alpha))*(-sin(theta2));
A(1,4) = v*(-sin(beta2) + M1/L1*cos(beta2)*tan(alpha))*cos(theta2);
A(2,3) = v*cos(beta2)*(1 + M1/L1*tan(beta2)*tan(alpha))*cos(theta2);
A(2,4) = v*(-sin(beta2) + M1/L1*cos(beta2)*tan(alpha))*sin(theta2);
A(3,4) = v*(cos(beta2)/L2 + M1/L1/L2*sin(beta2)*tan(alpha));
A(4,4) = v*(-cos(beta2)/L2 - M1/L1/L2*sin(beta2)*tan(alpha));
B(1,1) = v*cos(beta2)*M1/L1*tan(beta2)/cos(alpha)^2*cos(theta2);
B(2,1) = v*cos(beta2)*M1/L1*tan(beta2)/cos(alpha)^2*sin(theta2);
B(3,1) = v*(-M1/L1/L2*cos(beta2)/cos(alpha)^2);
B(4,1) = v*(1/cos(alpha)^2/L1 + M1/L1/L2*cos(beta2)/cos(alpha)^2);
B(1,2) = cos(beta2)*(1 + M1/L1*tan(beta2)*tan(alpha))*cos(theta2);
B(2,2) = cos(beta2)*(1 + M1/L1*tan(beta2)*tan(alpha))*sin(theta2);
B(3,2) = sin(beta2)/L2 - M1/L1/L2*cos(beta2)*tan(alpha);
B(4,2) = tan(alpha)/L1 - sin(beta2)/L2 + M1/L1/L2*cos(beta2)*tan(alpha);



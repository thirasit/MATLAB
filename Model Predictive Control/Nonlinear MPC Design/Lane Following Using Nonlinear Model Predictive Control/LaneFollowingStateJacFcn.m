function [A,B] = LaneFollowingStateJacFcn(x,u)
% This function calculates the Jacobian of the state equations for the
% augmented model. This Jacobian is used by the nlmpc object to improve
% its efficiency.
%
% Inputs:
%           x: current state values
%           u: current input values
% Outputs:
%           A: nx-by-nx matrix which contains the jacobian of states wrt 'x'
%           B: nx-by-nu matrix which contains the jacobian of states wrt 'u'
%
% Measured and unmeasured disturbances do not contribute to B because they
% are not optimization variables. 

% Copyright 2018 The MathWorks, Inc.

%#codegen

%% Vehicle Parameters
m = 1575;   % Mass of car
Iz = 2875;  % Moment of inertia about Z axis
lf = 1.2;   % Distance between Center of Gravity and Front axle 
lr = 1.6;   % Distance between Center of Gravity and Rear axle
Cf = 19000; % Cornering stiffness of the front tires (N/rad)
Cr = 33000; % Cornering stiffness of the rear tires (N/rad).
tau = 0.2;  % Time constant

a1 = -(2*Cf+2*Cr)/m/x(3);
a2 = -(2*Cf*lf-2*Cr*lr)/m/x(3) - x(3);
a3 = -(2*Cf*lf-2*Cr*lr)/Iz/x(3);
a4 = -(2*Cf*lf^2+2*Cr*lr^2)/Iz/x(3);
b1 = 2*Cf/m;
b2 = 2*Cf*lf/Iz;

%% Jacobian Equations
A = zeros(7,7);

A(1,1) = a1; %dx1dot/dx1
A(1,2) = a2; %dx1dot/dx2
A(1,3) =  ((2*Cf+2*Cr)/m/(x(3)^2))*x(1) + (((2*Cf*lf-2*Cr*lr)/m/(x(3)^2))-1)*x(2); %dx1dot/dx3

A(2,1) = a3; %dx2dot/dx1
A(2,2) = a4; %dx2dot/dx2
A(2,3) = ((2*Cf*lf-2*Cr*lr)/Iz/(x(3)^2))*x(1) + ((2*Cf*lf^2+2*Cr*lr^2)/Iz/(x(3)^2))*x(2); %dx2dot/dx3

A(3,1) = x(2); %dx3dot/d1
A(3,2) = x(1); %dx3dot/dx2
A(3,4) = 1;    %dx3dot/dx4

A(4,4) = -1/tau; %dx4dot/dx4

A(5,1) = 1;    %dx5dot/dx1
A(5,3) = x(6); %dx5dot/dx3
A(5,6) = x(3); %dx5dot/dx6

A(6,2) = 1;     %dx6dot/dx2
A(6,3) = 0; %dx6dot/dx3

B = zeros(7,2);

B(1,2) = b1; %dx1dot/du2

B(2,2) = b2; %dx2dot/du2

B(4,1) = 1/tau; %dx4dot/du1

end


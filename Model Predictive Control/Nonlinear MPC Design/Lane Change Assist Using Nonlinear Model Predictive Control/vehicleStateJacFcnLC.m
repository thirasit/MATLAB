function [A,B] = vehicleStateJacFcnLC(x,~)
% This function calculates the Jacobian of the state equations for the
% augmented model. This Jacobian is used by the nlmpc object to improve
% its efficiency.
%
% Inputs:
%        x: current state values
%
% Outputs:
%        A: nx-by-nx matrix which contains the jacobian of states wrt 'x'
%        B: nx-by-nu matrix which contains the jacobian of states wrt 'u'
%
% Measured and unmeasured disturbances do not contribute to B because they
% are not optimization variables.

%   This is a helper function for example purposes and may be removed or
%   modified in the future.

% Copyright 2019 The MathWorks, Inc.

%#codegen

% States x = [  lateral velocity (Vy)
%               yaw rate (psi_dot)
%               global X (X)
%               global Y (Y)
%               yaw angle (psi)];
%
% Inputs u = [  steering angle];

%% Vehicle Parameters
m = 1575;   % Mass of car
Iz = 2875;  % Moment of inertia about Z axis
lf = 1.2;   % Distance between Center of Gravity and Front axle
lr = 1.6;   % Distance between Center of Gravity and Rear axle
Cf = 19000; % Cornering stiffness of the front tires (N/rad)
Cr = 33000; % Cornering stiffness of the rear tires (N/rad).
Vx = 15;

a1 = -(2*Cf+2*Cr)/m/Vx;
a2 = -(2*Cf*lf-2*Cr*lr)/m/Vx - Vx;
a3 = -(2*Cf*lf-2*Cr*lr)/Iz/Vx;
a4 = -(2*Cf*lf^2+2*Cr*lr^2)/Iz/Vx;
b1 = 2*Cf/m;
b2 = 2*Cf*lf/Iz;

%% Jacobian Equations
A = zeros(5,5);

A(1,1) = a1; %dx1dot/dx1
A(1,2) = a2; %dx1dot/dx2

A(2,1) = a3; %dx2dot/dx1
A(2,2) = a4; %dx2dot/dx2

A(3,1) = -sin(x(5));    %dx3dot/dx1
A(3,5) = -Vx*sin(x(5)) - x(1)*cos(x(5)); %dx3dot/dx5

A(4,1) = cos(x(5));     %dx4dot/dx1
A(4,5) = Vx*cos(x(5)) - x(1)*sin(x(5)); %dx4dot/dx5

A(5,2) = 1; %dx5dot/dx2

B = zeros(5,1);

B(1) = b1; %dx1dot/du1

B(2) = b2; %dx2dot/du1

end


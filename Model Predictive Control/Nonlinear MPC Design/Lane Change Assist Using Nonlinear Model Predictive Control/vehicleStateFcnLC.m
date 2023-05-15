function dxdt = vehicleStateFcnLC(x,u)
% This function represents the state derivative equation for the augmented
% vehicle dynamics model.
%
% States x = [  lateral velocity (Vy)
%               yaw rate (psi_dot)
%               global X (X)
%               global Y (Y)
%               yaw angle (psi)];
%
% Inputs u = [  steering angle];
%
% Outputs:
%     dxdt = state derivatives

%   This is a helper function for example purposes and may be removed or
%   modified in the future.

% Copyright 2019 The MathWorks, Inc.

%#codegen

%% Vehicle Parameters
m = 1575;   % Mass of car
Iz = 2875;  % Moment of inertia about Z axis
lf = 1.2;   % Distance between Center of Gravity and Front axle
lr = 1.6;   % Distance between Center of Gravity and Rear axle
Cf = 19000; % Cornering stiffness of the front tires (N/rad)
Cr = 33000; % Cornering stiffness of the rear tires (N/rad).
Vx = 15;

%% State Equations
a1 = -(2*Cf+2*Cr)/m/Vx;
a2 = -(2*Cf*lf-2*Cr*lr)/m/Vx - Vx;
a3 = -(2*Cf*lf-2*Cr*lr)/Iz/Vx;
a4 = -(2*Cf*lf^2+2*Cr*lr^2)/Iz/Vx;
b1 = 2*Cf/m;
b2 = 2*Cf*lf/Iz;
dxdt = x;
dxdt(1) = a1*x(1) + a2*x(2) + b1*u;      % Vy
dxdt(2) = a3*x(1) + a4*x(2) + b2*u;      % psi_dot
dxdt(3) = Vx*cos(x(5)) - x(1)*sin(x(5)); % X
dxdt(4) = Vx*sin(x(5)) + x(1)*cos(x(5)); % Y
dxdt(5) = x(2);                          % psi

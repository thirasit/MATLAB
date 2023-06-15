function dxdt = LaneFollowingStateFcn(x,u)
% This function represents the state derivative equation for the augmented
% vehicle dynamics model.  
%
% States x = [  lateral velocity (Vy)
%               yaw rate (psi_dot)
%               longitudinal velocity (Vx)
%               longitudinal acceleration (Vx_dot)
%               lateral deviation (e1)
%               relative yaw angle (e2)
%               output disturbance of relative yaw angle (xOD)];
%
% Inputs u = [  acceleration
%               steering angle
%               road curvature * Vx (measured disturbance)
%               white noise (unmeasured disturbance)];
% Outputs:
%     dxdt = state derivatives

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

%% State Equations
a1 = -(2*Cf+2*Cr)/m/x(3); 
a2 = -(2*Cf*lf-2*Cr*lr)/m/x(3) - x(3);
a3 = -(2*Cf*lf-2*Cr*lr)/Iz/x(3);
a4 = -(2*Cf*lf^2+2*Cr*lr^2)/Iz/x(3);
b1 = 2*Cf/m;
b2 = 2*Cf*lf/Iz;
dxdt = x;
dxdt(1) = a1*x(1) + a2*x(2) + b1*u(2);  % Vy
dxdt(2) = a3*x(1) + a4*x(2) + b2*u(2);  % psi_dot
dxdt(3) = x(2)*x(1) + x(4);             % Vx
dxdt(4) = (1/tau)*(-x(4) + u(1));       % Vx_dot
dxdt(5) = x(1) + x(3)*x(6);             % e1
dxdt(6) = x(2) - u(3);                  % e2
dxdt(7) = u(4);                         % xOD

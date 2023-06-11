function G = helperACCLinearModel(m,Iz,lf,lr,Cf,Cr,tau,v0_ego)
% Linear model for demo "Adaptive Cruise Control with Sensor Fusion"

% Copyright 2017-2018 The MathWorks, Inc. 

%% Ego Car Parameters
% Dynamics modeling parameters defined in helperACCSetUp
% m        Total mass of vehicle                          (kg)
% Iz       Yaw moment of inertia of vehicle               (m*N*s^2)
% lf       Longitudinal distance from c.g. to front tires (m)
% lr       Longitudinal distance from c.g. to rear tires  (m)
% Cf       Cornering stiffness of front tires             (N/rad)
% Cr       Cornering stiffness of rear tires              (N/rad)
% tau      Longitudinal time constant                     (N/A)
% v0_ego   Initial speed of the ego car                   (m/s)

%% Vehicle Model
% States: x = [Vy,Phi,Phidot,Vx,Vxdot]
%   x1: Vy      -- vehicle lateral velocity
%   x2: Phi     -- vehicle yaw angle
%   x3: Phidot  -- vehicle yaw angle rate
%   x4: Vx      -- vehicle longitudinal velocity
%   x5: Vxdot   -- vehicle longitudinal acceleration from actuators
% Inputs: [delta, u]
%   delta       -- vehicle front steering angle
%   u           -- required vehicle longitudinal acceleration

% Note: Vehicle model is given by 
%       xdot = A*x + B1*delta + B2*u + x1*x3,
% with initial conditions 
%       x1, x2, x3, x5 = 0 and x4 = v0_ego. 
% The linear model is given by xdot = A*x + B1*delta + B2*u.

% System matrices
A = [-(2*Cf+2*Cr)/m/v0_ego,0,-v0_ego-(2*Cf*lf-2*Cr*lr)/m/v0_ego,0,0;...
     0,0,1,0,0;...
     -(2*Cf*lf-2*Cr*lr)/Iz/v0_ego,0,-(2*Cf*lf^2+2*Cr*lr^2)/Iz/v0_ego,0,0;...
     0,0,0,0,1;...
     0,0,0,0,-1/tau];
% B1 = [2*Cf/m,0,2*Cf*lf/Iz,0,0]';   
B2 = [0,0,0,0,1/tau]';

%% Linear Model for ACC design
% Input:  u (required longitudinal acceleration) 
% Output: x4(longitudinal velocity)
C = [0,0,0,1,0];
G = minreal(ss(A,B2,C,0));




 
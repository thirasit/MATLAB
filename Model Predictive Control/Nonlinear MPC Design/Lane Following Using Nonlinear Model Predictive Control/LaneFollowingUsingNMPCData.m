% Set up Script for the Lane Following with Nonlinear Model predictive
% Control Example
%
% This script initializes the lane following example model. It loads
% necessary Vehicle Dynamics and Road Curvature parameters.
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2018 The MathWorks, Inc.

%% Parameters of Vehicle Dynamics and Road Curvature. 
% Specify the vehicle dynamics parameters
m = 1575;   % Mass of car
Iz = 2875;  % Moment of inertia about Z axis
lf = 1.2;   % Distance between Center of Gravity and Front axle 
lr = 1.6;   % Distance between Center of Gravity and Rear axle
Cf = 19000; % Cornering stiffness of the front tires (N/rad)
Cr = 33000; % Cornering stiffness of the rear tires (N/rad).
tau = 0.2;  % Time constant

%%
% Set the initial and driver-set velocities.
v0 = 15;    % Initial velocity
v_set = 20; % Driver set velocity

%%
% Set the controller sample time.
Ts = 0.1;

%%
% Obtain the lane curvature information.
% seconds.
Duration = 15;                              % Simulation duration
t = 0:Ts:Duration;                          % Time vector
rho = LaneFollowingGetCurvature(v_set,t);   % Signal containing curvature information

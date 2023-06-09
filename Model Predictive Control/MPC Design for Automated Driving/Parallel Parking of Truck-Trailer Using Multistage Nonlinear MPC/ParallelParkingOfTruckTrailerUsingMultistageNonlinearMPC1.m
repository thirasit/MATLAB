%% Parallel Parking of Truck-Trailer Using Multistage Nonlinear MPC
% This example shows how to parallel park a truck-trailer system using multistage nonlinear model predictive control (NLMPC).

% In the application scenario for this example, the truck-trailer system (ego vehicle) is driving at a parking garage.
% When a parking spot is located, a nonlinear MPC planner generates a parking path.
% Then, the ego vehicle follows the planned path to the target pose using another nonlinear MPC controller.

%%% Parking Environment
% The parking environment contains a truck-trailer system (ego vehicle) and static obstacles.
% The goal of the ego vehicle is to park at a target pose without colliding with the obstacles.
% The reference point of the ego vehicle pose is located at the center of the rear axle.
% The ego vehicle dynamics and parameters match the parameters in the Truck and Trailer Automatic Parking Using Multistage Nonlinear MPC example.

% Load the parameters of the ego vehicle.
load truckDimensions.mat

% Specify the initial ego vehicle pose and target parking pose.
% Ego initial pose: x(m), y(m), trailer yaw angle (rad), 
% and yaw angle error between truck and trailer
initialPose1 = [-15,-30,pi/2,0]';
targetPose2 = [-8,-8,pi/2,0]';

% Visualize the parking environment with steering angle equal to zero using the helperSLVisualizeParkingTruck helper function.
helperSLVisualizeParkingTruck(initialPose1,0,truckDimensions);

%%% Simulink Model
% Open the Simulink® model.
mdl = 'truckParallelParking';
open_system(mdl)

figure
imshow("ParallelParkingOfTruckTrailerUsingMultistageNonlinearMPCExample_02.png")
axis off;

% The model contains four major components.
% - Decision Logic subsystem — Selects when to execute each of the three control modes: driving, planning, parking. For this example, the decision logic is time-based.
% - Control Commands — Outputs the control commands (steering angle and velocity) based on the selected control mode.
% - Truck Trailer System subsystem — Models the truck-trailer system.
% - Parking Visualizer subsystem — Visualizes the simulation results using animation and scopes.

% Open the path planner system.
open_system([mdl '/Planning/Path Planner'])

figure
imshow("ParallelParkingOfTruckTrailerUsingMultistageNonlinearMPCExample_03.png")
axis off;

% The path planner is designed using multistage NLMPC. The path planner requires the following information.
% - Initial pose of ego vehicle
% - Target pose of ego vehicle
% - Model parameters for ego vehicle
% - Obstacle parameters
% - Initial guess for the NLMPC controller

% The path generated from the path planner is transformed to a trajectory for the parking controller.
% The parking controller is designed using NLMPC.

%%% Path Planner and Trajectory-Tracking Controller
% In this example, the obstacle information is represented by two parameters: wall length and wall width.
wallLength = 20;
wallWidth = 10;

% The path planner takes obstacle information into account and generates a collision-free path for the ego vehicle.
% For more details on how to use multistage NLMPC for planning, see Truck and Trailer Automatic Parking Using Multistage Nonlinear MPC.

% To create the path-planning NLMPC controller, use the mpcGeneratePlanner helper function.
planner = mpcGeneratePlanner(truckDimensions,wallLength,wallWidth);

planningObj = planner.mpcobj; % MPC object for planning
pPlanning = planner.horizon;  % Prediction horizon
Tsplan = planner.sampleTime;  % Sample time

%%% Trajectory-Tracking Controller
% The goal for the trajectory-tracking controller is to closely track the trajectory from the path planner and guide the ego vehicle to the target parking location.
% For more details on how to use NLMPC for parking of a sedan vehicle, see Parallel Parking Using Nonlinear Model Predictive Control.

% To create the trajectory-tracking controller, use the mpcGenerateTracker helper function.
controller = mpcGenerateTracker(truckDimensions);

trackingObj = controller.mpcobj; % MPC object for tracking
pTracking = controller.horizon;  % Prediction horizon
Ts = controller.sampleTime;      % Sample time

%%% Simulate Model
% To run the Simulink model, configure the following parameters.
tmin = 2.5;           % Start time for planning
tmax = tmin + Tsplan; % End time for planning (at least one sample time)
Duration = 30;        % Simulation time
mdlParas = [truckDimensions.M1;truckDimensions.L1;truckDimensions.L2;...
            truckDimensions.W1;truckDimensions.W2]; % Truck information
obsParas = [wallLength;wallWidth];                  % Obstacle information
numParas = numel(mdlParas) + numel(obsParas);

% To pass the ego vehicle parameters to the tracking controller, you must create a parameter bus object.
parasTracking = {mdlParas(1:3)};
blk = [mdl '/Parking/tracking/Nonlinear MPC Controller'];
createParameterBus(trackingObj,blk,'parasBusObject',parasTracking);

% Simulate the model.
sim(mdl);

% The animation shows that the ego vehicle parks at the target pose successfully without any obstacle collisions.
% You can also view the ego vehicle and pose trajectories using the scopes in the Parking Visualizer subsystem.

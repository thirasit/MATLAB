%% Parallel Parking Using Nonlinear Model Predictive Control
% This example shows how to design a parallel parking controller using nonlinear model predictive control (NLMPC).

%%% Parking Environment
% In this example, the parking environment contains an ego vehicle and six static obstacles.
% The obstacles include four parked vehicles, the road curbside, and a yellow line on the road.
% The goal of the ego vehicle is to park at a target pose without colliding with any of the obstacles.
% The reference point for the ego vehicle pose is located at the center of rear axle.

% The ego vehicle has two axles and four wheels.
% Define the ego vehicle parameters.
vdims = vehicleDimensions;
egoWheelbase = vdims.Wheelbase;
distToCenter = 0.5*egoWheelbase;

% The ego vehicle starts at the following initial pose.
% - X position of 7 m
% - Y position of 3.1 m
% - Yaw angle 0 rad
egoInitialPose = [7,3.1,0];

% To park the center of the ego vehicle at the target location (X = 0, Y = 0) use the following target pose, which specifies the location of the rear-axle reference point.
% - X position equal to half the wheelbase length in the negative X direction
% - Y position of 0 m
% - Yaw angle 0 rad
egoTargetPose = [-distToCenter,0,0];

% Visualize the parking environment.
% Specify a visualizer sample time of 0.1 s.
Tv = 0.1;
helperSLVisualizeParking(egoInitialPose,0);

figure
imshow("ParallelParkingUsingNonlinearModelPredictiveControlExample_01.png")
axis off;

% In the visualization, the four parked vehicles are the orange boxes in the middle.
% The bottom orange boundary is the road curbside and the top orange boundary is the yellow line on the road.

%%% Ego Vehicle Model
% For parking problems, the vehicle travels at low speeds.
% This example uses a kinematic bicycle model with front steering angle for the vehicle parking problem.
% The motion of the ego vehicle can be described using the following equations.

figure
imshow("Opera Snapshot_2023-06-26_092338_www.mathworks.com.png")
axis off;

% Here, (x,y) denotes the position of the vehicle and ψ denotes the yaw angle of the vehicle.
% The parameter b represents the wheelbase of the vehicle.
% (x,y,ψ) are the state variables for the vehicle state functions.
% The speed v and steering angle δ are the control variables for the vehicle state functions.
% The vehicle state functions are implemented in parkingVehicleStateFcn.

%%% Design Nonlinear Model Predictive Controller

figure
imshow("Opera Snapshot_2023-06-26_092528_www.mathworks.com.png")
axis off;

% Specify the sample time (Ts), prediction horizon (p), and control horizon (m) for the nonlinear MPC controller.
Ts = 0.1;
p = 70;
c = 70;

% Specify constant weight matrices for the controller.
% Define both the tracking weight matrices (Qp and Rp) and the terminal weight matrices (Qt and Rt).
Qp = diag([0.1 0.1 0]);
Rp = 0.01*eye(2);
Qt = diag([1 5 100]); 
Rt = 0.1*eye(2);

% Specify the safety distance of 0.1 m, which the controller uses when defining its constraints.
safetyDistance = 0.1;

% Specify the maximum number of iterations for the NLMPC solver.
maxIter = 40;

% Create the nonlinear MPC controller.
% For clarity, first disable the MPC command-window messages.
mpcverbosity('off');

% Create the nlmpc controller object with three states, three outputs, and two inputs.
nx = 3;
ny = 3;
nu = 2;
nlobj = nlmpc(nx,ny,nu);

% Specify the sample time (Ts), prediction horizon (PredictionHorizon), and control horizon (ControlHorizon) for the controller.
nlobj.Ts = Ts;
nlobj.PredictionHorizon = p;
nlobj.ControlHorizon = c;

% Define constraints for the manipulated variables.
% Here, MV(1) is the ego vehicle speed in m/s, and MV(2) is the steering angle in radians.
nlobj.MV(1).Min = -2;
nlobj.MV(1).Max = 2;
nlobj.MV(2).Min = -pi/4;
nlobj.MV(2).Max = pi/4;

% Specify the controller state function and the state-function Jacobian.
nlobj.Model.StateFcn = "parkingVehicleStateFcn";
nlobj.Jacobian.StateFcn = "parkingVehicleStateJacobianFcn";

% Specify the controller cost function and the cost-function Jacobian.
nlobj.Optimization.CustomCostFcn = "parkingCostFcn";
nlobj.Optimization.ReplaceStandardCost = true;
nlobj.Jacobian.CustomCostFcn = "parkingCostJacobian";

% Define custom inequality constraints for the controller and the constraint Jacobian.
% The custom constraint function computes the distance form the ego vehicle to all the obstacles in the environment and compares these distances to the safe distance.
nlobj.Optimization.CustomIneqConFcn = "parkingIneqConFcn";
nlobj.Jacobian.CustomIneqConFcn = "parkingIneqConFcnJacobian";

% Configure the optimization solver of the controller.
nlobj.Optimization.SolverOptions.FunctionTolerance = 0.01;
nlobj.Optimization.SolverOptions.StepTolerance = 0.01;
nlobj.Optimization.SolverOptions.ConstraintTolerance = 0.01;
nlobj.Optimization.SolverOptions.OptimalityTolerance = 0.01;
nlobj.Optimization.SolverOptions.MaxIter = maxIter;

% Define an initial guess for the optimal state solution.
% This initial guess is the straight line from the starting pose to the target pose.
% Also, specify the values for the ego vehicle parameters in the nlmpcmoveopt object.
opt = nlmpcmoveopt;
opt.X0 = [linspace(egoInitialPose(1),egoTargetPose(1),p)', ...
          linspace(egoInitialPose(2),egoInitialPose(2),p)'...
          zeros(p,1)];
opt.MV0 = zeros(p,nu);

% Computing the cost function and inequality constraints, along with their Jacobians, requires passing parameters to the custom functions.
% Define the parameter vector and specify the number of parameters.
% Also, specify the parameter values in the nlmpcmoveopt object.
paras = {egoTargetPose,Qp,Rp,Qt,Rt,distToCenter,safetyDistance}';
nlobj.Model.NumberOfParameters = numel(paras);
opt.Parameters = paras;

%%% Simulate Controller in MATLAB
% To simulate an NLMPC controller in MATLAB®, you can use one of the following options:
% - Simulate the controller using the nlmpcmove function.
% - Build a MEX file for the controller using the buildMEX function. Evaluating this MEX file improves the simulation efficiency compared to nlmpcmove.
% Simulate the NLMPC controller for parking using the runParkingAndPlot script.
% For this simulation, do not build a MEX file (set useMEX to 0).
useMex = 0; 
runParkingAndPlot

figure
imshow("ParallelParkingUsingNonlinearModelPredictiveControlExample_02.png")
axis off;

% The ego vehicle parks in the target pose successfully.
% The final control input values are close to zero.
% In the animation and the ego vehicle does not collide with any obstacles at any time.
% Build a MEX file for your controller and rerun the simulation.
useMex = 1;
runParkingAndPlot

figure
imshow("ParallelParkingUsingNonlinearModelPredictiveControlExample_05.png")
axis off;

% The simulation using the MEX file produces similar results and is significantly faster than the simulation using nlmpcmove.

%%% Simulate Controller in Simulink
% To simulate the NLMPC controller in Simulink ®, use the Nonlinear MPC Controller block.
% For this example, to simulate the ego vehicle, use the Vehicle Body 3DOF Lateral block, which is a Bicycle Model (Automated Driving Toolbox) block.

% Specify the simulation duration and open the Simulink model.
Duration = p*Ts;
mdl = 'mpcVDAutoParking';
open_system(mdl)

figure
imshow("ParallelParkingUsingNonlinearModelPredictiveControlExample_08.png")
axis off;

% To pass the ego vehicle parameters to the controller, you must create a parameter bus object.
createParameterBus(nlobj,[mdl '/Nonlinear MPC Controller'],'parasBusObject',paras);

% Close the animation plot before simulating the model.
f = findobj('Name','Automated Parallel Parking');
close(f)

% Simulate the model.
sim(mdl)

figure
imshow("ParallelParkingUsingNonlinearModelPredictiveControlExample_09.png")
axis off;

% Examine the Ego Vehicle Pose and Controls scopes.
open_system([mdl '/Ego Vehicle Model/Ego Vehicle Pose'])
open_system([mdl '/Controls'])

figure
imshow("ParallelParkingUsingNonlinearModelPredictiveControlExample_10.png")
axis off;

figure
imshow("ParallelParkingUsingNonlinearModelPredictiveControlExample_11.png")
axis off;

% The simulation results are similar to the MATLAB simulation.
% The ego vehicle has parked at the target pose successfully without collisions with any obstacles.

%%% Conclusion
% This example shows how to design a nonlinear MPC controller for parallel parking.
% The controller navigates the ego vehicle to the target parking spot without colliding with any obstacles.
% Enable message display
mpcverbosity('on');
% Close Simulink model
bdclose(mdl)
% Close animation plots
f = findobj('Name','Automated Parallel Parking');
close(f)

%%% References
% [1] Schulman, John, Yan Duan, Jonathan Ho, Alex Lee, Ibrahim Awwal, Henry Bradlow, Jia Pan, Sachin Patil, Ken Goldberg, and Pieter Abbeel. %Motion Planning with Sequential Convex Optimization and Convex Collision Checking . The International Journal of Robotics Research 33, no. 9 (August 2014): 1251–70. https://doi.org/10.1177/0278364914528132.

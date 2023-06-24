%% Plan Parallel Parking Path Using Multistage Nonlinear Model Predictive Control
% This example shows how to plan a parallel parking path for an ego car in Simulink® using the Vehicle Path Planner System block.
% This block plans a vehicle path using multistage nonlinear model predictive control (MPC).

%%% Parking Environment
% In this example, the parking environment contains an ego vehicle and six static obstacles.
% The obstacles include four parked vehicles, the road curbside, and a yellow line on the road.
% The goal of the ego vehicle is to park at a target pose without colliding with any of the obstacles.
% The reference point for the ego vehicle pose is located at the center of rear axle.

% The ego vehicle starts at an initial pose with the vector format [x-position, y-position, yaw angle].
egoInitialPose = [7,3.1,0];

% To park the center of the ego vehicle at the target location (X = 0, Y = 0) use the following target pose, which specifies the location of the rear-axle reference point.
egoTargetPose = [-1.4,0,0];

% Visualize the parking environment.
helperSLVisualizeParking(egoInitialPose,0);

figure
imshow("PlanParallelParkingPathUsingMultistageNonlinearMPCExample_01.png")
axis off;

% In the visualization, the four parked vehicles are the orange boxes in the middle.
% The bottom orange boundary is the road curbside and the top orange boundary is the yellow line on the road.

%%% Configure Vehicle Path Planner System Block
% Define the parameters of the ego vehicle.
% For this example, the ego vehicle parameters of the Vehicle Path Planner System block match the simulation parameters.
% If your simulation parameters differ from the default values, then update the block parameters accordingly.
vdims = vehicleDimensions;
egoWheelbase = vdims.Wheelbase;
distToCenter = 0.5*egoWheelbase;

% Define the parameters of the six obstacles. Each row of obsMat contains five elements: position (x,y), heading angle, length, and width.
% Number of obstacles
numObs = 6;
% Each row represents an obstacle with five elements: [position (x,y), heading angle, length, and width]
obsMat = [-12.4,0,0,4.7,1.8;...
          -6.2,0,0,4.7,1.8;...
          6.2,0,0,4.7,1.8;...
          12.4,0,0,4.7,1.8;...
          0,-1.8,0,37.2,0.5;...
          0,5.65,0,37.2,0.5];

% Define the sample time and prediction horizon for the MPC controller.
Ts = 1;
p = 10;

% The velocity of the ego vehicle is constrained to the range [-2.5,2.5] m/s and the steering angle of the ego vehicle is constrained to the range [-30,30] degrees.
v_range = [-2.5,2.5];
steer_range = [-pi/6,pi/6];

% To avoid collisions with obstacles, the minimum distance to all obstacles must be greater than a safe distance.
% Define this distance in meters.
d_safe = 0.2;

% The Vehicle Path Planner System block can generate a reference path from the start pose of the ego car to a target pose.

%%% Run Vehicle Path Planner in Simulink Model
% Open the Simulink model.
mdl = 'pathPlanningVPP';
open_system(mdl)

figure
imshow("PlanParallelParkingPathUsingMultistageNonlinearMPCExamp.png")
axis off;

% Run the Simulink model and obtain the planned path.
out = sim(mdl);
path = out.simout;

% Run the animation to visualize results.
% animate
timeLength = size(path,1);
for ct = 1:timeLength
    helperSLVisualizeParking(path(ct,:), 0);
    pause(0.1);
end

figure
imshow("PlanParallelParkingPathUsingMultistageNonlinearMPCE (1).png")
axis off;

% The animation shows that the ego vehicle path successfully parks at the target pose without any obstacle collisions.

%%% Conclusion
% This example shows how to parallel park an ego car by generating a path using the Vehicle Path Planner System block.
% The planner generated a collision-free path to the target parking spot.

% Enable message display
mpcverbosity('on');
% Close Simulink model
bdclose(mdl)
% Close animation plots
f = findobj('Name','Automated Parallel Parking');
close(f)

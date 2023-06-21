%% Highway Lane Following with Intelligent Vehicles
% This example shows how to simulate a lane following application in a scenario that contains intelligent target vehicles.
% The intelligent target vehicles are the non-ego vehicles in the scenario and are programmed to adapt their trajectories based on the behavior of its neighboring vehicles.
% In this example, you will:

% 1. Model the behavior of the target vehicles to dynamically adapt their trajectories in order to perform one of the following behaviors: velocity keeping, lane following, or lane change.
% 2. Simulate and test the lane following application in response to the dynamic behavior of the target vehicles on straight road and curved road scenarios.

% You can also apply the modeling patterns used in this example to test your own lane following algorithms.

%%% Introduction
% The highway lane following system developed in this example steers the ego vehicle to travel within a marked lane.
% The system tests the lane following capability in the presence of other non-ego vehicles, which are the target vehicles.
% For regression testing, it is often sufficient for the target vehicles to follow a predefined trajectory.
% To randomize the behavior and identify edge cases like aggressive lane change in front of the ego vehicle, it is beneficial to add intelligence to the target vehicles.

% This example builds on the Highway Lane Following (Automated Driving Toolbox) example that demonstrates lane following in the presence of target vehicles that follow predefined trajectories.
% This example modifies the scenario simulation framework of the Highway Lane Following (Automated Driving Toolbox) example by adding functionalities to model and simulate intelligent target vehicles.
% The intelligent target vehicles added to this example adapt their trajectories based on the behavior of the neighboring vehicles and the environment.
% In response, the lane following system automatically reacts to ensure that the ego vehicle stays in its lane.

% In this example, you achieve system-level simulation through integration with the Unreal Engine® from Epic Games®.
% The 3D simulation environment requires a Windows® 64-bit platform.
if ~ispc
    error(['Unreal simulation is only supported on Microsoft', char(174), ' Windows', char(174), '.']);
end

% To ensure reproducibility of the simulation results, set the random seed.
rng(0);

% In the rest of the example, you will:
% 1. Explore the test bench model: Explore the functionalities in the system-level test bench model that you use to assess lane following with intelligent target vehicles.
% 2. Vehicle behaviors: Explore vehicle behaviors that you can use to model the intelligent target vehicles.
% 3. Model the intelligent target vehicles: Model the target vehicles in the scenario for three different behaviors: velocity keeping, lane following, and lane changing.
% 4. Simulate lane following with intelligent target vehicles on a straight road: Simulate velocity keeping, lane following, and lane change behaviors of a target vehicle while testing lane following on a straight road.
% 5. Simulate lane following with intelligent target vehicles on a curved road: Simulate velocity keeping, lane following, and lane change behaviors of a target vehicle while testing lane following on a curved road.
% 6. Test with other scenarios: Test the model with other scenarios available with this example.

%%% Explore Test Bench Model
% To explore the test bench model, open a working copy of the project example files. MATLAB® copies the files to an example folder so that you can edit them.
addpath(fullfile(matlabroot, 'toolbox', 'driving', 'drivingdemos'));
helperDrivingProjectSetup('HLFIntelligentVehicles.zip', 'workDir', pwd);

% Open the system-level simulation test bench model for the lane following application.
open_system("HighwayLaneFollowingWithIntelligentVehiclesTestBench")

figure
imshow("HighwayLaneFollowingWithIntelligentVehiclesExample_01.png")
axis off;

% The test bench model contains these modules:
% 1. Simulation 3D Scenario: Subsystem that specifies road, ego vehicle, intelligent target vehicles, camera, and radar sensors used for simulation.
% 2. Lane Marker Detector: Algorithm model to detect the lane boundaries in the frame captured by camera sensor.
% 3. Vehicle Detector: Algorithm model to detect to detect vehicles in the frame captured by camera sensor.
% 4. Forward Vehicle Sensor Fusion: Algorithm model that fuses the detections of vehicles in front of the ego vehicle that were obtained from vision and radar sensors.
% 5. Lane Following Decision Logic: Algorithm model that specifies lateral, longitudinal decision logic and provides lane center information and MIO related information to controller.
% 6. Lane Following Controller: Algorithm model that specifies the controls.
% 7. Vehicle Dynamics: Specifies the dynamics model for the ego vehicle.
% 8. Metrics Assessment: Assesses system-level behavior.

% The Lane Marker Detector, Vehicle Detector, Forward Vehicle Sensor Fusion, Lane Following Decision Logic, Lane Following Controller, Vehicle Dynamics, and Metrics Assessment subsystems are based on the subsystems used in Highway Lane Following (Automated Driving Toolbox) (Automated Driving Toolbox).
% If you have license to Simulink® Coder™ and Embedded Coder™, you can generate deployable-ready embedded real-time code for the Lane Marker Detector, Vehicle Detector, Forward Vehicle Sensor Fusion, Lane Following Decision Logic, and Lane Following Controller algorithm models.
% This example focuses only on the Simulation 3D Scenario subsystem.
% An Intelligent Target Vehicles subsystem block is added to the Simulation 3D Scenario subsystem in order to configure the behavior of target vehicles in the scenario.
% The Lane Marker Detector, Vehicle Detector, Forward Vehicle Sensor Fusion, Lane Following Decision Logic, Lane Following Controller, Vehicle Dynamics, and Metrics Assessment subsystems steer the ego vehicle in response to the behavior of the target vehicles configured by the Simulation 3D Scenario subsystem.

% Open the Simulation 3D Scenario subsystem and highlight the Intelligent Target Vehicles subsystem.
open_system("HighwayLaneFollowingWithIntelligentVehiclesTestBench/Simulation 3D Scenario")
hilite_system("HighwayLaneFollowingWithIntelligentVehiclesTestBench/Simulation 3D Scenario/Intelligent Target Vehicles")

figure
imshow("HighwayLaneFollowingWithIntelligentVehiclesExample_02.png")
axis off;

% The Simulation 3D Scenario subsystem configures the road network, models the target vehicles, sets vehicle positions, and synthesizes sensors.
% The subsystem is initialized by using the helperSLHighwayLaneFollowingWithIntelligentVehiclesSetup script.
% This script defines the driving scenario for testing the highway lane following.
% This setup script defines the road network and sets the behavior for each target vehicle in the scenario.

% - The Scenario Reader (Automated Driving Toolbox) block reads the roads and actors (ego and target vehicles) from a scenario file specified using the helperSLHighwayLaneFollowingWithIntelligentVehiclesSetup script. The block outputs the poses of target vehicles and the lane boundaries with respect to the coordinate system of the ego vehicle.
% - The Intelligent Target Vehicles is a function-call subsystem block that models the behavior of the actors in the driving scenario. The initial values for this subsystem block parameters are set by the helperSLHighwayLaneFollowingWithIntelligentVehiclesSetup script. The Cuboid To 3D Simulation (Automated Driving Toolbox) and the Simulation 3D Vehicle with Ground Following (Automated Driving Toolbox) blocks set the actor poses for the 3D simulation environment.
% - The Simulation 3D Scene Configuration (Automated Driving Toolbox) block implements a 3D simulation environment by using the road network and the actor positions.

% This setup script also configures the controller design parameters, vehicle model parameters, and the Simulink® bus signals required for the HighwayLaneFollowingWithIntelligentVehiclesTestBench model.
% This script assigns an array of structures, targetVehicles, to the base workspace that contains the behavior type for each target vehicle.

%%% Vehicle Behaviors
% This example enables you to use four modes of vehicle behaviors for configuring the target vehicles using the targetVehicles structure.
% - Default: In this mode, the target vehicles in the scenario follow predefined trajectories. The target vehicles are non-adaptive and are not configured for intelligent behavior.
% - VelocityKeeping: In this mode, the target vehicles are configured to travel in a lane at a constant set velocity. Each target vehicle maintains the set velocity regardless of the presence of a lead vehicle in its current lane and does not check for collision.
% - LaneFollowing: In this mode, the target vehicles are configured to travel in a lane by adapting their velocities in response to a lead vehicle. If a target vehicle encounters a lead vehicle in its current lane, the model performs collision checking and adjusts the velocity of the target vehicle. Collision checking ensures that the target vehicle maintains a safe distance from the lead vehicle.
% - LaneChange: In this mode, the target vehicles are configured to travel in a lane at a particular velocity and follow the lead vehicle. If the target vehicle gets too close to the lead vehicle, then it performs a lane change. Before changing the lane, the model checks for potential forward and side collisions and adapts the velocity of the target vehicle to maintain a safe distance from other vehicles in the scenario.

%%% Model Intelligent Target Vehicles
% The Intelligent Target Vehicles subsystem dynamically updates the vehicle poses for all the target vehicles based on their predefined vehicle behavior.
% As mentioned already, the helperSLHighwayLaneFollowingWithIntelligentVehiclesSetup script defines the scenario and the behavior for each target vehicle in the scenario.
% The setup script stores the vehicle behavior and other attributes as an array of structures, targetVehicles, to the base workspace.
% The structure stores these attributes:
% - ActorID
% - Position
% - Velocity
% - Roll
% - Pitch
% - Yaw
% - AngularVelocity
% - InitialLaneID
% - BehaviorType

% The Intelligent Target Vehicles subsystem uses a mask to load the configuration in targetVehicles from the base workspace.
% You can set the values of these attributes to modify the position, orientation, velocities, and behavior of target vehicles.
% Open the Intelligent Target Vehicles subsystem.
open_system("HighwayLaneFollowingWithIntelligentVehiclesTestBench/Simulation 3D Scenario/Intelligent Target Vehicles")

figure
imshow("HighwayLaneFollowingWithIntelligentVehiclesExample_03.png")
axis off;

% The Vehicle To World (Automated Driving Toolbox) block converts the predefined actor (ego and target vehicle) poses and trajectories from ego-vehicle coordinates to world coordinates.
% The Target Vehicle Behavior subsystem block computes the next state of the target vehicles by using predefined target vehicles poses, ego-vehicle pose, and current state of target vehicles.
% The subsystem outputs the target vehicles poses in world coordinates for navigating the vehicles in the 3D simulation environment.

% Open the Target Vehicle Behavior subsystem.
open_system("HighwayLaneFollowingWithIntelligentVehiclesTestBench/Simulation 3D Scenario/Intelligent Target Vehicles/Target Vehicle Behavior",'tab')

figure
imshow("HighwayLaneFollowingWithIntelligentVehiclesExample_04.png")
axis off;

% The Target Vehicle Behavior subsystem enables you to switch between the default and other vehicle behaviors.
% If the behavior type for a target vehicle is set to Default, the subsystem configures the target vehicles to follow predefined trajectories.
% Otherwise, the position of the vehicle is dynamically computed and updated using the Intelligent Vehicle subsystem block.
% The Intelligent Vehicle subsystem block configures the VelocityKeeping, LaneFollowing, and LaneChange behaviors for the target vehicles.

% Open Intelligent Vehicle subsystem.
open_system("HighwayLaneFollowingWithIntelligentVehiclesTestBench/Simulation 3D Scenario/Intelligent Target Vehicles/Target Vehicle Behavior/Intelligent Vehicle")

figure
imshow("HighwayLaneFollowingWithIntelligentVehiclesExample_05.png")
axis off;

% The Intelligent Vehicle subsystem computes the pose of a target vehicle by using information about the neighboring vehicles and the vehicle behavior. The subsystem is similar to the Lane Change Planner component of the Highway Lane Change (Automated Driving Toolbox) example. The Intelligent Vehicle subsystem has these blocks:
% - The Environment Updater block computes the lead and rear vehicle information, current lane number, and existence of adjacent lanes (NoLeftLane, NoRightLane) with respect to the current state of the target vehicle. This block is configured by the System object™ HelperEnvironmentUpdater.
% - The Velocity Keeping Sampler block defines terminal states required for the VelocityKeeping behavior. This block reads the set velocity from the mask parameter norm(TargetVehicle.Velocity).
% - The Lane Following Sampler block defines terminal states required for the LaneFollowing behavior. This block reads the set velocity from the mask parameter norm(TargetVehicle.Velocity).
% - The Lane Change Sampler block defines terminal states required for the LaneChange behavior. This block also defines deviation offset from the reference path to keep the vehicle in a specific lane after a lane change. This block reads TargetVehicle.Velocity, laneInfo, and TargetVehicle.InitialLaneID from the base workspace by using mask parameters.

% The table shows the configuration of terminal states and parameters for different vehicle behaviors:

figure
imshow("xxstatetable.png")
axis off;

% - The Check Collision block checks for collision with any other vehicle in the scenario. The simulation stops if collision is detected.
% - The Pulse Generator block defines the replan period for the Motion Planner subsystem. The default value is set to 1 second. Replanning can be triggered every pulse period, or if any of the samplers has a state update, or by the Motion Planner subsystem.
% - The MotionPlanner subsystem generates trajectory for a target vehicle by using the terminal states defined by the vehicle behavior. It uses trajectoryOptimalFrenet (Navigation Toolbox) from Navigation Toolbox™ to generate a trajectory. The subsystem estimates the position of the vehicle along its trajectory at every simulation step. This subsystem internally uses the HelperTrajectoryPlanner System object™ to implement a fallback mechanism for different vehicle behaviors when the trajectoryOptimalFrenet function is unable to generate a feasible trajectory.
% - If the vehicle behavior is set to LaneChange, the trajectory planner attempts to generate a trajectory with LaneFollowing behavior. If it is unable to generate a trajectory, then it stops the vehicle using its stop behavior.
% - If the vehicle behavior is set to LaneFollowing or VelocityKeeping, the trajectory planner stops the vehicle using stop behavior.

% The system implements the stop behavior by constructing a trajectory with the previous state of the vehicle, which results in an immediate stop of the target vehicle.

%%% Simulate Intelligent Target Vehicle Behavior on Straight Road
% This example uses a test scenario that has three target vehicles (red sedan, black muscle car, and orange hatchback) and one ego vehicle (blue sedan) traveling on a straight road with two lanes.
% - The red sedan is the first target vehicle and travels in the lane adjacent to the ego lane.
% - The orange hatchback is a lead vehicle for the ego vehicle in the ego lane.
% - The black muscle car is slow moving and a lead vehicle for the red sedan in the adjacent lane of the ego vehicle. The figure shows the initial positions of these vehicles.

figure
imshow("xxIntelligentVehicle3DScenarioStraight.jpg")
axis off;

% You can run the simulation any number of times by changing the behavior type for each vehicle during each run.
% This example runs the simulation three times and at each run the behavior type for the first target vehicle is modified.

%%% Configure All Target Vehicles Behavior to Velocity Keeping and Run Simulation
% Run the setup script to configure VelocityKeeping behavior for all target vehicles.
helperSLHighwayLaneFollowingWithIntelligentVehiclesSetup(...
    "scenarioFcnName",...
    "scenario_LFACC_01_Straight_IntelligentVelocityKeeping");

% Display the BehaviorType of all the target vehicles.
disp([targetVehicles(:).BehaviorType]');

% Run the simulation and visualize the results.
% The target vehicles in the scenario travel in their respective lanes at a constant velocity.
% The red sedan and the black muscle car maintain their velocity and do not check for collisions.

% To reduce command-window output, turn off the model predictive control (MPC) update messages.
mpcverbosity('off');
% Run the model
simout = sim("HighwayLaneFollowingWithIntelligentVehiclesTestBench","StopTime","9");

% Plot the velocity profiles of ego and first target vehicle (red sedan) to analyze the results.
hFigVK = helperPlotEgoAndTargetVehicleProfiles(simout.logsout);

% Close figure
close(hFigVK);

% - The Yaw Angle of Target Vehicle (Red sedan) plot shows the yaw angle of the red sedan. There is no variation in the yaw angle as the vehicle travels on a straight lane road.
% - The Absolute Velocity of Target Vehicle (Red sedan) plot shows the absolute velocity of the red sedan. The velocity profile of the vehicle is constant as the vehicle is configured to VelocityKeeping behavior.
% - The Absolute Velocity of Ego Vehicle (Blue sedan) plot shows that there is no effect of the red sedan on the ego vehicle as both vehicles travel in adjacent lanes.

%%% Configure First Target Vehicle Behavior to Lane Following and Run Simulation
% Configure the behavior type for the first target vehicle (red sedan) to perform lane following.
% Display the updated values for the BehaviorType of target vehicles.
targetVehicles(1).BehaviorType = VehicleBehavior.LaneFollowing;
disp([targetVehicles(:).BehaviorType]');

% Run the simulation and visualize the results.
% The target vehicles in the scenario are traveling in their respective lanes.
% The first target vehicle (red sedan) slows down to avoid colliding with the slow-moving black muscle car in its lane.
sim("HighwayLaneFollowingWithIntelligentVehiclesTestBench");

% Plot the velocity profiles of the ego and first target vehicle (red sedan) to analyze the results.
hFigLF = helperPlotEgoAndTargetVehicleProfiles(logsout);

% Close figure
close(hFigLF);

% - The Yaw Angle of Target Vehicle (Red sedan) plot is the same as the one obtained in the previous simulation. There is no variation in the yaw angle as the vehicle travels on a straight lane road.
% - The Absolute Velocity of Target Vehicle (Red sedan) plot diverges from the previous simulation. The velocity of the red sedan gradually decreases from 13 m/s to 5 m/s to avoid colliding with the black muscle car and maintains a safety gap.
% - The Absolute Velocity of Ego Vehicle (Blue sedan) plot is same as the one in the previous simulation. The ego vehicle is not affected by the change in the behavior of the red sedan.

%%% Configure First Target Vehicle Behavior to Lane Changing and Run Simulation
targetVehicles(1).BehaviorType = VehicleBehavior.LaneChange;

% Display the BehaviorType of all the target vehicles.
disp([targetVehicles(:).BehaviorType]');

% Run the simulation and visualize the results.
% The orange hatchback and black muscle car are traveling at constant velocity in their respective lanes.
% The first target vehicle (red sedan) performs a lane change as it gets close to the black muscle car.
% It also does another lane change when it gets close to the orange hatchback.
sim("HighwayLaneFollowingWithIntelligentVehiclesTestBench");

% Plot the velocity profiles of the ego and the first target vehicle (red sedan) to analyze the results.
hFigLC = helperPlotEgoAndTargetVehicleProfiles(logsout);

% Close figure
close(hFigLC);

% - The Yaw Angle of Target Vehicle (Red sedan) plot diverges from the previous simulation results. The yaw angle profile of the first target vehicle shows deviations as the vehicle performs a lane change.
% - The Absolute Velocity of Target Vehicle (Red sedan) plot is similar to the VelocityKeeping behavior. The red sedan maintains a constant velocity even during the lane change.
% - The Absolute Velocity of Ego Vehicle (Blue sedan) plot shows the ego vehicle response to the lane change maneuver by the first target vehicle (red sedan). The velocity of the ego vehicle decreases as the red sedan changes lanes. The red sedan moves to the ego lane and travels in front of the ego vehicle. The ego vehicle reacts by decreasing its velocity in order to travel in the same lane. Close all the figures.

%%% Simulate Intelligent Target Vehicle Behavior on Curved Road
% Test the model on a scenario with curved roads.
% The vehicle configuration and position of vehicles are similar to the previous simulation.
% The test scenario contains a curved road and the first target vehicle (Red sedan) is configured to LaneChange behavior.
% The other two target vehicles are configured to VelocityKeeping behavior.
% The figure below shows the initial positions of the vehicles in the curved road scene.

figure
imshow("xxIntelligentVehicle3DScenario.jpg")
axis off;

% Run the setup script to configure the model parameters.
helperSLHighwayLaneFollowingWithIntelligentVehiclesSetup(...
    "scenarioFcnName",...
        "scenario_LFACC_04_Curved_IntelligentLaneChange");

% Run simulation and visualize the results.
% Plot the yaw angle and velocity profiles of ego and target vehicles.
sim("HighwayLaneFollowingWithIntelligentVehiclesTestBench");
hFigCurvedLC = helperPlotEgoAndTargetVehicleProfiles(logsout);

% - The Yaw Angle of Target Vehicle (Red sedan) plot shows variation in the profile as the red sedan performs lane change on a curved road. The curvature of the road also impacts the yaw angle of the target vehicle.
% - The Absolute Velocity of Target Vehicle (Red sedan) plot is similar to the VelocityKeeping behavior, as the red sedan maintains a constant velocity during lane change on a curved road.
% - The Absolute Velocity of Ego Vehicle (Blue sedan) plot shows the response of the ego vehicle to the lane change maneuver by the red sedan. The ego vehicle reacts by decreasing its velocity in order to travel in the same lane.

% Close the figure.
close(hFigCurvedLC);

%%% Explore Other Scenarios
% This example provides additional scenarios that are compatible with the HighwayLaneFollowingWithIntelligentVehiclesTestBench model.
% Below is a list of compatible scenarios that are provided with this example.
% - scenario_LFACC_01_Straight_IntelligentVelocityKeeping function configures the test scenario such that all the target vehicles are configured to perform VelocityKeeping behavior on a straight road.
% - scenario_LFACC_02_Straight_IntelligentLaneFollowing function configures the test scenario such that the red sedan performs LaneFollowing behavior while all other target vehicles perform VelocityKeeping behavior on a straight road.
% - scenario_LFACC_03_Straight_IntelligentLaneChange function configures the test scenario such that the red sedan performs LaneChange behavior while all other target vehicles perform VelocityKeeping behavior on a straight road.
% - scenario_LFACC_04_Curved_IntelligentLaneChange function configures the test scenario such that the red sedan performs LaneChange behavior while all other target vehicles perform VelocityKeeping behavior on a curved road. This is configured as the default scenario.
% - scenario_LFACC_05_Curved_IntelligentDoubleLaneChange function configures the test scenario such that the red sedan performs LaneChange behavior while all other target vehicles perform VelocityKeeping behavior on a curved road. The placement of other vehicles in this scenario is such that the red sedan performs a double lane change during the simulation.

% For more details on the road and target vehicle configurations in each scenario, view the comments in each file.
% You can configure the Simulink model and workspace to simulate these scenarios using the helperSLHighwayLaneFollowingWithIntelligentVehiclesSetup function.
%helperSLHighwayLaneFollowingWithIntelligentVehiclesSetup("scenarioFcnName","scenario_LFACC_05_Curved_IntelligentDoubleLaneChange");

%%% Conclusion
% This example demonstrates how to test the functionality of a lane following application in a scenario with an ego vehicle and multiple intelligent target vehicles.
% Enable the MPC update messages again.
mpcverbosity('on');

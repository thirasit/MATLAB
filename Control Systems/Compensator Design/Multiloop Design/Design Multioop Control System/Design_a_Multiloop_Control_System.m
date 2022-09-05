%% Design a Multiloop Control System

% In many applications, a single-loop control system is not feasible due to your plant design or design requirements. 
% If you have a design with an inner and outer loop, you can use Control System Designer to design compensators for both loops.

% The typical workflow is to tune the compensator for the inner loop first, by isolating the inner loop from the rest of the control system. 
% Once the inner loop is satisfactorily tuned, tune the outer loop to achieve your desired closed-loop response.

%%% System Model
% For this example develop a position control system for a DC motor. 
% A single-loop angular velocity controller is designed in Bode Diagram Design. 
% To design an angular position controller, add an outer loop that contains an integrator.

figure
imshow("csd_multiloop_plant_model1.gif")

% Define a state-space plant model, as described in SISO Example: The DC Motor.

% Define the motor parameters
R = 2.0
L = 0.5
Km = .015
Kb = .015
Kf = 0.2
J = 0.02
% Create the state-space model
A = [-R/L -Kb/L; Km/J -Kf/J]
B = [1/L; 0];
C = [0 1];
D = [0];
sys_dc = ss(A,B,C,D);

%%% Design Objectives
% The design objective is to minimize the closed-loop step response settling time, while maintaining an inner-loop phase margin of at least 65 degrees with maximum bandwidth:
% - Minimal closed-loop step response settling time.
% - Inner-loop phase margin of at least 65 degrees.
% - Maximum inner-loop bandwidth.

%%% Match System To Control Architecture
% Control System Designer has six possible control architectures from which you can choose. 
% For more information on these architectures, see Feedback Control Architectures.

% For this example use Configuration 4, which has an inner and outer control loop.

figure
imshow("csd_configuration4.png")

% Currently, the control system structure does not match Configuration 4. 
% However, using block diagram algebra, you can modify the system model by adding:
% - An integrator to the motor output to get the angular displacement.
% - A differentiator to the inner-loop feedback path.

figure
imshow("csd_multiloop_plant_model2.gif")

% At the MATLAB® command line, add the integrator to the motor plant model.

plant = sys_dc*tf(1,[1,0]);

% Create an initial model of the inner-loop compensator that contains the feedback differentiator.

Cdiff = tf('s');

%%% Define Control Architecture
% Open Control System Designer.

controlSystemDesigner

% In Control System Designer, on the Control System tab, click Edit Architecture.
% In the Edit Architecture dialog box, under Select Control Architecture, click the fourth architecture.

figure
imshow("csd_multiloop_edit_architecture.png")

% Import the plant and controller models from the MATLAB workspace.

% In the Blocks tab, for:
% - Controller C2, specify a Value of Cdiff.
% - Plant G, specify a Value of plant.

% Click OK.

% The app updates the control architecture and imports the specified models for the motor plant and the inner-loop controller.

% In Control System Designer, the following plots open:
% - Bode Editor for LoopTransfer_C1 — Open-loop Bode Editor for the outer loop
% - Root Locus Editor for LoopTransfer_C1 — Open-loop Root Locus Editor for the outer loop
% - Bode Editor for LoopTransfer_C2 — Open-loop Bode Editor for the inner loop
% - Root Locus Editor for LoopTransfer_C2 — Open-loop root Locus Editor for the inner loop
% - IOTransfer_r2y: step — Overall closed-loop step response from input r to output y

% For this example, close the Bode Editor for LoopTransfer_C1 and Root Locus Editor for LoopTransfer_C2 plots.
% Since the inner loop is tuned first, configure the plots to view just the inner-loop Bode editor plot. On the View tab, click Single, and click Bode Editor for LoopTransfer_C2.

figure
imshow("csd_multiloop_inner_bode.png")

%%% Isolate Inner Loop
% To isolate the inner loop from the rest of the control system architecture, add a loop opening to the open-loop response of the inner loop. 
% In the Data Browser, right-click LoopTransfer_C2, and select Open Selection.

% To add a loop opening at the output of outer-loop compensator, C1, in the Open-Loop Transfer Function dialog box, click  Add loop opening location to list. Then, select uC1.

figure
imshow("csd_multiloop_add_opening.png")

% Click OK.

% The app adds a loop opening at the selected location. This opening removes the effect of the outer control loop on the open-loop transfer function of the inner loop.
% The Bode Editor response plot updates to reflect the new open-loop transfer function.

figure
imshow("csd_multiloop_bode_isolated.png")

%%% Tune Inner Loop
% To increase the bandwidth of the inner loop, increase the gain of compensator C2.
% In the Bode Editor plot, drag the magnitude response upward until the phase margin is 65 degrees. 
% This corresponds to a compensator gain of 107. 
% Increasing the gain further reduces the phase margin below 65 degrees.

figure
imshow("csd_multiloop_set_inner_gain.png")

% Alternatively, you can adjust the gain value using the compensator editor. For more information, see Edit Compensator Dynamics.

%%% Tune Outer Loop
% With the inner loop tuned, you can now tune the outer loop to reduce the closed-loop settling time.
% In Control System Designer, on the View tab, select Left/Right. Arrange the plots to display the Root Locus for LoopTransfer_C1 and IOTransfer_r2y_step plots simultaneously.
% To view the current settling time, right-click in the step response plot and select Characteristics > Settling Time.

figure
imshow("csd_multiloop_plots_left_right.png")

% The current closed-loop settling time is greater than 500 seconds.
% In the Root Locus Editor, increase the gain of compensator C1. 
% As the gain increases, the complex pole pair moves toward a slower time constant and the real pole moves toward a faster time constant. 
% A gain of 600 produces a good compromise between rise time and settling time.

figure
imshow("csd_multiloop_final.png")

% With a closed-loop settling time below 0.8 seconds and an inner-loop phase margin of 65 degrees, the design satisfies the design requirements.

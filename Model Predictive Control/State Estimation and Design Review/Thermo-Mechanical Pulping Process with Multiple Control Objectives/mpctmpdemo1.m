%% Thermo-Mechanical Pulping Process with Multiple Control Objectives
% This example shows how to control a thermo-mechanical pulping (TMP) plant with a model predictive controller.

%%% Plant Description
% The following diagram shows a typical process arrangement for a two stage TMP operation.
% Two pressured refiners operate in sequence to produce a mechanical pulp suitable for making newsprint.

% The primary objective of controlling the TMP plant is to regulate the energy applied to the pulp by the electric motors which drive each refiner, so that the resulting pulp has the desired physical properties while at the same time excessive energy expenses are avoided.

% The secondary control objective is to regulate the ratio of dry mass flow rate to overall mass flow rate (known as consistency) measured at the outlet of each refiner.

% In practice, these objectives amount to regulating the primary and secondary refiner motor loads, and the primary and secondary refiner constancies, subject to the following output constraints:
% (1) Maintain the power on each refiner below the maximum rated values.
% (2) Maintain the vibration level on the two refiners below a critical level to prevent refiner plate clash.
% (3) Limit the measured consistency to prevent blow line plugging and fiber damage.

% The manipulated variables for this plant include:
% - Gap controller setpoints for regulating the distance between the refiner plates
% - Dilution flow rates to the two refiners
% - RPM of the screw feeder
% Physical limits are also imposed on each of these inputs.

figure
imshow("xxmpctmpdemo_plant.jpg")
axis off;

%%% Modeling of the TMP Plant in Simulink®
% The following Simulink® model represents a TMP plant in closed loop with an MPC Controller designed for the control objectives described above.
% Open the model and call a script to initialize the plant.
open_system('mpctmp_cl')
mpctmp_init;

figure
imshow("mpctmpdemo_01.png")
axis off;

% Load the MPC controller in the workspace.
load mpctmp_demodata;

% The controller, which was designed using MPC Designer, is contained in the variable mpcobj.
% Display controller information in the command window.
mpcobj

%%% Tuning the Controller Using the MPC Designer App
% Click the "Design" button in the MPC Controller block dialog to launch the MPC Designer app.

figure
imshow("xxmpctmpdemo_newapp.png")
axis off;

% In the Tuning tab, click Weights to open the Weights dialog box.
% To put more emphasis on regulating primary and secondary refiner motor loads and constancies, specify the input and output weights as follows:

figure
imshow("xxmpctmpdemo_weightdlg.png")
axis off;

% In the MPC Designer tab, click Edit Scenario to open the Simulation Scenario dialog box.
% To simulate a primary refiner motor load setpoint change from 8 to 9 MW without a model mismatch, specify the simulation scenario settings as follows:

figure
imshow("xxmpctmpdemo_scenariodlg.png")
axis off;

% The effect of design changes can be observed immediately in the response plots.

figure
imshow("xxmpctmpdemo_fullapp.png")
axis off;

%%% Simulating the Design in Simulink®
% The controller can be tested on the non-linear plant by running the simulation in Simulink®.
% In the Tuning tab, in the Update and Simulate drop-down list, select Update Block and Run Simulation to export the current controller design to the MATLAB® workspace and run the simulation in Simulink.
% Alternatively, select Update Block Only, and then run the simulation from Simulink or from the MATLAB command line use the sim command.
sim('mpctmp_cl');

%%% Open the scopes
% The output of the 3 scopes show the response to initial setpoints with:
% - Primary consistency of 0.4
% - Secondary motor load of 6 MW
% - Secondary consistency of 0.3
open_system('mpctmp_cl/Pri. motor load')
open_system('mpctmp_cl/Sec. motor load')
open_system('mpctmp_cl/Sec. consistency')

figure
imshow("mpctmpdemo_02.png")
axis off;

figure
imshow("mpctmpdemo_03.png")
axis off;

figure
imshow("mpctmpdemo_04.png")
axis off;

bdclose('mpctmp_cl')

%% Design Compensator Using Automated PID Tuning and Graphical Bode Design

% This example shows how to design a compensator for a Simulink® model using automated PID tuning in the Control System Designer app. 
% It then shows how to fine tune the compensator design using the open-loop Bode editor.

%%% System Model
% This example uses the watertank_comp_design Simulink model. 
% To open the model, at the MATLAB® command line, enter:

open_system('watertank_comp_design')

figure;
imshow("comp_design_watertank_model.png")

% This model contains a Water-Tank System plant model and a PID controller in a single-loop feedback system.

% To view the water tank model, open the Water-Tank System subsystem.

figure;
imshow("comp_design_watertank_model_watertank.png")

% This model represents the following water tank system.

figure;
imshow("op_watertank_schematic.gif")

% Here:
% * H is the height of water in the tank.
% * Vol is the volume of water in the tank.
% * V is the voltage applied to the pump.
% * A is the cross-sectional area of the tank.
% * b is a constant related to the flow rate into the tank.
% * a is a constant related to the flow rate out of the tank.

% Water enters the tank from the top at a rate proportional to the voltage applied to the pump. 
% The water leaves through an opening in the tank base at a rate that is proportional to the square root of the water height in the tank. 
% The presence of the square root in the water flow rate results in a nonlinear plant. 
% Based on these flow rates, the rate of change of the tank volume is:

figure;
imshow("Opera Snapshot_2022-11-17_122740_www.mathworks.com.png")

%%% Design Requirements
% Tune the PID controller to meet the following closed-loop step response design requirements:
% * Overshoot less than 5%
% * Rise time less than five seconds

%%% Open Control System Designer
% To open Control System Designer, in the Simulink model window, in the Apps gallery, click Control System Designer.

figure;
imshow("csd_watertank_open_app.png")

% Control System Designer opens and automatically opens the Edit Architecture dialog box.

%%% Specify Blocks to Tune
% To specify the compensator to tune, in the Edit Architecture dialog box, click Add Blocks.

% In the Select Blocks to Tune dialog box, in the left pane, click the Controller subsystem. 
% In the Tune column, check the box for the PID Controller.

figure;
imshow("csd_watertank_select_block.png")

% Click OK.

% In the Edit Architecture dialog box, the app adds the selected controller block to the list of blocks to tune on the Blocks tab. 
% On the Signals tab, the app also adds the output of the PID Controller block to the list of analysis point Locations.

figure;
imshow("csd_watertank_signal_locations.png")

% When Control System Designer opens, it adds any analysis points previously defined in the Simulink model to the Locations list. 
% For the watertank_comp_design, there are two such signals.

% * Desired Water Level block output — Reference signal for the closed-loop step response
% * Water-Tank System block output — Output signal for the closed-loop step response

% To linearize the Simulink model and set the control architecture, click OK.

% By default, Control System Designer linearizes the plant model at the model initial conditions.

% The app adds the PID controller to the data browser, in the Controllers and Fixed Blocks section. 
% The app also computes the open-loop transfer function at the output of the PID Controller block and adds this response to the data browser.

figure;
imshow("csd_watertank_data_browser.png")

%%% Plot Closed-Loop Step Response

% To analyze the controller design, create a closed-loop transfer function of the system and plot its step response.

% On the Control System tab, click New Plot, and select New Step.

figure;
imshow("csd_watertank_new_step.png")

% In the New Step to plot dialog box, in the Select Response to Plot drop-down list, select New Input-Output Transfer Response.

% To add an input signal, in the Specify input signals area, click +. 
% In the drop-down list, select the output of the Desired Water Level block.

figure;
imshow("csd_watertank_select_input.png")

% To add an output signal, in the Specify output signals area, click +. 
% In the drop-down list, select the output of the Water-Tank System block.

figure;
imshow("csd_watertank_select_output.png")

% To create the closed-loop transfer function and plot the step response, click Plot.

figure;
imshow("csd_watertank_initial_step.png")

% To view the maximum overshoot on the response plot, right-click the plot area, and select Characteristics > Peak Response.

% To view the rise time on the response plot, right-click the plot area, and select Characteristics > Rise Time.

figure;
imshow("csd_watertank_add_characteristics.png")


% Mouse-over the characteristic indicators to view their values. 
% The current design has a:

% * Maximum overshoot of 47.9%.
% * Rise time of 2.13 seconds.

% This response does not satisfy the 5% overshoot design requirement.

%%% Tune Compensator Using Automated PID Tuning

% To tune the compensator using automated PID tuning, click Tuning Methods, and select PID Tuning.

% In the PID Tuning dialog box, in the Specifications section, select the following options:

% * Tuning method — Robust response time
% * Controller Type — PI

figure;
imshow("csd_watertank_pid_settings.png")

% Click Update Compensator. 
% The app updates the closed-loop response for the new compensator settings and updates the step response plot.

figure;
imshow("csd_watertank_pid_result.png")

% To check the system performance, mouse over the response characteristic markers. 
% The system response with the tuned compensator has a:
% * Maximum overshoot of 13.8%.
% * Rise time of 51.2 seconds.

% This response exceeds the maximum allowed overshoot of 5%. 
% The rise time is much slower than the required rise time of five seconds.

%%% Tune Compensator Using Bode Graphical Tuning
% To decrease the rise time, interactively increase the compensator gain using graphical Bode Tuning.

% To open the open-loop Bode editor, click Tuning Methods, and select Bode Editor.

% In the Select Response to Edit dialog box, the open-loop response at the output of the PID Controller block is already selected. 
% To open the Bode editor for this response, click Plot.

% To view the Bode Editor and Step Response plots side-by-side, on the plot tab, click Tile All > Left/Right.

figure;
imshow("csd_watertank_open_bode.png")

% In the Bode Editor plot, drag the magnitude response up to increase the compensator gain. 
% By increasing the gain, you increase the bandwidth and speed up the response.

figure;
imshow("csd_watertank_drag_bode.png")

% As you drag the Bode response upward, the app automatically updates the compensator and the associated response plots. 
% Also, when you release the plot, in the status bar, on the right side, the app displays the updated gain value.

% Increase the compensator gain until the step response meets the design requirements. 
% One potential solution is to set the gain to 1.7.

figure;
imshow("csd_watertank_graphical_result.png")

% At this gain value, the closed loop response has a:
% * Maximum overshoot of 4.74%.
% * Rise time of 4.36 seconds.

%%% Fine Tune Controller Using Compensator Editor
% To tune the parameters of your compensator directly, use the compensator editor. 
% In the Bode Editor, right-click the plot area, and select Edit Compensator.

% In the Compensator Editor dialog box, on the Parameter tab, tune the PID controller gains. 
% For more information on editing compensator parameters, see Tune Simulink Blocks Using Compensator Editor.

figure;
imshow("csd_compensator_editor.png")

% While the tuned compensator meets the design requirements, the settling time is over 30 seconds. 
% To improve the settling time, adjust the P and I parameters of the controller manually.

% For example, set the compensator parameters to:
% * P = 4
% * I = 0.1

% This compensator produces a closed-loop response with a:
% * Maximum overshoot of 0.206%.
% * Rise time of 1.74 seconds.
% * Settling time of around three seconds.

figure;
imshow("csd_watertank_final_result.png")

%%% Simulate Closed-Loop System in Simulink
% Validate your compensator design by simulating the nonlinear Simulink model with the tuned controller parameters.

% To write the tuned compensator parameters to the PID Controller block, in Control System Designer, on the Control System tab, click Update Blocks.

% In the Simulink model window, run the simulation.

% To view the closed-loop simulation output, double-click the Scope block.

figure;
imshow("csd_watertank_simulink_result.png")

% The closed-loop response of the nonlinear system satisfies the design requirements with a rise time of less than five seconds and minimal overshoot.

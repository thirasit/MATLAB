%% Root Locus Design
% Root locus design is a common control system design technique in which you edit the compensator gain, poles, and zeros in the root locus diagram.

% As the open-loop gain, k, of a control system varies over a continuous range of values, 
% the root locus diagram shows the trajectories of the closed-loop poles of the feedback system. 
% For example, in the following tracking system:

figure
imshow("csd_root_locus_intro.gif")

% P(s) is the plant, H(s) is the sensor dynamics, and k is an adjustable scalar gain The closed-loop poles are the roots of

figure
imshow("Opera Snapshot_2022-08-11_053007_www.mathworks.com.png")

% The root locus technique consists of plotting the closed-loop pole trajectories in the complex plane as k varies. 
% You can use this plot to identify the gain value associated with a desired set of closed-loop poles.

%%% Tune Electrohydraulic Servomechanism Using Root Locus Graphical Tuning
% This example shows how to design a compensator for an electrohydraulic servomechanism using root locus graphical tuning techniques.

%%% Plant Model
% A simple version of an electrohydraulic servomechanism model consists of
% - A push-pull amplifier (a pair of electromagnets)
% - A sliding spool in a vessel of high-pressure hydraulic fluid
% - Valve openings in the vessel to allow for fluid to flow
% - A central chamber with a piston-driven ram to deliver force to a load
% - A symmetrical fluid return vessel

figure
imshow("csd_root_locus_servo.gif")

% The force on the spool is proportional to the current in the electromagnet coil. 
% As the spool moves, the valve opens, allowing the high-pressure hydraulic fluid to flow through the chamber. 
% The moving fluid forces the piston to move in the opposite direction of the spool. 
% For more information on this model, including the derivation of a linearized model, see [1].

% You can use the input voltage to the electromagnet to control the ram position. 
% When measurements of the ram position are available, you can use feedback for the ram position control, 
% as shown in the following, where Gservo represents the servomechanism:

figure
imshow("csd_root_locus_feedback.gif")

%%% Design Requirements
% For this example, tune the compensator, C(s) to meet the following closed-loop step response requirements:
% - The 2% settling time is less than 0.05 seconds.
% - The maximum overshoot is less than 5%.

%%% Open Control System Designer
% At the MATLAB® command line, load a linearized model of the servomechanism, 
% and open Control System Designer in the root locus editor configuration.

load ltiexamples Gservo
controlSystemDesigner('rlocus',Gservo);

% The app opens and imports Gservo as the plant model for the default control architecture, Configuration 1.
% In Control System Designer, a Root Locus Editor plot and input-output Step Response open.
% To view the open-loop frequency response and closed-loop step response simultaneously, click and drag the plots to the desired location.
% The app displays Bode Editor and Step Response plots side-by-side.

figure
imshow("csd_root_locus_side_by_side.png")

% In the closed-loop step response plot, the rise time is around two seconds, which does not satisfy the design requirements.
% To make the root locus diagram easier to read, zoom in. In the Root Locus Editor, right-click the plot area and select Properties.
% In the Property Editor dialog box, on the Limits tab, specify Real Axis and Imaginary Axis limits from -500 to 500.

figure
imshow("csd_root_locus_set_limits.png")

% Click Close.

%%% Increase Compensator Gain
% To create a faster response, increase the compensator gain. 
% In the Root Locus Editor, right-click the plot area and select Edit Compensator.
% In the Compensator Editor dialog box, specify a gain of 20.

figure
imshow("csd_root_locus_set_gain.png")

% In the Root Locus Editor plot, the closed-loop pole locations move to reflect the new gain value. Also, the Step Response plot updates.

figure
imshow("csd_root_locus_gain_result.png")

% The closed-loop response does not satisfy the settling time requirement and exhibits unwanted ringing.
% Increasing the gain makes the system underdamped and further increases lead to instability. 
% Therefore, to meet the design requirements, you must specify additional compensator dynamics. 
% For more information on adding and editing compensator dynamics, see Edit Compensator Dynamics.

%%% Add Poles to Compensator
% To add a complex pole pair to the compensator, in the Root Locus Editor, right-click the plot area and select Add Pole/Zero > Complex Pole. 
% Click the plot area where you want to add one of the complex poles.

figure
imshow("csd_root_locus_add_pole.png")

% The app adds the complex pole pair to the root locus plot as red X’s, and updates the step response plot.
% In the Root Locus Editor, drag the new poles to locations near –140 ± 260i. 
% As you drag one pole, the other pole updates automatically.

figure
imshow("csd_root_locus_drag_poles.png")

%%% Add Zeros to Compensator
% To add a complex zero pair to your compensator, in the Compensator Editor dialog box, 
% right-click the Dynamics table, and select Add Pole/Zero > Complex Zero

figure
imshow("csd_root_locus_add_zeros.png")

% The app adds a pair of complex zeros at –1 ± i to your compensator
% In the Dynamics table, click the Complex Zero row. 
% Then in the Edit Selected Dynamics section, specify a Real Part of -170 and an Imaginary Part of 430.

figure
imshow("csd_root_locus_edit_zeros.png")

% The compensator and response plots automatically update to reflect the new zero locations.

figure
imshow("csd_root_locus_zeros_result.png")

% In the Step Response plot, the settling time is around 0.1 seconds, which does not satisfy the design requirements.

%%% Adjust Pole and Zero Locations
% The compensator design process can involve some trial and error. 
% Adjust the compensator gain, pole locations, and zero locations until you meet the design criteria.

% One possible compensator design that satisfies the design requirements is:
% - Compensator gain of 10
% - Complex poles at –110 ± 140i
% - Complex zeros at –70 ± 270i

% In the Compensator Editor dialog box, configure your compensator using these values. 
% In the Step Response plot, the settling time is around 0.05 seconds.

figure
imshow("csd_root_locus_edit_pz_result.png")

% To verify the exact settling time, right-click the Step Response plot area and select Characteristics > Settling Time. 
% A settling time indicator appears on the response plot.

% To view the settling time, move the cursor over the settling time indicator.

figure
imshow("csd_root_locus_settling_time.png")

% The settling time is about 0.043 seconds, which satisfies the design requirements.

%% References
% [1] Clark, R. N. Control System Dynamics, Cambridge University Press, 1996.

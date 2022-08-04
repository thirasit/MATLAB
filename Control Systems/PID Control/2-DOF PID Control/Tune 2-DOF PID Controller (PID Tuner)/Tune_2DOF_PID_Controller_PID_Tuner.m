%% Tune 2-DOF PID Controller (PID Tuner)

% This example shows how to design a two-degree-of-freedom (2-DOF) PID controller using PID Tuner. 
% The example also compares the 2-DOF controller performance to the performance achieved with a 1-DOF PID controller.

% In this example, you represent the plant as an LTI model. 
% For information about using PID Tuner to tune a PID Controller (2DOF) block in a Simulink® model, see Design Two-Degree-of-Freedom PID Controllers (Simulink Control Design).

% 2-DOF PID controllers include setpoint weighting on the proportional and derivative terms. 
% Compared to a 1-DOF PID controller, a 2-DOF PID controller can achieve better disturbance rejection without significant increase of overshoot in setpoint tracking. 
% A typical control architecture using a 2-DOF PID controller is shown in the following diagram.

figure
imshow("pidtuning3.png")

% For this example, first design a 1-DOF controller for the plant given by:

figure
imshow("Opera Snapshot_2022-08-04_132630_www.mathworks.com.png")

G = tf(1,[1 0.5 0.1]);
pidTuner(G,'PID')

% Suppose for this example that your application requires a faster response than the PID Tuner initial design. 
% In the text box next to the Response Time slider, enter 2.

figure
imshow("pidtuner_2dof_2.png")

% The resulting response is fast, but has a considerable amount of overshoot. 
% Design a 2-DOF controller to improve the overshoot. 
% First, set the 1-DOF controller as the baseline controller for comparison. 
% Click the Export arrow  and select Save as Baseline.

figure
imshow("pidtuner_2dof_3.png")

% Design the 2-DOF controller. In the Type menu, select PID2.

figure
imshow("pidtuner_2dof_4.png")

% PID Tuner generates a 2-DOF controller with the same target response time. 
% The controller parameters displayed at the bottom right show that PID Tuner tunes all controller coefficients, 
% including the setpoint weights b and c, to balance performance and robustness. 
% Compare the 2-DOF controller performance (solid line) with the performance of the 1-DOF controller that you stored as the baseline (dotted line).

figure
imshow("pidtuner_2dof_5.png")

% Adding the second degree of freedom eliminates the overshoot in the reference tracking response. 
% Next, add a step response plot to compare the disturbance rejection performance of the two controllers. 
% Select Add Plot > Input Disturbance Rejection.

figure
imshow("pidtuner_2dof_6.png")

% You can move the plots in the PID Tuner such that the disturbance-rejection plot side by side with the reference-tracking plot.

figure
imshow("pidtuner_2dof_7.png")

% The disturbance-rejection performance is identical with both controllers. 
% Thus, using a 2-DOF controller eliminates reference-tracking overshoot without any cost to disturbance rejection.

% You can improve disturbance rejection too by changing the PID Tuner design focus. 
% First, click the Export arrow  and select Save as Baseline again to set the 2-DOF controller as the baseline for comparison.

% Change the PID Tuner design focus to favor reference tracking without changing the response time or the transient-behavior coefficient. 
% To do so, click  Options, and in the Focus menu, select Input disturbance rejection.

figure
imshow("pidtuner_designfocus.png")

% PID Tuner automatically retunes the controller coefficients with a focus on disturbance-rejection performance.

figure
imshow("pidtuner_2dof_8.png")

% With the default balanced design focus, PID Tuner selects a b value between 0 and 1. 
% For this plant, when you change design focus to favor disturbance rejection, PID Tuner sets b = 0 and c = 0. 
% Thus, PID Tuner automatically generates an I-PD controller to optimize for disturbance rejection. 
% (Explicitly specifying an I-PD controller without setting the design focus yields a similar controller.)

% The response plots show that with the change in design focus, the disturbance rejection is further improved compared to the balanced 2-DOF controller. 
% This improvement comes with some sacrifice of reference-tracking performance, which is slightly slower. 
% However, the reference-tracking response still has no overshoot.

% Thus, using 2-DOF control can improve disturbance rejection without sacrificing as much reference tracking performance as 1-DOF control. 
% These effects on system performance depend strongly on the properties of your plant and the speed of your controller. 
% For some plants and some control bandwidths, using 2-DOF control or changing the design focus has less or no impact on the tuned result.

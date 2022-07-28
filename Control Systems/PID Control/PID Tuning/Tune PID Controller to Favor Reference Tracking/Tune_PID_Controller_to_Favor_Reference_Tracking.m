%% Tune PID Controller to Favor Reference Tracking or Disturbance Rejection (PID Tuner)

% This example shows how to tune a PID controller to reduce overshoot in reference tracking or to improve rejection of a disturbance at the plant input. 
% Using the PID Tuner app, the example illustrates the tradeoff between reference tracking and disturbance-rejection performance in PI and PID control systems.

% In this example, you represent the plant as an LTI model. 
% For information about using PID Tuner to tune a PID Controller block in a Simulink® model, 
% see Tune PID Controller to Favor Reference Tracking or Disturbance Rejection (Simulink Control Design).

% Consider the control system of the following illustration.
figure
imshow("pidtuner6.png")

% The plant in this example is:
figure
imshow("Opera Snapshot_2022-07-28_203132_www.mathworks.com.png")

% Reference tracking is the response at y to signals at r. 
% Disturbance rejection is a measure of the suppression at y of signals at d. 
% When you use PID Tuner to tune the controller, 
% you can adjust the design to favor reference tracking or disturbance rejection as your application requires.

%%% Design Initial PI Controller

% Having an initial controller design provides a baseline against which you can compare results as you tune a PI controller. 
% Create an initial PI controller design for the plant using PID tuning command pidtune.

G = tf(0.3,[1,0.1,0]);    % plant model
C = pidtune(G,'PI');

% Use the initial controller design to open PID Tuner.

pidTuner(G,C)

% Add a step response plot of the input disturbance rejection. 
% Select Add Plot > Input Disturbance Rejection.
figure
imshow("tspidtuner7a.png")

% PID Tuner tiles the disturbance-rejection plot side by side with the reference-tracking plot.
figure
imshow("tspidtuner8.png")

% By default, for a given bandwidth and phase margin, PID Tuner tunes the controller to achieve a balance between reference tracking and disturbance rejection. 
% In this case, the controller yields some overshoot in the reference-tracking response. 
% The controller also suppresses the input disturbance with a longer settling time than the reference tracking, after an initial peak.

%%% Adjust Transient Behavior
% Depending on your application, you might want to alter the balance between reference tracking and disturbance rejection to favor one or the other. 
% For a PI controller, you can alter this balance using the Transient Behavior slider. 
% Move the slider to the left to improve the disturbance rejection. 
% The responses with the initial controller design are now displayed as the Baseline response (dotted line).
figure
imshow("tspidtuner9.png")

% Lowering the transient-behavior coefficient to 0.45 speeds up disturbance rejection, but also increases overshoot in the reference-tracking response. 

% Move the Transient behavior slider to the right until the overshoot in the reference-tracking response is minimized.
figure
imshow("tspidtuner9a.png")

% Increasing the transient-behavior coefficient to 0.70 nearly eliminates the overshoot, 
% but results in extremely sluggish disturbance rejection. 
% You can try moving the Transient behavior slider until you find a balance between reference tracking and disturbance rejection that is suitable for your application. 
% The effect that changing the slider has on the balance depends on the plant model. 
% For some plant models, the effect is not as large as shown in this example.

%%% Change PID Tuning Design Focus
% So far, the response time of the control system has remained fixed while you have changed the transient-behavior coefficient. 
% These operations are equivalent to fixing the bandwidth and varying the target minimum phase margin of the system. 
% If you want to fix both the bandwidth and target phase margin, you can still change the balance between reference tracking and disturbance rejection. 
% To tune a controller that favors either disturbance rejection or reference tracking, you change the design focus of the PID tuning algorithm.

% Changing the PID Tuner design focus is more effective the more tunable parameters there are in the control system. 
% Therefore, it does not have much effect when used with a PI controller. 
% To see its effect, change the controller type to PIDF. 
% In the Type menu, select PIDF.
figure
imshow("tspidtuner10.png")

% PID Tuner automatically designs a controller of the new type, PIDF. 
% Move the Transient Behavior slider to set the coefficient back to 0.6.

% Save this new design as the baseline design, by clicking the Export arrow and selecting Save as Baseline.
figure
imshow("tspidtuner10a.png")

% The PIDF design replaces the original PI design as the baseline plot.

% As in the PI case, the initial PIDF design balances reference tracking and disturbance rejection. 
% Also as in the PI case, the controller yields some overshoot in the reference-tracking response, 
% and suppresses the input disturbance with a similar settling time.
figure
imshow("tspidtuner11.png")

% Change the PID Tuner design focus to favor reference tracking without changing the response time or the transient-behavior coefficient. 
% To do so, click Options, and in the Focus menu, select Reference tracking.
figure
imshow("tspidtuner12.png")

% PID Tuner automatically retunes the controller coefficients with a focus on reference-tracking performance.
figure
imshow("tspidtuner13.png")

% The PIDF controller tuned with reference-tracking focus is displayed as Tuned response (solid line). 
% The plots show that the resulting controller tracks the reference input with considerably less overshoot and 
% a faster settling time than the balanced controller design. 
% However, the design yields much poorer disturbance rejection.

% Change the design focus to favor disturbance rejection. 
% In the Options dialog box, in the Focus menu, select Input disturbance rejection.
figure
imshow("tspidtuner14.png")

% This controller design yields improved disturbance rejection, 
% but results in some increased overshoot in the reference-tracking response.

% When you use design focus option, you can still adjust the Transient Behavior slider for further fine-tuning of the balance between the two measures of performance. 
% Use the design focus and the sliders together to achieve the performance balance that best meets your design requirements. 
% The effect of this fine tuning on system performance depends strongly on the properties of your plant. 
% For some plants, moving the Transient Behavior slider or changing the Focus option has little or no effect.

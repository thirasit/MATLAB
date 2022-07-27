%% PID Controller Design for Fast Reference Tracking

% This example shows how to use PID Tuner to design a controller for the plant:
figure
imshow("Opera Snapshot_2022-07-27_203218_www.mathworks.com.png")

% The design requirements are for the closed loop system to track a reference input with a rise time less than 1.5 s, 
% and settling time less than 6 s.

% In this example, you represent the plant as an LTI model. 
% For information about using PID Tuner to tune a PID Controller block in a Simulink® model, 
% see Tune PID Controller to Favor Reference Tracking or Disturbance Rejection (Simulink Control Design).

% 1. Create the plant model and open PID Tuner to design a PI controller for a first pass design.
sys = zpk([],[-1 -1 -1],1); 
pidTuner(sys,'pi')

% When you open PID Tuner, it automatically designs a controller of the type you specify (here, PI). 
% The controller is designed for a balance between performance (response time) and robustness (stability margins). 
% PID Tuner displays the closed-loop step response of the system with the designed controller.

% 2. Examine the reference tracking rise time and settling time.
% Right-click on the plot and select Characteristics > Rise Time to mark the rise time as a blue dot on the plot. 
% Select Characteristics > Settling Time to mark the settling time. 
% To see tool-tips with numerical values, click each of the blue dots.
figure
imshow("tspidtuner1a.png")

% The initial PI controller design provides a rise time of 2.35 s and settling time of 10.7 s. 
% Both results are slower than the design requirements.

% 3. Slide the Response time slider to the right to try to improve the loop performance. 
% The response plot automatically updates with the new design.
figure
imshow("tspidtuner3.png")

% Moving the Response time slider far enough to meet the rise time requirement of less than 1.5 s results in more oscillation. 
% Additionally, the parameters display shows that the new response has an unacceptably long settling time.
figure
imshow("tspidtuner3a.png")

% To achieve the faster response speed, the algorithm must sacrifice stability.

% 4. Change the controller type to improve the response.
% Adding derivative action to the controller gives PID Tuner more freedom to achieve adequate phase margin with the desired response speed.
% In the Type menu, select PIDF. PID Tuner designs a new PIDF controller. 
% (See PID Controller Type for more information about available controller types.)
figure
imshow("tspidtuner4.png")

% The rise time and settling time now meet the design requirements. 
% You can use the Response time slider to make further adjustments to the response. 
% To revert to the default automated tuning result, click Reset Design.

% 5. Analyze other system responses, if appropriate.
% To analyze other system responses, click Add Plot. 
% Select the system response you want to analyze.
figure
imshow("pidtuner_addplot1.png")

% For example, to observe the closed-loop step response to disturbance at the plant input, 
% in the Step section of the Add Plot menu, select Input disturbance rejection. 
% The disturbance rejection response appears in a new figure.
figure
imshow("tspidtuner5.png")

% See Analyze Design in PID Tuner for more information about available response plots.

% 6. Export your controller design to the MATLAB workspace.
% To export your final controller design to the MATLAB workspace, click Export. PID Tuner exports the controller as a
% - pid controller object, if the Form is Parallel
% - pidstd controller object, if the Form is Standard
% Alternatively, you can export a model using the right-click menu in the Data Browser. To do so, click the Data Browser tab.
figure
imshow("tunerestim8.png")

% Then, right-click the model and select Export.
figure
imshow("pid_tuner_export_rtclick.png")

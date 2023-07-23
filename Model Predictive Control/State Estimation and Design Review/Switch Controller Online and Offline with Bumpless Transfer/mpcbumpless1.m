%% Switch Controller Online and Offline with Bumpless Transfer
% This example shows how to obtain bumpless transfer when switching a model predictive controller from manual to automatic operation or vice versa.

% During the startup of a manufacturing process, before switching to automatic control, operators often adjust key actuators manually until the plant is near the desired operating point.
% If not done correctly, the transfer can cause a bump; that is, a large actuator movement, which might be unsafe or undesirable.

% In this example, you simulate a Simulink® model that contains a single-input single-output LTI plant and an MPC Controller block.

% The model predictive controller monitors all known plant signals, even when it is not in control of the actuators.
% This continuous monitoring improves the quality of its state estimates and allows a bumpless transfer to automatic operation.

% In particular, since the last used value of the control signal is a part of the internal controller state, you must use MPC block ext.mv input signal to keep the internal MPC state up to date when the operator (or another controller) is in control of the plant.

%%% Define Plant Model
% Define a linear open-loop dynamic plant model.
num = [1 1];
den = [1 3 2 0.5];
sys = tf(num,den);

% The plant is a stable single-input single-output system as seen in its step response.
figure
step(sys)

%%% Design MPC Controller
% Create an MPC controller, specifying the:
% - Plant model
% - Sample time (0.5 time units).
% - Prediction horizon 15 steps.
% - Control horizon 2 steps.
mpcobj = mpc(sys,0.5,15,2);

% Define constraints on the manipulated variable.
mpcobj.MV = struct('Min',-1,'Max',1);

% Specify the output tuning weight.
mpcobj.Weights.Output = 0.01;

%%% Open and Configure Simulink Model
% Open the Simulink model.
mdl = 'mpc_bumpless';
open_system(mdl)

figure
imshow("mpcbumpless_02.png")
axis off;

% In this model, the MPC Controller block is already configured for bumpless transfer using the following controller parameter settings.

% - The External manipulated variable parameter in the MPC Controller block is selected. This parameter adds the ext.mv inport to the block, thereby allowing the block to monitor an external control signal.
% - The Use external signal to enable or disable optimization parameter in the MPC Controller block is selected. This parameter adds a switch inport to switch off the controller optimization calculations when they are not needed.

% To achieve bumpless transfer, the initial states of your plant and controller must be the same, which is the case for the plant and controller in this example.
% However, if the initial conditions for your system do not match, you can set the initial states of the controller to the plant initial states.
% To do so, obtain an mpcstate handle object pointing to the internal state of your controller and set the initial controller state to the one of the plant.

%stateobj = mpcstate(MPC1);
%stateobj.Plant = x0;

% where x0 is a vector of the initial plant states.
% Then, set the Initial Controller State parameter of the MPC Controller block to stateobj.

% To simulate switching between manual and automatic operation, the Switching Signal block sends either 1 or 0 to control a switch.
% When it sends 0, the system is in automatic mode, and the output from the MPC Controller block goes to the plant.
% Otherwise, the system is in manual mode, and the signal from the Operator Commands block goes to the plant.

% In both cases, the actual plant input feeds back to the controller ext.mv inport, unless the plant input saturates at -1 or 1.
% The controller constantly monitors the plant output and updates its estimate of the plant state, even when in manual operation.

% This model also shows the optimization switching option.
% When the system switches to manual operation, a nonzero signal enters the switch inport of the controller block.
% This nonzero signal turns off the optimization calculations of the controller, which reduces computational effort.

%%% Simulate Controller in Simulink
% Simulate closed-loop control of the linear plant model in Simulink.
sim(mdl)

% open the scope blocks windows
open_system([mdl '/Yplots'])
open_system([mdl '/MVplots'])

figure
imshow("mpcbumpless_03.png")
axis off;

figure
imshow("mpcbumpless_04.png")
axis off;

% For the first 90 time units, the Switching Signal is 0, which makes the system operate in automatic mode.
% During this time, the controller smoothly drives the controlled plant output from its initial value, 0, to the desired reference value, -0.5.

% The controller state estimator has zero initial conditions as a default, which is appropriate when this simulation begins.
% Thus, there is no bump at startup.
% In general, when the system starts in manual mode, it is good practice to let it run long enough so that the controller can converge to an accurate state estimate before switching to automatic mode.

% At time 90, the Switching Signal changes to 1.
% This change switches the system to manual operation and sends the operator commands to the plant.
% Simultaneously, the nonzero signal entering the switch inport of the controller turns off the optimization calculations.

% While the optimization is turned off, the MPC Controller built-in estimator continues to use the plant output measurement, together with the last value of the manipulated variable (that is the ext.mv signal), to estimate the plant state.
% The MPC Controller block also passes ext.mv to the controller output port.

% Once in manual mode, the Operator Commands block sets the manipulated variable to -0.5 for 10 time units, and then to 0.
% The Plant Output plot shows the open-loop response between times 90 and 180 when the controller is deactivated.

% At time 180, the system switches back to automatic mode.
% As a result, the plant output returns to the reference value smoothly, and a similar smooth adjustment occurs in the controller output.

%%% Turn Off Manipulated Variable Feedback
% To examine the controller behavior without manipulated variable feedback, modify the model as follows:
% - Delete the signals entering the ext.mv and switch inports of the MPC Controller block.
% - Delete the Unit Delay block and the signal line entering its inport.
% - For the MPC Controller block, clear the External manipulated variable and Use external signal to enable or disable optimization parameters.
% To perform these steps programmatically, use the following commands.
delete_line(mdl,'Switch/1','Unit Delay/1');
delete_line(mdl,'Unit Delay/1','MPC Controller/3');
delete_block([mdl '/Unit Delay']);
delete_line(mdl,'Switching Signal/1','MPC Controller/4');
set_param([mdl '/MPC Controller'],'mv_inport','off');
set_param([mdl '/MPC Controller'],'switch_inport','off');

figure
imshow("xxmpcbumpless_no_ext_mv.png")
axis off;

% Adjust the limits of the response plots, and simulate the model.
set_param([mdl '/Yplots'],'Ymin','-1.1~-0.1')
set_param([mdl '/Yplots'],'Ymax','2~1.1')
set_param([mdl '/MVplots'],'Ymin','-0.6~-0.5')
set_param([mdl '/MVplots'],'Ymax','1.1~1.1')
sim(mdl)

figure
imshow("mpcbumpless_05.png")
axis off;

figure
imshow("mpcbumpless_06.png")
axis off;

% The behavior of the system is identical to the original case for the first 90 time units.

% When the system switches to manual mode at time 90, the plant behavior is the same as before.
% However, the controller keeps on calculating the control input necessary to hold the plant at the setpoint.
% Therefore, the manipulated variable keeps on increasing and eventually saturates, as seen in the Controller Output scope.
% Furthermore, since the controller assumes that its output is going to the plant, its state estimates become inaccurate.
% Therefore, when the system switches back to automatic mode at time 180, there is a large bump in the actuator movement within the plant, as seen in the Plant Output scope.

% By using the controller ext.mv input signal to keep the internal MPC state updated when the controller does not operate on the plant, you can enable a smooth transfer from manual to automatic operation, and therefore eliminate unwanted actuator movements.
bdclose(mdl)

%% Monitoring Optimization Status to Detect Controller Failures
% This example shows how to use the qp.status outport of the MPC Controller block in Simulink® to detect controller failures in real time.

%%% Overview of Run-Time Control Monitoring
% The qp.status output from the MPC Controller block returns a positive integer when the controller finds an optimal control action by solving a quadratic programming (QP) problem.
% The integer value corresponds to the number of iterations used during optimization.
% If the QP problem formulated at a given sample interval is infeasible, the controller will fail to find a solution.
% In that case, the MV outport of controller block retains the most recent value and the qp.status outport returns -1.
% In a rare case when the maximum number of iteration is reached during optimization, the qp.status outport returns 0.

% In industrial MPC applications, you can detect whether your model predictive controller is in a failure mode (0 or -1) or not by monitoring the qp.status outport.
% If an MPC failure occurs, you can use this signal to switch to a backup control plan.

% For more information, see Lane Keeping Assist System and the Optimizer options in the mpc.

% This example shows how to setup run-time controller status monitoring in Simulink.

%%% Define Plant Model
% The test plant is a single-input, single-output plant with hard limits on both manipulated variable and controlled output.
% A load disturbance is added at the plant output.
% The disturbance consists of a ramp signal that saturates manipulated variable due to the hard limit on the MV.
% After saturation occurs, you lose the control degree of freedom and the disturbance eventually forces the output outside its upper limit.
% When that happens, the QP problem formulated by the model predictive controller at run-time becomes infeasible.

% Define the plant model as a simple SISO system with unity static gain.
plant = tf(1,[2 1]);

% Define the unmeasured load disturbance.
% The signal ramps up from 0 to 2 between 1 and 3 seconds, then ramps down from 2 to 0 between 3 and 5 seconds.
LoadDist = [0 0; 1 0; 3 2; 5 0; 7 0];

%%% Design MPC Controller
% Create an MPC object for plant with a sample time of 0.2 seconds.
mpcobj = mpc(plant, 0.2);

% Define hard constraints on plant input (MV) and output (OV).
% By default, all the MV constraints are hard and OV constraints are soft.
mpcobj.MV.Min = -1;
mpcobj.MV.Max = 1;
mpcobj.OV.Min = -1;
mpcobj.OV.Max = 1;

% Configure the upper and lower OV constraints as hard bounds.
mpcobj.OV.MinECR = 0;
mpcobj.OV.MaxECR = 0;

% Override the default estimator.
% This high-gain estimator improves detection of an impending constraint violation.
setEstimator(mpcobj,[],[0;1])

%%% Simulate Using Simulink
% Build the control system in a Simulink model and enable the qp.status outport from the controller block dialog.
% Its run-time value is displayed in a Simulink Scope block.
mdl = 'mpc_onlinemonitoring';
open_system(mdl)

figure
imshow("mpconlinemonitoring_01.png")
axis off;

% Simulate the closed-loop and display the response.
sim(mdl)
open_system([mdl '/Controller Status'])
open_system([mdl '/Response'])

figure
imshow("mpconlinemonitoring_02.png")
axis off;

figure
imshow("mpconlinemonitoring_03.png")
axis off;

% As shown in the response scope, the ramp-up disturbance signal causes the MV to saturate at its lower bound -1, which is the optimal solution for these situations.
% After the plant output exceeds the upper limit, at the next sampling interval (2.6 seconds), the controller realizes that it can no longer keep the output within bounds (because its MV is still saturated), so it signals controller failure due to an infeasible QP problem (-1 in the controller status scope).
% After the output comes back within bounds, the QP problem becomes feasible again (3.4 seconds).
% Once the MV is no longer saturated, normal control behavior returns.

% Close the Simulink model.
bdclose(mdl)

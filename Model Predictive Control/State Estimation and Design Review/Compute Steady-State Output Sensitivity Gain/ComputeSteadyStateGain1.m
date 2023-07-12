%% Compute Steady-State Output Sensitivity Gain
% This example shows how to analyze the steady-state performance of a model predictive controller using cloffset.
% This command assumes that no constraint is active, and calculates the steady-state output sensitivity matrix (also known as complementary sensitivity) of the closed loop, which is the DC gain matrix from the plant output disturbances (using a sustained 1-unit disturbance step) to the controlled plant outputs.
% When this matrix is zero the controller is able to reject constant output disturbances and track constant setpoint with zero offsets in steady-state.

% Define a state-space plant model with two inputs and two outputs.
% This plant represents the linearized model of a Continuously Stirred Tank Reactor (CSTR) where the manipulated variable (first input) is the coolant temperature, and the input disturbance (second input) is the concentration of the inflow reagent.
% Since the C matrix is a flipped identity, the first measured output is the temperature in the reactor, and the second one is the key reactant concentration.

% For more information see CSTR Model.
% Define CSTR plant as state space object
A = [-5 -0.3427; 47.68 2.785];
B = [0 1; 0.3 0];
C = [0 1; 1 0];
D = zeros(2,2);
CSTR = ss(A,B,C,D);

% Define input signals for MPC
CSTR.InputGroup.MV = 1;  % (K)
CSTR.InputGroup.UD = 2;  % (kmol/m^3)

% Create an MPC controller for the defined plant, with a sampling time of one second.
mpcobj = mpc(CSTR,1);

% As the last output line specifies, the cost function default output weights is 1 for the first output and 0 for the second one:
mpcobj.W.OutputVariables

% The software automatically adds an integrator as output disturbance model for each measured output, in order of decreasing output weight, unless this causes the plant state to become unobservable.
% For this plant, only an integrator on the first output is added:
getoutdist(mpcobj)

% Compute the closed-loop, steady-state output sensitivity gain matrix for the closed loop system.
SoDC = cloffset(mpcobj)

% SoDC(i,j) is the closed loop static gain from output disturbance j to controlled plant output i.
% The first column of SoDC shows that a disturbance applied to the first measured output (reactor temperature) only affects the second output (key reactant concentration).
% The second column shows that a disturbance applied to the second measured output passes unmitigated through the closed loop and is fully measured at the second plant output.
% In other words, while the closed loop is able to compensate for (and therefore track) a temperature disturbance (first output) it is not able to compensate for a disturbance in the key reactant concentration (second output).

% The fact that both entries in the first row of SoDC are zeros means that the controller is able to completely reject disturbances that affect this output (and therefore the tracking of any given setpoint reference on this output would be perfect).
% This happens because the cost function weight for the first output is nonzero, and because the built-in estimator includes the integrator added as disturbance model on the first output.

% On the other hand, since the cost function weight for the second output is 0, (and also because there is no integrator added as a disturbance model on this output) the controller does not try to reject disturbances affecting the second output, and this is reflected by the second row of SoDC.
% This also means that the controller would be unable to track any reference setpoint on this output.

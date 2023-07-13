%% Extract Controller
% This example shows how to obtain an LTI representation of an unconstrained MPC controller using ss.
% You can use this to analyze the frequency response and performance of the controller.

% Define a plant model.
% For this example, use the CSTR model described in Design Controller Using MPC Designer.

% Define CSTR plant as state space object
A = [-5 -0.3427; 47.68 2.785];
B = [0 1; 0.3 0];
C = [0 1; 1 0];
D = zeros(2,2);
CSTR = ss(A,B,C,D);

% Define inputs and outputs for MPC (also see setmpcsignals)
CSTR.InputGroup.MV = 1;     % coolant temperature (K)
CSTR.InputGroup.UD = 2;     % inflow reagent concentration (kmol/m^3)
CSTR.OutputGroup.MO = 1;    % reactor temperature (K)
CSTR.OutputGroup.UO = 2;    % key rectant concentration (kmol/m^3)

% Create an MPC controller for the defined plant using the same sample time, prediction horizon, and tuning weights described in Design MPC Controller at the Command Line.
mpcobj = mpc(CSTR,1,15);

mpcobj.W.ManipulatedVariablesRate = 0.3;
mpcobj.W.OutputVariables = [1 0];

% Compute the steady-state output sensitivity (also known as complementary sensitivity) gain matrix for the closed loop system.
DCgain = cloffset(mpcobj)

% Extract the LTI state-space representation of the controller.
MPCss = ss(mpcobj);

% Convert the original CSTR model to discrete-time using the same sample time of the MPC controller.
CSTRd = c2d(CSTR,MPCss.Ts);

% Create an LTI model of the closed-loop system using feedback.
% Use the manipulated variable and measured output for feedback, indicating that the feedback signal is added to the input (not subtracted).
% Subtracting the feedback signal from the input would lead to an unstable closed-loop system, because the MPC controller is designed using an additive feedback signal convention.
clsys = feedback(CSTRd,MPCss,1,1,1);

% You can then analyze the resulting feedback system.
% For example, verify that all closed-loop poles are within the unit circle.
poles = eig(clsys)

% Display the magnitude and damping of all the poles.
damp(clsys)

% Display the transmission zeros.
tzero(clsys)

% You can also and plot its singular values, or view the frequency responses of each channel.
sigma(clsys)

bode(clsys)

% Display the step responses of each channel.
step(clsys)

% Display the DC gain matrix (from the system input to the system output) of the closed loop system.
% This matrix is related to the steady state complementary sensitivity previously calculated with cloffset.
dcgain(clsys)

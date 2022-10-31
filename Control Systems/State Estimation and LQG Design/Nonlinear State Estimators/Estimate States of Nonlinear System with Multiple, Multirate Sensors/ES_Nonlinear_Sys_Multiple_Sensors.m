%% Estimate States of Nonlinear System with Multiple, Multirate Sensors

% This example shows how to perform nonlinear state estimation in Simulink™ for a system with multiple sensors operating at different sample rates. 
% The Extended Kalman Filter block in Control System Toolbox™ is used to estimate the position and velocity of an object using GPS and radar measurements.

%%% Introduction
% The toolbox has three Simulink blocks for nonlinear state estimation:
% - Extended Kalman Filter: Implements the first-order discrete-time extended Kalman filter algorithm.
% - Unscented Kalman Filter: Implements the discrete-time unscented Kalman filter algorithm.
% - Particle Filter: Implements a discrete-time particle filter algorithm.

% These blocks support state estimation using multiple sensors operating at different sample rates. A typical workflow for using these blocks is as follows:
% 1. Model your plant and sensor behavior using MATLAB or Simulink functions.
% 2. Configure the parameters of the block.
% 3. Simulate the filter and analyze results to gain confidence in filter performance.
% 4. Deploy the filter on your hardware. You can generate code for these filters using Simulink Coder™ software.

% This example uses the Extended Kalman Filter block to demonstrate the first two steps of this workflow. 
% The last two steps are briefly discussed in the Next Steps section. 
% The goal in this example is to estimate the states of an object using noisy measurements provided by a radar and a GPS sensor. 
% The states of the object are its position and velocity, which are denoted as xTrue in the Simulink model.

% If you are interested in the Particle Filter block, please see the example "Parameter and State Estimation in Simulink Using Particle Filter Block".

addpath(fullfile(matlabroot,'examples','control','main')) % add example data
open_system('multirateEKFExample');

figure
imshow("MultirateNonlinearStateEstimationInSimulinkExample_01.png")

%%% Plant Modeling
% The extended Kalman filter (EKF) algorithm requires a state transition function that describes the evolution of states from one time step to the next. The block supports the following two function forms:
% - Additive process noise: $x[k+1] = f(x[k], u[k]) + w[k]$
% - Nonadditive process noise: $x[k+1] = f(x[k], w[k], u[k])$

% Here f(..) is the state transition function, x is the state, and w is the process noise. 
% u is optional, and represents additional inputs to f, for instance system inputs or parameters. 
% Additive noise means that the next state $x[k+1]$ and process noise $w[k]$ are related linearly. 
% If the relationship is nonlinear, use the nonadditive form.

% The function f(...) can be a MATLAB Function that comply with the restrictions of MATLAB Coder™, or a Simulink Function block. 
% After you create f(...), you specify the function name and whether the process noise is additive or nonadditive in the Extended Kalman Filter block.

% The function f(...) can be a MATLAB Function that comply with the restrictions of MATLAB Coder™, or a Simulink Function block. 
% After you create f(...), you specify the function name and whether the process noise is additive or nonadditive in the Extended Kalman Filter block.

figure
imshow("MultirateNonlinearStateEstimationInSimulinkExamp.png")

% Here $k$ is the discrete-time index. 
% The state transition equation used is of the nonadditive form $\hat{x}[k+1] = A\hat{x}[k] + Gw[k]$, where $\hat{x}$ is the state vector, and $w$ is the process noise. 
% The filter assumes that $w$ is a zero-mean, independent random variable with known variance $E[ww^T]$. The A and G matrices are:

figure
imshow("MultirateNonlinearStateEstimationInSimulinkE (1).png")

% where $T_s$ is the sample time. 
% The third row of A and G model the east velocity as a random walk: $\hat{v}_e[k+1]=\hat{v}_e[k]+w_1[k]$. 
% In reality, position is a continuous-time variable and is the integral of velocity over time $\frac{d}{dt}\hat{x}_e=\hat{v}_e$. 
% The first row of A and G represent a discrete approximation to this kinematic relationship: $(\hat{x}_e[k+1]-\hat{x}_e[k])/T_s = (\hat{v}_e[k+1]+\hat{v}_e[k])/2$. 
% The second and fourth rows of A and G represent the same relationship between the north velocity and position. 
% This state transition model is linear, but the radar measurement model is nonlinear. 
% This nonlinearity necessitates the use of a nonlinear state estimator such as the extended Kalman filter.

% In this example you implement the state transition function using a Simulink Function block. To do so,
% - Add a Simulink Function block to your model from the Simulink/User-Defined Functions library
% - Click on the name shown on the Simulink Function block. Edit the function name, and add or remove input and output arguments, as necessary. 
% In this example the name for the state transition function is stateTransitionFcn. 
% It has one output argument (xNext) and two input arguments (x, w).

figure
imshow("xxSimulinkFunctionBlock.png")

% - Though it is not required in this example, you can use any signals from the rest of your Simulink model in the Simulink Function. To do so, add Inport blocks from the Simulink/Sources library. Note that these are different than the ArgIn and ArgOut blocks that are set through the signature of your function (xNext = stateTransitionFcn(x, w)).
% - In the Simulink Function block, construct your function utilizing Simulink blocks.
% - Set the dimensions for the input and output arguments x, w, and xNext in the Signal Attributes tab of the ArgIn and ArgOut blocks. The data type and port dimensions must be consistent with the information you provide in the Extended Kalman Filter block.

figure
imshow("xxArgInConfig.png")

% Analytical Jacobian of the state transition function is also implemented in this example. 
% Specifying the Jacobian is optional. 
% However, this reduces the computational burden, and in most cases increases the state estimation accuracy. 
% Implement the Jacobian function as a Simulink function because the state transition function is a Simulink function.

open_system('multirateEKFExample/Simulink Function - State Transition Jacobian');

figure
imshow("MultirateNonlinearStateEstimationInSimulinkE (2).png")

%%% Sensor modeling - Radar
% The Extended Kalman Filter block also needs a measurement function that describes how the states are related to measurements. The following two function forms are supported:
% - Additive measurement noise: $y[k] = h(x[k], u[k]) + v[k]$
% - Nonadditive measurement noise: $y[k] = h(x[k], v[k], u[k])$

% Here h(..) is the measurement function, and v is the measurement noise. 
% u is optional, and represents additional inputs to h, for instance system inputs or parameters. 
% These inputs can differ from the inputs in the state transition function.

% In this example a radar located at the origin measures the range and angle of the object at 20 Hz. 
% Assume that both of the measurements have about 5% noise. 
% This can be modeled by the following measurement equation:

figure
imshow("MultirateNonlinearStateEstimationInSimulinkE (3).png")

% Here $v_1[k]$ and $v_2[k]$ are the measurement noise terms, each with variance 0.05^2. 
% That is, most of the measurements have errors less than 5%. 
% The measurement noise is nonadditive because $v_1[k]$ and $v_2[k]$ are not simply added to the measurements, but instead they depend on the states x. 
% In this example, the radar measurement equation is implemented using a Simulink Function block.

open_system('multirateEKFExample/Simulink Function - Radar Measurements');

figure
imshow("MultirateNonlinearStateEstimationInSimulinkE (4).png")

%%% Sensor modeling - GPS
% A GPS measures the east and north positions of the object at 1 Hz. Hence, the measurement equation for the GPS sensor is:

figure
imshow("MultirateNonlinearStateEstimationInSimulinkE (5).png")

% Here $v_1[k]$ and $v_2[k]$ are measurement noise terms with the covariance matrix [10^2 0; 0 10^2]. 
% That is, the measurements are accurate up to approximately 10 meters, and the errors are uncorrelated. 
% The measurement noise is additive because the noise terms affect the measurements $y_{GPS}$ linearly.

% Create this function, and save it in a file named gpsMeasurementFcn.m. 
% When the measurement noise is additive, you must not specify the noise terms in the function. 
% You provide this function name and measurement noise covariance in the Extended Kalman Filter block.

type gpsMeasurementFcn

%%% Filter Construction
% Configure the Extended Kalman Filter block to perform the estimation. 
% You specify the state transition and measurement function names, initial state and state error covariance, and process and measurement noise characteristics.

% In the System Model tab of the block dialog, specify the following parameters:

%%%% State Transition
% 1. Specify the state transition function, stateTransitionFcn, in Function. Since you have the Jacobian of this function, select Jacobian, and specify the Jacobian function, stateTransitionJacobianFcn.
% 2. Select Nonadditive in the Process Noise drop-down list because you explicitly stated how the process noise impacts the states in your function.
% 3. Specify the process noise covariance as [0.2 0; 0 0.2]. As explained in the Plant Modeling section of this example, process noise terms define the random walk of the velocities in each direction. The diagonal terms approximately capture how much the velocities can change over one sample time of the state transition function. The off-diagonal terms are set to zero, which is a naive assumption that velocity variations in the north and east directions are uncorrelated.

%%%% Initialization
% 1. Specify your best initial state estimate in Initial state. In this example, specify [100; 100; 0; 0].
% 2. Specify your confidence in your state estimate guess in Initial covariance. In this example, specify 10. The software interprets this value as the true state values are likely to be within $\pm\sqrt{10}$ of your initial estimate. You can specify a separate value for each state by setting Initial covariance as a vector. You can specify cross-correlations in this uncertainty by specifying it as a matrix.

% Since there are two sensors, click Add Measurement to specify a second measurement function.

%%%% Measurement 1
% 1. Specify the name of your measurement function, radarMeasurementFcn, in Function.
% 2. Select Nonadditive in the Measurement Noise drop-down list because you explicitly stated how the process noise impacts the measurements in your function.
% 3. Specify the measurement noise covariance as [0.05^2 0; 0 0.05^2] per the discussion in the Sensor Modeling - Radar section.

%%%% Measurement 2
% 1. Specify the name of your measurement function, gpsMeasurementFcn, in Function.
% 2. This sensor model has additive noise. Therefore, specify the GPS measurement noise as Additive in the Measurement Noise drop-down list.
% 3. Specify the measurement noise covariance as [100 0; 0 100].

figure
imshow("xxekfMultirateExampleEKFBlockDialog1.png")

% In the Multirate tab, since the two sensors are operating at different sample rates, perform the following configuration:

% 1. Select Enable multirate operation.
% 2. Specify the state transition sample time. The state transition sample time must be the smallest, and all measurement sample times must be an integer multiple of the state transition sample time. Specify State Transition sample time as 0.05, the sample time of the fastest measurement. Though not required in this example, it is possible to have a smaller sample time for state transition than all measurements. This means there will be some sample times without any measurements. For these sample times the filter generates state predictions using the state transition function.
% 3. Specify the Measurement 1 sample time (Radar) as 0.05 seconds and Measurement 2 (GPS) as 1 seconds.

figure
imshow("xxekfMultirateExampleEKFBlockDialog2.png")

%%% Simulation and Results
% Test the performance of the Extended Kalman filter by simulating a scenario where the object travels in a square pattern with the following maneuvers:

% - At t = 0, the object starts at $x_e(0)=100\; \textnormal{[m]}, x_n(0)=100 \;\textnormal{[m]}$
% - It heads north at $\dot{x}_n=50\;\textnormal{[m/s]}$ until t = 20 seconds.
% - It heads east at $\dot{x}_n=40\;\textnormal{[m/s]}$ between t = 20 and t = 45 seconds.
% - It heads south at $\dot{x}_n=-25\;\textnormal{[m/s]}$ between t = 45 and t = 85 seconds.
% - It heads west at $\dot{x}_e=-10\;\textnormal{[m/s]}$ between t = 85 and t = 185 seconds.

% Generate the true state values corresponding to this motion:

Ts = 0.05; % [s] Sample rate for the true states
[t, xTrue] = generateTrueStates(Ts); % Generate position and velocity profile over 0-185 seconds

% Simulate the model. For instance, look at the actual and estimated velocities in the east direction:

sim('multirateEKFExample');
open_system('multirateEKFExample/Scope - East Velocity');

figure
imshow("MultirateNonlinearStateEstimationInSimulinkE (6).png")

% The plot shows the true velocity in the east direction, and its extended Kalman filter estimates. 
% The filter successfully tracks the changes in velocity. 
% The multirate nature of the filter is most apparent in the time range t = 20 to 30 seconds. 
% The filter makes large corrections every second (GPS sample rate), while the corrections due to radar measurements are visible every 0.05 seconds.

%%% Next Steps
% 1. Validate the state estimation: The validation of unscented and extended Kalman filter performance is typically done using extensive Monte Carlo simulations. For more information, see Validate Online State Estimation in Simulink.
% 2. Generate code: The Unscented and Extended Kalman Filter blocks support C and C++ code generation using Simulink Coder™ software. The functions you provide to these blocks must comply with the restrictions of MATLAB Coder™ software (if you are using MATLAB functions to model your system) and Simulink Coder software (if you are using Simulink Function blocks to model your system).

%%% Summary
% This example has shown how to use the Extended Kalman Filter block in System Identification Toolbox. You estimated position and velocity of an object from two different sensors operating at different sampling rates.

close_system('multirateEKFExample', 0);

%% Interactively Estimate Plant Parameters from Response Data

% This example shows how to use PID Tuner to fit a linear model to measured SISO response data.

% If you have System Identification Toolbox™ software, 
% you can use PID Tuner to estimate the parameters of a linear plant model based on time-domain response data measured from your system. 
% PID Tuner then tunes a PID controller for the resulting estimated model. 
% PID Tuner gives you several techniques to graphically, manually, or automatically adjust the estimated model to match your response data. 
% This example illustrates some of those techniques.

% In this example, you load measured response data from a data file into the MATLAB® workspace you represent the plant as an LTI model. 
% For information about generating simulated data from a Simulink® model, 
% see Interactively Estimate Plant from Measured or Simulated Response Data (Simulink Control Design).

%%% Import Response Data for Identification
% 1. Open PID Tuner and load measured response data into the MATLAB workspace.

pidTuner(tf(1),'PI')
load PIDPlantMeasuredIOData

% When you import response data, PID Tuner assumes that your measured data represents a plant connected to the PID controller in a negative-feedback loop. 
% In other words, PID Tuner assumes the following structure for your system. 
% PID Tuner assumes that you injected a step signal at the plant input u and measured the system response at y, as shown.

figure
imshow("pidtuner_iodata1.png")

% The sample data file for this example, contains three variables, each of which is a 501-by-1 array. 
% inputu is the unit step function injected at u to obtain the response data. outputy is the measured response of the system at y. 
% The time vector t, runs from 0 to 50 s with a 0.1 s sample time. 
% Comparing inputu to t shows that the step occurs at t = 5 s.

% 2. In PID Tuner, in the Plant menu, select Identify New Plant.

figure
imshow("tunerestim1.png")

% 3. In the Plant Identification tab, click Get I/O data and select Step Response. 
% This action opens the Import Step Response dialog box.

% Enter information about the response data. The output signal is the
% measured system response, outputy. The input step signal is parametrized
% as shown in the diagram in the dialog box. Here, enter 5 for the Onset Lag, and 0.1 for Sample Time. Then, click Import.

figure
imshow("tunerestim3.png")

% The Plant Identification plot displays the response data and the response of an initial estimated plant.

figure
imshow("tunerestim4.png")

%%% Preprocess Data

% Depending on the quality and features of your response data, 
% you might want to perform some preprocessing on the data to improve the estimated plant results. 
% PID Tuner provides several options for preprocessing response data, such as removing offsets, filtering, or extracting a subset of the data. 
% In this example, the response data has an offset. 
% It is important for good identification results to remove data offsets. 
% Use the Preprocess menu to do so. 
% (For information about other data preprocessing options, see Preprocess Data.)

% 1. On the Plant Identification tab, click Preprocess and select Remove Offset. 
% The Remove Offset tab opens, displaying time plots of the response data and corresponding input signal.

% 2. Select Remove offset from signal and choose the response, Output (y). 
% In the Offset to remove text box, specify a value of –2. 
% You can also select the signal initial value or signal mean, or enter a numerical value. 
% The plot updates with an additional trace showing the signal with the offset applied.

figure
imshow("tunerestim_offset.png")

% 3. Click Apply to save the change to the signal. Click  Close Remove Offset to return to the Plant Identification tab.
% PID Tuner automatically adjusts the plant parameters to create a new initial guess for the plant based on the preprocessed response signal.

%%% Adjust Plant Structure and Parameters

% PID Tuner allows you to specify a plant structure, such as One Pole, Underdamped Pair, or State-Space Model. 
% In the Structure menu, choose the plant structure that best matches your response. 
% You can also add a transport delay, a zero, or an integrator to your plant. 
% For this example, the one-pole structure gives the qualitatively correct response. 
% You can make further adjustments to the plant structure and parameter values to make the estimated system’s response a better match to the measured response data.

% PID Tuner gives you several ways to adjust the plant parameters:
% - Graphically adjust the response of the estimated system by dragging the adjustors on the plot. 
% In this example, drag the red x to adjust the estimated plant time constant. 
% PID Tuner recalculates system parameters as you do so. 
% As you change the estimated system’s response, 
% it becomes apparent that there is some time delay between the application of the step input at t = 5 s, and the response of the system to that step input.

figure
imshow("tunerestim6.png")

% To add a transport delay to the estimated plant model, in the Plant Structure section, check Delay. 
% A vertical line appears on the plot, indicating the current value of the delay. 
% Drag the line left or right to change the delay, and make further adjustments to the system response by dragging the red x.

% - Adjust the numerical values of system parameters such as gains, time constants, and time delays. 
% To numerically adjust the values of system parameters, click Edit Parameters.

% Suppose that you know from an independent measurement that the transport delay in your system is 1.5 seconds. 
% In the Plant Parameters dialog box, enter 1.5 for τ. Check Fix to fix the parameter value. 
% When you check Fix for a parameter, neither graphical nor automatic adjustments to the estimated plant model affect that parameter value.

figure
imshow("tunerestim7.png")

% - Automatically optimize the system parameters to match the measured response data. 
% Click Auto Estimate to update the estimated system parameters using the current values as an initial guess.

% You can continue to iterate using any of these methods to adjust plant structure and parameter values 
% until the response of the estimated system adequately matches the measured response.

%%% Save Plant and Tune PID Controller

% When you are satisfied with the fit, click Apply. 
% Doing so saves the estimated plant, Plant1, to the PID Tuner workspace. 
% PID Tuner automatically designs a PI controller for Plant1 and, in the Step Plot: Reference Tracking plot, displays a new closed-loop response. 
% The Plant List table reflects that Plant1 is selected for the current controller design.

figure
imshow("tunerestim9.png")

% You can now use the PID Tuner tools to refine the controller design for the estimated plant and examine tuned system responses.

% You can also export the identified plant from the PID Tuner workspace to the MATLAB workspace for further analysis. 
% On the PID Tuner tab, click Export. 
% Check the plant model you want to export to the MATLAB workspace. 
% For this example, export Plant1, the plant you identified from response data. 
% You can also export the tuned PID controller. 
% Click OK. The models you selected are saved to the MATLAB workspace.

% Identified plant models are saved as identified LTI models, such as idproc (System Identification Toolbox) or idss (System Identification Toolbox).

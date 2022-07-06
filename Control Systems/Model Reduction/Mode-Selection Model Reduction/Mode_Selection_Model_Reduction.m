%% Mode-Selection Model Reduction

% Model selection eliminates poles that fall outside a specific frequency range of interest. 
% This method is useful when you want to focus your analysis on a particular subset of system dynamics. 
% For instance, if you are working with a control system with bandwidth limited by actuator dynamics, 
% you might discard higher-frequency dynamics in the plant. 
% Eliminating dynamics outside the frequency range of interest reduces the numerical complexity of calculations with the model. 
% There are two ways to compute a reduced-order model by mode selection:

% - At the command line, using the freqsep command.
% - In the Model Reducer, using the Mode Selection method.
% - In the Reduce Model Order task in the Live Editor, using the Mode Selection method.

%%% Mode Selection in the Model Reducer App

% Model Reducer provides an interactive tool for performing model reduction and 
% examining and comparing the responses of the original and reduced-order models. 
% To approximate a model by mode selection in Model Reducer:

% 1. Open the app and import an LTI model to reduce. 
% For instance, suppose that there is a model named Gms in the MATLAB® workspace. 
% The following command opens Model Reducer and imports the model.

load modeselect Gms
modelReducer(Gms)

% 2. In the Data Browser, select the model to reduce. Click Mode Selection.

figure
imshow("mr_modsel1.png")

% In the Mode Selection tab, Model Reducer displays a plot of the frequency response of the original model and a reduced version of the model. 
% The app also displays a pole-zero map of both models.

figure
imshow("mr_modsel2.png")

% The pole-zero map marks pole locations with x and zero locations with o.

% Note - The frequency response is a Bode plot for SISO models, and a singular-value plot for MIMO models.

% 3. Model Reducer eliminates poles that lie outside the shaded region. 
% Change the shaded region to capture only the dynamics you want to preserve in the reduced model. 
% There are two ways to do so.

% - On either the response plot or the pole-zero map, drag the boundaries of the shaded region or the shaded region itself.
% - On the Mode Selection tab, enter lower and upper cutoff frequencies.

figure
imshow("mr_modsel3.png")

% When you change the shaded regions or cutoff frequencies, Model Reducer automatically computes a new reduced-order model. 
% All poles retained in the reduced model fall within the shaded region on the pole-zero map. 
% The reduced model might contain zeros that fall outside the shaded region.

% 4. Optionally, examine absolute or relative error between the original and simplified model. 
% Select the error-plot type using the buttons on the Mode Selection tab.

figure
imshow("mr_modsel4.png")

% 5. When you have one or more reduced models that you want to store and analyze further, click Create Reduced Model. 
% The new model appears in the Data Browser.

figure
imshow("mr_modsel5.png")

% After creating a reduced model in the Data Browser, 
% you can continue adjusting the mode-selection region to create reduced models with different orders for analysis and comparison.

% You can now perform further analysis with the reduced model. For example:

% - Examine other responses of the reduced system, such as the step response or Nichols plot. 
% To do so, use the tools on the Plots tab. 
% See Visualize Reduced-Order Models in the Model Reducer App for more information.

% - Export reduced models to the MATLAB workspace for further analysis or control design. 
% On the Model Reducer tab, click Export.

%%% Generate MATLAB Code for Mode Selection
% To create a MATLAB script you can use for further model-reduction tasks at the command line, click Create Reduced Model, and select Generate MATLAB Script.

figure
imshow("mr_codegen.png")

% Model Reducer creates a script that uses the freqsep command to perform model reduction with the parameters you have set on the Mode Selection tab. 
% The script opens in the MATLAB editor.

%%% Mode Selection at the Command Line

% To reduce the order of a model by mode selection at the command line, use freqsep. 
% This command separates a dynamic system model into slow and fast components around a specified frequency.

% For this example, load the model Gms and examine its frequency response.

figure
bodeplot(Gms)

% Gms has two sets of resonances, one at relatively low frequency and the other at relatively high frequency. 
% Suppose that you want to tune a controller for Gms, 
% but the actuator in your system is limited to a bandwidth of about 3 rad/s, 
% in between the two groups of resonances. 
% To simplify calculation and tuning using Gms, you can use mode selection to eliminate the high-frequency dynamics.

[Gms_s,Gms_f] = freqsep(Gms,30);

% freqsep decomposes Gms into slow and fast components such that Gms = Gms_s + Gms_f. 
% All modes (poles) with natural frequency less than 30 are in Gms_s, and the higher-frequency poles are in Gms_f.

figure
bodeplot(Gms,Gms_s,Gms_f)
legend('original','slow','fast')

% The slow component, Gms_s, contains only the lower-frequency resonances and matches the DC gain of the original model. 
% Examine the orders of both models.

order(Gms)

order(Gms_s)

% When the high-frequency dynamics are unimportant for your application, you can use the 10th-order Gms_s instead of the original 18th-order model. 
% If neglecting low-frequency dynamics is appropriate for your application, you can use Gms_f. 
% To select modes that fall between a low-frequency and a high-frequency cutoff, use additional calls to freqsep.

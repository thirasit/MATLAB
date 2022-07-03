%% Balanced Truncation Model Reduction

% Balanced truncation computes a lower-order approximation of your model by
% neglecting states that have relatively low effect on the overall model response. 
% Using a lower-order approximation that preserves the dynamics of interest
% can simplify analysis and control design. 
% In the balanced truncation method of model reduction, the software measures state
% contributions by Hankel singular values (see hsvd) and discards states with smaller values. 
% You can compute a reduced-order model by balanced truncation:

% - At the command line, using the balred command.
% - In the Model Reducer app, using the Balanced Truncation method.
% - In the Reduce Model Order task in the Live Editor, using the Balanced Truncation method.

%%% Balanced Truncation in the Model Reducer App

% Model Reducer provides an interactive tool for performing model reduction
% and examining and comparing the responses of the original and reduced-order models. 
% To approximate a model by balanced truncation in Model Reducer:

% 1. Open the app, and import an LTI model to reduce. 
% For instance, suppose that there is a model named build in the MATLAB® workspace. 
% The following command opens Model Reducer and imports the model.

load building.mat
build = G;
modelReducer(build)

% 2. In the Data Browser, select the model to reduce. Click Balanced Truncation.

figure
imshow("mr_baltrunc1.png")

% In the Balanced Truncation tab, Model Reducer displays a plot of the frequency response 
% of the original model and a reduced version of the model. 
% The frequency response is a Bode plot for SISO models, and a singular-value plot for MIMO models. 
% The app also displays a Hankel singular-value and approximation error plot of the original model.

figure
imshow("mr_baltrunc2.png")

% The Hankel singular-value plot shows the relative energy contributions of each state in the system.
% Model Reducer computes an initial reduced-order model based on these values. 
% The highlighted bar is the lowest-energy state in the initial reduced-order model. 
% Model Reducer discards states that have lower Hankel singular values than the highlighted bar.

% 3. Try different reduced-model orders to find the lowest-order model that preserves the dynamics 
% that are important for your application. To specify different orders, either:

% - Enter model orders in the Reduced orders field. You can enter a single integer or an array of integers, such as 10:14 or [8,11,12].
% - Click a bar on the Hankel singular-value plot to specify the lowest-energy state of the reduced-order model. Ctrl-click to specify multiple values.

% When you change the specified reduced model order, Model Reducer automatically computes a new reduced-order model. 
% If you specify multiple model orders, Model Reducer computes multiple reduced-order models and displays their responses on the plot.

figure
imshow("mr_baltrunc3.png")

% 4. Optionally, examine the absolute or relative error between the original and reduced-order model, 
% in addition to the frequency response. Select the error-plot type using the buttons on the Balanced Truncation tab.

figure
imshow("mr_baltrunc4.png")

% 5. If low-frequency dynamics are not important to your application, 
% you can clear the Preserve DC Gain checkbox. 
% Doing so sometimes yields a better match at higher frequencies between the original and reduced-order models.

figure
imshow("mr_baltrunc5.png")

% When you check or clear the Preserve DC Gain checkbox, Model Reducer automatically computes new reduced-order models.

% 6. Optionally, limit the Hankel singular-value computation to a specific frequency range. 
% Such a limit is useful when the model has modes outside the region of interest to your particular application. 
% When you apply a frequency limit, Model Reducer determines which states to truncate based on their energy contribution within the specified frequency range only. 
% Neglecting energy contributions outside that range can yield an even lower-order approximation that is still adequate for your application.

% To limit the singular-value computation, check Focus on range. Then, specify the frequency range by:
% - In the text box, entering a vector of the form [fmin,fmax]. Units are rad/TimeUnit, where TimeUnit is the TimeUnit property of the model you are reducing.
% - On the response plot or error plot, dragging the boundaries of the shaded region or the shaded region itself. Model Reducer analyzes the state contributions within the shaded region only.

figure
imshow("mr_baltrunc6.png")

% When you check or clear the Focus on range checkbox or change the selected range, Model Reducer automatically computes new reduced-order models.

%%% Note. - Checking Focus on range automatically clears Preserve DC Gain. 
%%% To enforce a DC match even when using frequency limits, recheck Preserve DC Gain. 
%%% Note that restricting the frequency range is not supported with relative error control.

% 7. You can choose between absolute and relative errors by selecting the appropriate option in Error Bound. Setting it to absolute controls the absolute error ‖G−G_r‖_∞
% while setting it to relative controls the relative error ‖G^−1(G−G_r)‖_∞. 
% Relative error gives a better match across frequency while absolute error emphasizes areas with most gain.

%%% Note. - Switching between Error Bound options automatically clears Preserve DC Gain and Focus on Range. 
%%% To enforce a DC match, recheck Preserve DC Gain. Note that restricting the frequency range is not supported with relative error control.

figure
imshow("mr_baltrunc8.png")

% 8. When you have one or more reduced models that you want to store and analyze further, click Create Reduced Model. 
% The new models appear in the Data Browser. 
% If you have specified multiple orders, each reduced model appears separately. 
% Model names reflect the reduced model order.

figure
imshow("mr_baltrunc7.png")

% After creating reduced models in the Data Browser, you can continue changing the reduction parameters and create reduced models with different orders for analysis and comparison.

% You can now perform further analysis with the reduced model. For example:
% - Examine other responses of the reduced system, such as the step response or Nichols plot. To do so, use the tools on the Plots tab. See Visualize Reduced-Order Models in the Model Reducer App for more information.
% - Export reduced models to the MATLAB workspace for further analysis or control design. On the Model Reducer tab, click Export.

%%% Generate MATLAB Code for Balanced Truncation
% To create a MATLAB script you can use for further model-reduction tasks at the command line, click Create Reduced Model, and select Generate MATLAB Script.

figure
imshow("mr_codegen.png")

% Model Reducer creates a script that uses the balred command to perform model reduction with the parameters and options you have set on the Balanced Truncation tab. The script opens in the MATLAB editor.


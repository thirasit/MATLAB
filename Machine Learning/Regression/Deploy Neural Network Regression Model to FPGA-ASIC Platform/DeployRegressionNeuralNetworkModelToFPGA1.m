%% Deploy Neural Network Regression Model to FPGA/ASIC Platform
% This example shows how to train a neural network regression model, use the trained regression model in a Simulink® model that estimates the state of charge of a battery, and generate HDL code from the Simulink model for deployment to an FPGA/ASIC (Field-Programmable Gate Array / Application-Specific Integrated Circuit) platform.

% State of charge (SoC) is the level of charge of an electric battery relative to its capacity, measured as a percentage.
% SoC is critical for a vehicle's energy management system.
% You cannot measure SoC directly; therefore, you must estimate it.
% The SoC estimation must be accurate to ensure reliable and affordable electrified vehicles (xEV).
% However, because of the nonlinear temperature, health, and SoC-dependent behavior of Li-ion batteries, SoC estimation remains a significant challenge in automotive engineering.
% Traditional approaches to this problem, such as electrochemical models, usually require precise parameters and knowledge of the battery composition and physical response.

% In contrast, modeling SoC with neural networks is a data-driven approach that requires minimal knowledge of the battery and its nonlinear characteristics [1].
% This example uses a neural network regression model to predict SoC from the battery's current, voltage, and temperature measurements [2].

% The Simulink model in this example includes a plant simulation of the battery and a battery management system (BMS).
% The BMS monitors the battery state, manages the battery temperature, and ensures safe operation.
% For example, the BMS helps to avoid overcharging and overdischarging.
% From the battery sensors, the BMS collects information on the current, voltage, and temperature in a closed-loop system.

figure
imshow("DeployRegressionNeuralNetworkModelToFPGAExample_01.png")
axis off;

%%% Train Regression Model at Command Line
% To begin, load the data set for this example.
% Then, train the regression model at the command line and evaluate the model performance.

%%% Load Data Set
% This example uses the batterySmall data set, which is a subset of the data set in [1].
% The batterySmall data set contains two tables: trainDataSmall (training data set) and testDataSmall (test data set).
% Both the training and test data sets have a balanced representation of various temperature ranges.
% In both data sets, the observations are normalized.

% Load the batterySmall data set.
load batterysmall.mat

% Display the first eight rows of the tables trainDataSmall and testDataSmall.
head(trainDataSmall)

head(testDataSmall)

% Both tables contain variables of battery sensor data: voltage (V), current (I), temperature (Temp), average voltage (V_avg), and average current (I_avg).
% Both tables also contain the state of charge (SoC) variable, which is represented by Y.

%%% Train Regression Model
% Train a neural network regression model by using the fitrnet function on the training data set.
% Specify the sizes of the hidden, fully connected layers in the neural network model.
nnetMdl = fitrnet(trainDataSmall,"Y",LayerSizes=[10,10]);

% nnetMdl is a RegressionNeuralNetwork model.

%%% Evaluate Model Performance
% Cross-validate the trained model using 5-fold cross-validation, and estimate the cross-validated classification accuracy.
partitionedModel = crossval(nnetMdl,KFold=5);
validationAccuracy = 1-kfoldLoss(partitionedModel)

% Calculate the test set accuracy to evaluate how well the trained model generalizes.
testAccuracy = 1-loss(nnetMdl,testDataSmall,"Y")

% The test set accuracy is larger than 99.9%, which confirms that the model does not overfit to the training set.

%%% Import Model to Simulink for Prediction
% This example provides the Simulink model slexFPGAPredictExample, which includes the RegressionNeuralNetwork Predict block, for estimating the battery SoC.
% The model also includes the measured SoC, so you can compare it to the estimated SoC.
figure
imshow("DeployRegressionNeuralNetworkModelToFPGAExample_02.png")
axis off;

%%% Load Data
% The batterySmall data set contains the dataLarge structure with the input data (X) and the measured SoC (Y).
% Use the X data to create the input data to the slexFPGAPredictExample model.

% Create an input signal (input) in the form of an array for the Simulink model.
% The first column of the array contains the timeVector variable, which includes the points in time at which the observations enter the model.
% The other five columns of the array contain variables of battery measurements.
timeVector = (0:length(dataLarge.X)-1)';
input = [timeVector,dataLarge.X];
measuredSOC = [timeVector dataLarge.Y];

% Load the minimum and maximum values of the raw input data used for denormalizing input.
minmaxData = load("MinMaxVectors");
X_MIN = minmaxData.X_MIN;
X_MAX = minmaxData.X_MAX;
stepSize = 10;

%%% Simulate Simulink Model
% Open the Simulink model slexFPGAPredictExample.
% Simulate the model and export the simulation output to the workspace.
open_system("slexFPGAPredictExample.slx")
simOut = sim("slexFPGAPredictExample.slx");

% Plot the simulated and measured values of the battery SoC.
sim_ypred = simOut.yout.get("estim").Values.Data;

figure
plot(simOut.tout,sim_ypred)
hold on
plot(dataLarge.Y)
hold off
legend("Simulated SoC","Measured SoC",location="northwest")

%%% Convert Simulink Model to Fixed-Point
% To deploy the Simulink model to FPGA or ASIC hardware with no floating-point support, you must convert the RegressionNeuralNetwork Predict block to fixed-point.
% You can convert the Neural Network subsystem to fixed-point by using the Use the Fixed-Point Tool to Rescale a Fixed-Point Model (Fixed-Point Designer).
% You can also specify the fixed-point values directly using the Data Type tab of the RegressionNeuralNetwork Predict block dialog box.
% For more details on how to convert to fixed-point, see Human Activity Recognition Simulink Model for Fixed-Point Deployment.

% Open the Simulink model slexFPGAPredictFixedPointExample, which is already converted to fixed-point.
% Simulate the fixed-point Simulink model and export the simulation output to the workspace.
open_system("slexFPGAPredictFixedPointExample.slx")
simOutFixedPoint = sim("slexFPGAPredictFixedPointExample.slx");

% Compare the simulation results for the floating-point (soc_dl) and fixed-point (soc_fp) estimation of the battery SoC.
soc_dl_sig = simOut.yout.getElement(1);
soc_fp_sig = simOutFixedPoint.yout.getElement(1);
soc_dl = soc_dl_sig.Values.Data;
soc_fp = soc_fp_sig.Values.Data;
max(abs(soc_dl-soc_fp)./soc_dl)

% This result shows less than a 4% difference between floating-point and fixed-point values for the SoC estimation.

%%% Prepare Simulink Model for HDL Code Generation
% To prepare the RegressionNeuralNetwork Predict block for HDL code generation, open and run HDL Code Advisor.
% For more information, see Check HDL Compatibility of Simulink Model Using HDL Code Advisor (HDL Coder).

% Open HDL Code Advisor by right-clicking the neural network subsystem and selecting HDL Code > HDL Code Advisor.
% Alternatively, you can enter:
open_system("slexFPGAPredictFixedPointExample.slx")
hdlcodeadvisor("slexFPGAPredictFixedPointExample/Neural Network")

figure
imshow("DeployRegressionNeuralNetworkModelToFPGAExample_04.png")
axis off;

% In HDL Code Advisor, the left pane lists the folders in the hierarchy.
% Each folder represents a group or category of related checks.
% Expand the folders to see the available checks in each group.
% Make sure that all the checks are selected in the left pane, and then click Run Selected Checks in the right pane.
% If HDL Code Advisor returns a failure or a warning, the corresponding folder is marked accordingly.
% Expand each group to view the checks that failed.
% To fix a failure, click Run This Check in the right pane.
% Then, click Modify Settings.
% Click Run This Check again after you apply the modified settings.
% Repeat this process for each failed check in the following lists.
% Failed checks in the Industry standard checks group:
% - Check clock, reset, and enable signals - This check verifies if the clock, reset, and enable signals follow the recommended naming convention.
% - Check package file names
% - Check signal and port names
% - Check top-level subsystem/port names
% After you apply the suggested settings, run all checks again and inspect that make sure they pass.

%%% Generate HDL Code
% This example provides the Simulink model slexFPGAPredictReadyExample, which is ready for HDL code generation.
% Open the Simulink model.
open_system("slexFPGAPredictReadyExample.slx")

% To generate HDL code for the neural network subsystem, right-click the subsystem and select HDL Code > Generate HDL for Subsystem.
% After the code generation is complete, a code generation report opens.
% The report contains the generated source files and various reports on the efficiency of the code.

figure
imshow("DeployRegressionNeuralNetworkModelToFPGAExample_05.png")
axis off;

%%% Optimize Model for Efficient Resource Usage on Hardware
% Open the generated report High-level Resource Report.
% Note that the Simulink model uses a large number of multipliers and adders/subtractors, because of the matrix-vector operations flagged by HDL Code Advisor.
% To optimize resource usage, you can enable streaming for your model before generating HDL code.
% When streaming is enabled, the generated code saves chip area by multiplexing the data over a smaller number of hardware resources.
% That is, streaming allows some computations to share a hardware resource.

% The subsystems that can benefit from streaming are:
% - neural network/RegressionNeuralNetwork Predict/getScore/hiddenLayers/hiddenLayer1
% - neural network/RegressionNeuralNetwork Predict/getScore/hiddenLayers/hiddenLayer2

% To enable streaming for these two subsystems, perform these steps for each subsystem:
% 1. Right-click the subsystem (hiddenLayer1 or hiddenLayer2) and select HDL Code > HDL Block Properties.
% 2. In the dialog box that opens, change the StreamingFactor option from 0 to 10, because each hidden layer contains 10 neurons.
% 3. Click OK.

figure
imshow("DeployRegressionNeuralNetworkModelToFPGAExample_06.png")
axis off;

% Generate HDL code again and note the reduced number of multipliers and adders/subtractors in the High-level Resource Report.
% To open the autogenerated version of the model that uses streaming in the generated report, open the Streaming and Sharing report and click the link to the autogenerated model under the link Generated model after the transformation.
% To see the changes made to the subsystem, navigate to:
% /neural network/RegressionNeuralNetwork Predict/getScore/hiddenLayers/hiddenLayer1
% To run the autogenerated model, you must extract the parameters of the neural network model that are stored in the mask workspace of the original Simulink model slexFPGAPredictExample.
% These parameters now need to be in the base workspace.
blockName = "slexFPGAPredictReadyExample/neural network/RegressionNeuralNetwork Predict";
bmw = Simulink.Mask.get(blockName);
mv = bmw.getWorkspaceVariables;
learnerParams = mv(end).Value;

%%% Deploy New Neural Network Model
% If you train a new neural network model with different settings (for example, different activation function, number of hidden layers, or size of hidden layers), follow the steps in this example from the start to deploy the new model.
% The HDL Coder optimization (prior to HDL code generation) might be different, depending on the new model architecture, target hardware, or other requirements.

%%% References
% [1] Kollmeyer, Phillip, Carlos Vidal, Mina Naguib, and Michael Skells. "LG 18650HG2 Li-ion Battery Data and Example Deep Neural Network xEV SOC Estimator Script." Mendeley 3 (March 2020). https://doi.org/10.17632/CP3473X7XV.3.
% [2] Vezzini, Andrea. "Lithium-Ion Battery Management." In Lithium-Ion Batteries, edited by Gianfranco Pistoia, 345-360. Elsevier, 2014. https://doi.org/10.1016/B978-0-444-59513-3.00015-7.

%% Anomaly Detection in Industrial Machinery Using Three-Axis Vibration Data

% This example shows how to detect anomalies in vibration data using machine learning and deep learning. 
% The example uses vibration data is collected from an industrial machine. 
% First, you extract features from the raw measurements corresponding to normal operation using the Diagnostic Feature Designer App. 
% Use the selected features to train each model under consideration. 
% Then use each trained model to identify whether the machine is operating under normal condition.

%%% Dataset
% The dataset contains 3-axis vibration measurements from an industrial machine. 
% The data is collected both immediately before and after a scheduled maintenance. 
% The data collected after scheduled maintenance is assumed to represent normal operating condition of the machine. 
% The before maintenance data can represent either normal or anomalous conditions. 
% Data for each axis is stored in a separate column and each file contains 7000 measurements. 
% Load the data from the MathWorks supportfiles site and plot a sample of the normal and anomalous dataset.

url = 'https://ssd.mathworks.com/supportfiles/predmaint/anomalyDetection3axisVibration/v1/vibrationData.zip';
websave('vibrationData.zip',url);
unzip('vibrationData.zip');
load("MachineData.mat")
trainData

% To better understand the data, visualize it before and after maintenance. 
% Pick the fourth member of the ensemble for the plot and you can see that the data for the two conditions looks noticeably different.

ensMember = 4;
helperPlotVibrationData(trainData, ensMember)

%%% Extracting Features with Diagnostic Feature Designer App
% Using raw data for training machine learning models is not very efficient. 
% The Diagnostic Feature Designer App lets you interactively explore and preprocess your data, extract time and frequency domain features, then rank the features to determine which will be most effective. 
% You can then export a function to extract the selected features from your dataset programmatically. 
% Open the DFD app:

diagnosticFeatureDesigner

% Click the New Session button, select the trainData as the source and then set label as a condition variable. 
% The label variable identifies the condition of the machine for the corresponding data.

figure
imshow("AnomalyDetection_02.png")

% You can use the Diagnostic Feature Designer to iterate on the features and rank them. 
% A histogram view for all generated features is created to visualize the distributions separated by labels for various features extracted from ch1. 
% Note that the histograms shown below are from a much larger dataset, so the separation is easier to visualize. 
% The dataset used so far is a subset of the original data, so your results might be different.

figure
imshow("AnomalyD.png")

% Use the top four ranked features for each channel.
% - ch1 : Crest Factor, Kurtosis, RMS, Std
% - ch2 : Mean, RMS, Skewness, Std
% - ch3 : Crest Factor, SINAD, SNR, THD

% Export a function to generate the features from the Diagnostic Feature designer app and save it with the name generateFeatures. 
% This function extracts the top 4 relevant features from each channel in the entire dataset from the command line.

trainFeatures = generateFeatures(trainData);
head(trainFeatures)

%%% Train Models for Anomaly Detection
% The dataset used so far is only a small subset of a much larger dataset to illustrate the process of feature extraction and selection. 
% Training your algorithm on all available data yields the best performance. 
% To this end, load the 12 features that were previously extracted from the larger dataset of 17,642 signals.

load("FeatureEntire.mat")
head(featureAll)

% Use cvpartition to partition data into a training set and an independent test set. 
% helperExtractLabeledData helper function is used to find all features corresponding to the label 'After' in featureTrain variable.

rng(0) % set for reproducibility
idx = cvpartition(featureAll.label, 'holdout', 0.1);
featureTrain = featureAll(idx.training, :);
featureTest = featureAll(idx.test, :);

% For each model, only train on the data after maintenance which is assumed to be normal. 
% Extract only the data after maintenance from featureTrain.

trueAnomaliesTest = featureTest.label;
featureNormal = featureTrain(featureTrain.label=='After', :);

%%% Detect Anomalies with One-Class SVM
% Support Vector Machines are powerful classifiers, and their variant, which trains on only one class, models the normal data. 
% This model works well for identifying abnormalities as being "far" from the normal data. 
% Select the training data for normal condition and train the SVM model using fitcsvm function.

mdlSVM = fitcsvm(featureNormal, 'label', 'Standardize', true, 'OutlierFraction', 0);

% Validate the trained SVM model by using test data which contains both normal and anomalous data.

featureTestNoLabels = featureTest(:, 2:end);
[~,scoreSVM] = predict(mdlSVM,featureTestNoLabels);
isanomalySVM = scoreSVM<0;
predSVM = categorical(isanomalySVM, [1, 0], ["Anomaly", "Normal"]);
trueAnomaliesTest = renamecats(trueAnomaliesTest,["After","Before"], ["Normal","Anomaly"]);
figure;
confusionchart(trueAnomaliesTest, predSVM, Title="Anomaly Detection with One-class SVM", Normalization="row-normalized");

% From the confusion matrix, it is seen that the one-class SVM does pretty well. 
% Only 0.3% of anomalous samples are misclassified as normal and about 0.9% of normal data is misclassified as anomalous.

%%% Detect Anomalies with Isolation Forest
% The decision trees of an isolation forest isolate each observation in a leaf. 
% How many decisions a sample passes through to get to its leaf is a measure of how complicated it was to isolate it from the others. 
% The average depth of trees for a specific sample is used as their anomaly score and returned by the iforest. 
% Once again, train the isolation forest model on normal data only.

[mdlIF,~,scoreTrainIF] = iforest(featureNormal{:,2:13},'ContaminationFraction',0.09);

% Validate the trained isolation forest model by using test data which contains both normal and anomalous data. 
% Visualize the performance of this model by using a Confusion Chart.

[isanomalyIF,scoreTestIF] = isanomaly(mdlIF,featureTestNoLabels.Variables);
predIF = categorical(isanomalyIF, [1, 0], ["Anomaly", "Normal"]);
figure;
confusionchart(trueAnomaliesTest,predIF,Title="Anomaly Detection with Isolation Forest",Normalization="row-normalized");

% On this data, the isolation forest doesn't do as well as the one-class SVM, but it's not your typical anomaly detection with so many "anomalies" in this almost balanced data set. 
% The reason for this is that the training data contained normal data only while the test data contains about 30% anomalous data. 
% This indicates that the isolation forest model is better suited when the distribution of the anomalies and normal data is closer.

%%% Detect Anomalies with LSTM Autoencoder Network
% Autoencoders are a type of neural network that learn a compressed representation of unlabeled data. 
% LSTM autoencoders are a variant of this network, which can learn a compressed representation of sequence data. 
% This LSTM autoencoder will be trained with only normal data and the trained network will be used to identify when the sequence does not look like normal data is encountered.

featuresAfter = helperExtractLabeledData(featureTrain, ...
   "After");

% Then, construct the biLSTM autoencoder network and set the training options.

featureDimension = 1;

% Define biLSTM network layers
layers = [ sequenceInputLayer(featureDimension, 'Name', 'in')
   bilstmLayer(16, 'Name', 'bilstm1')
   reluLayer('Name', 'relu1')
   bilstmLayer(32, 'Name', 'bilstm2')
   reluLayer('Name', 'relu2')
   bilstmLayer(16, 'Name', 'bilstm3')
   reluLayer('Name', 'relu3')
   fullyConnectedLayer(featureDimension, 'Name', 'fc')
   regressionLayer('Name', 'out') ];

% Set Training Options
options = trainingOptions('adam', ...
   'Plots', 'training-progress', ...
   'MiniBatchSize', 500,...
   'MaxEpochs',200);

% The MaxEpochs training options parameter is set to 200. 
% For higher validation accuracy, you can set this parameter to a larger number. 
% However, this might cause the network to overfit. 
% Now train the model.

net = trainNetwork(featuresAfter, featuresAfter, layers, options);

%%% Visualize Model Behavior and Error on Validation Data
% Extract and visualize a sample each from Anomalous and Normal condition. 
% Note that the plots below are comparing the error in the values of each of the 12 features (indicated on the x-axis). 
% In this sample, features 10, 11 and 12 do not reconstruct well for the anomalous input and thus have a high error value. 
% The model uses this error value to identify an anomaly.

testNormal = {featureTest(1200, 2:end).Variables};
testAnomaly = {featureTest(200, 2:end).Variables};

% Predict decoded signal for both
decodedNormal = predict(net,testNormal);
decodedAnomaly = predict(net,testAnomaly);

% Visualize
helperVisualizeModelBehavior(testNormal, testAnomaly, decodedNormal, decodedAnomaly)

% Extract features for normal and anomalous data. 
% The figure shows that the reconstruction error for the anomalous data is significantly higher than the normal data. 
% This makes sense, since the autoencoder was trained on the normal data, so it will better reconstruct similar signals.

% Extract data Before maintenance
XTestBefore = helperExtractLabeledData(featureTest, "Before");

% Predict output before maintenance and calculate error
yHatBefore = predict(net, XTestBefore);
errorBefore = helperCalculateError(XTestBefore, yHatBefore);

% Extract data after maintenance
XTestAfter = helperExtractLabeledData(featureTest, "After");

% Predict output after maintenance and calculate error
yHatAfter = predict(net, XTestAfter);
errorAfter = helperCalculateError(XTestAfter, yHatAfter);

helperVisualizeError(errorBefore, errorAfter);

%%% Identify Anomalies
% Calculate the error on the full validation data.

XTestAll = helperExtractLabeledData(featureTest, "All");

yHatAll = predict(net, XTestAll);
errorAll = helperCalculateError(XTestAll, yHatAll);

% Define an anomaly as a point which has reconstruction error 0.5 times larger than the mean across all observations. 
% This threshold was determined through experimentation and can be changed as required.

thresh = 0.5;
anomalies = errorAll > thresh*mean(errorAll);

helperVisualizeAnomalies(anomalies, errorAll, featureTest);

%%% Supporting functions
function E = helperCalculateError(X, Y)
% HELPERCALCULATEERROR function calculates the rms error value between the
% inputs X, Y
E = zeros(length(X),1);
for i = 1:length(X)
   E(i,:) = sqrt(sum((Y{i} - X{i}).^2));
end

end

function helperVisualizeError(errorBefore, errorAfter)
% HELPERVISUALIZEERROR creates a plot to visualize the errors on detecting
% before and after conditions
figure("Color", "W")
tiledlayout("flow")

nexttile
plot(1:length(errorBefore), errorBefore, 'LineWidth',1.5), grid on
title(["Before Maintenance", ...
   sprintf("Mean Error: %.2f\n", mean(errorBefore))])
xlabel("Observations")
ylabel("Reconstruction Error")
ylim([0 15])

nexttile
plot(1:length(errorAfter), errorAfter, 'LineWidth',1.5), grid on,
title(["After Maintenance", ...
   sprintf("Mean Error: %.2f\n", mean(errorAfter))])
xlabel("Observations")
ylabel("Reconstruction Error")
ylim([0 15])

end

function helperVisualizeAnomalies(anomalies, errorAll, featureTest)
% HELPERVISUALIZEANOMALIES creates a plot of the detected anomalies
anomalyIdx = find(anomalies);
anomalyErr = errorAll(anomalies);

predAE = categorical(anomalies, [1, 0], ["Anomaly", "Normal"]);
trueAE = renamecats(featureTest.label,["Before","After"],["Anomaly","Normal"]);

acc = numel(find(trueAE == predAE))/numel(predAE)*100;
figure;
t = tiledlayout("flow");
title(t, "Test Accuracy: " + round(mean(acc),2) + "%");
nexttile
hold on
plot(errorAll)
plot(anomalyIdx, anomalyErr, 'x')
hold off
ylabel("Reconstruction Error")
xlabel("Observation")
legend("Error", "Candidate Anomaly")

nexttile
confusionchart(trueAE,predAE)

end

function helperVisualizeModelBehavior(normalData, abnormalData, decodedNorm, decodedAbNorm)
%HELPERVISUALIZEMODELBEHAVIOR Visualize model behavior on sample validation data

figure("Color", "W")
tiledlayout("flow")

nexttile()
hold on
colororder('default')
yyaxis left
plot(normalData{:})
plot(decodedNorm{:},":","LineWidth",1.5)
hold off
title("Normal Input")
grid on
ylabel("Feature Value")
yyaxis right
stem(abs(normalData{:} - decodedNorm{:}))
ylim([0 2])
ylabel("Error")
legend(["Input", "Decoded","Error"],"Location","southwest")

nexttile()
hold on
yyaxis left
plot(abnormalData{:})
plot(decodedAbNorm{:},":","LineWidth",1.5)
hold off
title("Abnormal Input")
grid on
ylabel("Feature Value")
yyaxis right
stem(abs(abnormalData{:} - decodedAbNorm{:}))
ylim([0 2])
ylabel("Error")
legend(["Input", "Decoded","Error"],"Location","southwest")

end

function X = helperExtractLabeledData(featureTable, label)
%HELPEREXTRACTLABELEDDATA Extract data from before or after operating
%conditions and re-format to support input to autoencoder network

% Select data with label After
if label == "All"
   Xtemp = featureTable(:, 2:end).Variables;
else
   tF = featureTable.label == label;
   Xtemp = featureTable(tF, 2:end).Variables;
end

% Arrange data into cells
X = cell(length(Xtemp),1);
for i = 1:length(Xtemp)
   X{i,:} = Xtemp(i,:);
end

end

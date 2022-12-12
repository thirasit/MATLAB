%% Anomaly Detection in Industrial Machinery Using Three-Axis Vibration Data

% This example shows how to detect anomalies in vibration data using machine learning and deep learning. 
% The example uses vibration data from an industrial machine. 
% First, you extract features from the raw measurements corresponding to normal operation using the Diagnostic Feature Designer App. 
% You use the selected features to train three different models (one-class SVM, isolation forest, and LSTM autoencoder) for anomaly detection. 
% Then, you use each trained model to identify whether the machine is operating normally.

%%% Data Set
% The data set contains three-axis vibration measurements from an industrial machine. 
% The data is collected both immediately before and after a scheduled maintenance. 
% The data collected after scheduled maintenance is assumed to represent normal operating conditions of the machine. 
% The data from before maintenance can represent either normal or anomalous conditions. 
% Data for each axis is stored in a separate column. 
% Save and unzip the data set and then, load the training data.

url = 'https://ssd.mathworks.com/supportfiles/predmaint/anomalyDetection3axisVibration/v1/vibrationData.zip';
websave('vibrationData.zip',url);
unzip('vibrationData.zip');
load("MachineData.mat")
trainData

% To better understand the data, visualize it before and after maintenance. 
% Plot vibration data for the fourth member of the ensemble and note that the data for the two conditions looks different.
ensMember = 4;
helperPlotVibrationData(trainData, ensMember)

%%% Extract Features with Diagnostic Feature Designer App
% Because raw data can be correlated and noisy, using raw data for training machine learning models is not very efficient. 
% The Diagnostic Feature Designer app lets you interactively explore and preprocess your data, extract time and frequency domain features, and then rank the features to determine which are most effective for diagnosing faulty or otherwise anomalous systems. 
% You can then export a function to extract the selected features from your data set programmatically. 
% Open Diagnostic Feature Designer by typing diagnosticFeatureDesigner at the command prompt. 
% For a tutorial on using Diagnostic Feature Designer, see Identify Condition Indicators for Predictive Maintenance Algorithm Design.

% Click the New Session button, select trainData as the source, and then set label as Condition Variable. 
% The label variable identifies the condition of the machine for the corresponding data.

figure
imshow("AnomalyDetectionUsing3axisVibrationDataExample_02.png")

% You can use Diagnostic Feature Designer to iterate on the features and rank them. 
% The app creates a histogram view for all generated features to visualize the distribution for each label. 
% For example, the following histograms show distributions of various features extracted from ch1. 
% These histograms are derived from a much larger data set than the data set that you use in this example, in order to better illustrate the label-group separation. 
% Because you are using a smaller data set, your results will look different.

figure
imshow("AnomalyDetectionUsing3axisVibrationDataExample_03.png")

% Use the top four ranked features for each channel.
% - ch1 : Crest Factor, Kurtosis, RMS, Std
% - ch2 : Mean, RMS, Skewness, Std
% - ch3 : Crest Factor, SINAD, SNR, THD

% Export a function to generate the features from the Diagnostic Feature designer app and save it with the name generateFeatures. 
% This function extracts the top 4 relevant features from each channel in the entire data set from the command line.
trainFeatures = generateFeatures(trainData);
head(trainFeatures)

%%% Prepare Full Data Sets for Training
% The data set you use to this point is only a small subset of a much larger data set to illustrate the process of feature extraction and selection. 
% Training your algorithm on all available data yields the best performance. 
% To this end, load the same 12 features as previously extracted from the larger data set of 17,642 signals.
load("FeatureEntire.mat")
head(featureAll)

% Use cvpartition to partition data into a training set and an independent test set. 
% Use the helperExtractLabeledData helper function to find all features corresponding to the label 'After' in the featureTrain variable.
rng(0) % set for reproducibility
idx = cvpartition(featureAll.label, 'holdout', 0.1);
featureTrain = featureAll(idx.training, :);
featureTest = featureAll(idx.test, :);

% For each model, train on only the after maintenance data, which is assumed to be normal. 
% Extract only this data from featureTrain.
trueAnomaliesTest = featureTest.label;
featureNormal = featureTrain(featureTrain.label=='After', :);

%%% Detect Anomalies with One-Class SVM
% Support Vector Machines are powerful classifiers, and the variant that trains on only the normal data is used here.
% This model works well for identifying abnormalities that are "far" from the normal data. 
% Train a one-class SVM model using the fitcsvm function and the data for normal conditions.
mdlSVM = fitcsvm(featureNormal, 'label', 'Standardize', true, 'OutlierFraction', 0);

% Validate the trained SVM model by using test data, which contains both normal and anomalous data.
featureTestNoLabels = featureTest(:, 2:end);
[~,scoreSVM] = predict(mdlSVM,featureTestNoLabels);
isanomalySVM = scoreSVM<0;
predSVM = categorical(isanomalySVM, [1, 0], ["Anomaly", "Normal"]);
trueAnomaliesTest = renamecats(trueAnomaliesTest,["After","Before"], ["Normal","Anomaly"]);
figure;
confusionchart(trueAnomaliesTest, predSVM, Title="Anomaly Detection with One-class SVM", Normalization="row-normalized");

% From the confusion matrix, you can see that the one-class SVM performs well. 
% Only 0.3% of anomalous samples are misclassified as normal and about 0.9% of normal data is misclassified as anomalous.

%%% Detect Anomalies with Isolation Forest
% The decision trees of an isolation forest isolate each observation in a leaf. 
% How many decisions a sample passes through to get to its leaf is a measure of how difficult isolating it from the others is. 
% The average depth of trees for a specific sample is used as their anomaly score and returned by iforest.

% Train the isolation forest model on normal data only.
[mdlIF,~,scoreTrainIF] = iforest(featureNormal{:,2:13},'ContaminationFraction',0.09);

% Validate the trained isolation forest model by using the test data. 
% Visualize the performance of this model by using a confusion chart.
[isanomalyIF,scoreTestIF] = isanomaly(mdlIF,featureTestNoLabels.Variables);
predIF = categorical(isanomalyIF, [1, 0], ["Anomaly", "Normal"]);
figure;
confusionchart(trueAnomaliesTest,predIF,Title="Anomaly Detection with Isolation Forest",Normalization="row-normalized");

% On this data, the isolation forest doesn't do as well as the one-class SVM. 
% The reason for this poorer performance is that the training data contains only normal data while the test data contains about 30% anomalous data. 
% Therefore, the isolation forest model is a better choice when the proportion of anomalous data to normal data is similar for both training and test data.

%%% Detect Anomalies with LSTM Autoencoder Network
% Autoencoders are a type of neural network that learn a compressed representation of unlabeled data. 
% LSTM autoencoders are a variant of this network that can learn a compressed representation of sequence data. 
% Here, you train an LSTM autoencoder with only normal data and use this trained network to identify when a signal does not look normal.

% Start by extracting features from the after maintenance data.
featuresAfter = helperExtractLabeledData(featureTrain, ...
   "After");

% Construct the LSTM autoencoder network and set the training options.
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
% For higher validation accuracy, you can set this parameter to a larger number; However, the network might overfit.

% Train the model.
net = trainNetwork(featuresAfter, featuresAfter, layers, options);

%%% Visualize Model Behavior and Error on Validation Data
% Extract and visualize a sample each from Anomalous and Normal condition. 
% The following plots show the reconstruction errors of the autoencoder model for each of the 12 features (indicated on the X-axis). 
% The reconstructed feature value is referred to as "Decoded" signal in the plot. 
% In this sample, features 10, 11, and 12 do not reconstruct well for the anomalous input and thus have high errors. 
% We can use reconstructon errors to identify an anomaly.
testNormal = {featureTest(1200, 2:end).Variables};
testAnomaly = {featureTest(200, 2:end).Variables};

% Predict decoded signal for both
decodedNormal = predict(net,testNormal);
decodedAnomaly = predict(net,testAnomaly);

% Visualize
helperVisualizeModelBehavior(testNormal, testAnomaly, decodedNormal, decodedAnomaly)

% Extract features for all the normal and anomalous data. 
% Use the trained autoencoder model to predict the selected 12 features for both before and after maintenance data. 
% The following plots show the root mean square reconstruction error across the twelve features. 
% The figure shows that the reconstruction error for the anomalous data is much higher than the normal data. 
% This result is expected, since the autoencoder is trained on the normal data, so it better reconstructs similar signals.

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
% Calculate the reconstruction error on the full validation data.
XTestAll = helperExtractLabeledData(featureTest, "All");

yHatAll = predict(net, XTestAll);
errorAll = helperCalculateError(XTestAll, yHatAll);

% Define an anomaly as a point that has reconstruction error 0.5 times the mean across all observations. 
% This threshold was determined through previous experimentation and can be changed as required.
thresh = 0.5;
anomalies = errorAll > thresh*mean(errorAll);

helperVisualizeAnomalies(anomalies, errorAll, featureTest);

% In this example, three different models are used to detect anomalies. 
% The one-class SVM had the best performance at 99.7% for detecting anomalies in the test data, while the other two models are around 93% accurate. 
% The relative performance of the models can change if a different set of features are selected or if different hyper-parameters are used for each model. 
% Use the Diagnostic Feature Designer MATLAB App to further experiment with feature selection.

%%% Supporting Functions
function E = helperCalculateError(X, Y)
% HELPERCALCULATEERROR calculates the rms error value between the
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




%% Perform Time Series Direct Forecasting with directforecaster
% Perform time series direct forecasting with the directforecaster function.
% The function creates a forecasting model that uses a direct strategy in which a separate regression model is trained for each step of the forecasting horizon.
% For more information, see Direct Forecasting.

% Use different validation schemes, such as holdout, expanding window, and sliding window, to assess the performance of the forecasting model.
% Then use the model to forecast at time steps beyond the available data.

%%% Load and Visualize Data
% Load the data in electricityclient.mat, which is a subset of the ElectricityLoadDiagrams20112014 data set available in the UCI Machine Learning Repository [1].
% The original data set contains the electricity consumption (in kWh) of 321 clients, logged every 15 minutes from 2012 to 2014, as described in [2].
% The smaller usagedata timetable contains the hourly electricity consumption of the sixth client only.
load electricityclient.mat

% Plot the electricity consumption of the sixth client during the first 200 hours.
% Overall, the electricity consumption of this client shows a periodicity of 24 hours.
figure
hrs = 1:200;
plot(usagedata.Time(hrs),usagedata.Electricity(hrs))
xlabel("Time")
ylabel("Electricity Consumption [kWh]")

% Confirm that the values in usagedata are regular with respect to time by using the isregular function.
% directforecaster requires data to be regularly sampled.
isregular(usagedata)

% Confirm that no values are missing in the time series by using the ismissing function.
sum(ismissing(usagedata))

% If your data is not regularly sampled or contains missing values, you can use the retime function or fill the missing values.
% For more information, see Clean Timetable with Missing, Duplicate, or Nonuniform Times.

%%% Prepare Data for Forecasting
% Before forecasting, reorganize the data.
% Use the date and time information in the usagedata timetable to create separate variables.
% Specifically, create Month, Day, Hour, WeekDay, DayOfYear, and WeekOfYear variables, and add them to the usagedata timetable.
usagedata.Month = month(usagedata.Time);
usagedata.Day = day(usagedata.Time);
usagedata.Hour = hour(usagedata.Time);
usagedata.WeekDay = weekday(usagedata.Time);
usagedata.DayOfYear = day(usagedata.Time,"dayofyear");
usagedata.WeekOfYear = week(usagedata.Time,"weekofyear");

% Normalize the time variables that contain more than 30 categories, so that their values are in the range –0.5 to 0.5.
% Specify the remaining time variables as categorical predictors.
[normData,C,S] = normalize( ...
    usagedata(:,["Day","DayOfYear","WeekOfYear"]),range=[-0.5 0.5]);
usagedata(:,["Day","DayOfYear","WeekOfYear"]) = normData;
catPredictors = ["Month","Hour","WeekDay"];

%%% Assess Performance at Specified Horizon Step
% Use holdout validation and expanding window cross-validation to assess the performance of a direct forecasting model that forecasts a fixed number of steps into the horizon.
% In this case, create and assess a model that forecasts 24 hours ahead.

%%% Holdout Validation
% Create a time series partition object using the tspartition function.
% Reserve 20% of the observations for testing and use the remaining observations for training.
% When you use holdout validation for time series data, the latest observations are in the test set and the oldest observations are in the training set.
holdoutPartition = tspartition(size(usagedata,1),"Holdout",0.2)

trainIdx = holdoutPartition.training;
testIdx = holdoutPartition.test;

% trainIdx and testIdx contain the indices for the observations in the training and test sets, respectively.

% Create a direct forecasting model by using the directforecaster function.
% Train the model using a boosted ensemble of regression trees.
% For the regression trees, specify the maximal number of decision splits (or branch nodes) per tree and the minimum number of observations per leaf by using the templateTree function.
% For the ensemble, specify to perform least-squares boosting with 150 trees and a learning rate of 0.2 for shrinkage by using the templateEnsemble function.

% Use the training set indices trainIdx to specify the training observations in usagedata.
% Specify the horizon step as 24 hours ahead.
% Specify the categorical and leading exogenous predictors.
% Note that all the exogenous predictors are leading because their future values are known.
% By default, directforecaster uses the unshifted leading exogenous predictors to train the direct forecasting model.
% Create 23 new predictors from the lagged values of the response variable Electricity.
rng("default") % For reproducibility
tree = templateTree(MaxNumSplits=255,MinLeafSize=1);
ensemble = templateEnsemble("LSBoost",150,tree,LearnRate=0.2);
singleHoldoutModel = directforecaster(usagedata(trainIdx,:), ...
    "Electricity",Horizon=24,Learner=ensemble, ...
    CategoricalPredictors=catPredictors,LeadingPredictors="all", ...
    ResponseLags=1:23)

% singleHoldoutModel is a DirectForecaster model object.
% The object consists of one ensemble model singleHoldoutModel.Learners{1} that predicts 24 steps ahead.

% Use the trained model singleHoldoutModel to predict response values for the observations in the test data set.
predHoldoutTest = predict(singleHoldoutModel,usagedata(testIdx,:));
trueHoldoutTest = usagedata(testIdx,"Electricity");

% Compare the true electricity consumption to the predicted electricity consumption for the first 200 observations in the test set.
% Plot the values using the time information in trueHoldoutTest and predHoldoutTest.
figure
hrs = 1:200;
plot(trueHoldoutTest(hrs,:),"Electricity")
hold on
plot(predHoldoutTest(hrs,:), ...
    "Electricity_Step24",LineStyle="--")
hold off
legend("True","Predicted")
xlabel("Time")
ylabel("Electricity Consumption [kWh]")

% Because the software creates lagged predictors, singleHoldoutModel makes the first few predictions using data with many missing values.
% To see the prepared test data used by singleHoldoutModel to make predictions, you can use the preparedPredictors object function.
preparedPredictors(singleHoldoutModel,usagedata(testIdx,:));

% Use the helper function computeRRSE (shown at the end of this example) to compute the root relative squared error (RRSE) on the test data.
% The RRSE indicates how well a model performs relative to the simple model, which always predicts the average of the true values.
% In particular, when the RRSE is less than 1, the model performs better than the simple model.
% For more information, see Compute Root Relative Squared Error (RRSE).
singleHoldoutRRSE = loss(singleHoldoutModel,usagedata(testIdx,:), ...
    LossFun=@computeRRSE)

% The singleHoldoutRRSE value indicates that the singleHoldoutModel performs well on the test data.

%%% Expanding Window Cross-Validation
% Create an object that partitions the time series observations using expanding windows.
% Split the data set into 5 windows with expanding training sets and fixed-size test sets by using tspartition.
% For each window, use at least one year of observations for training.
% By default, tspartition ensures that the latest observations are included in the last (fifth) window.
expandingWindowCV = tspartition(size(usagedata,1),"ExpandingWindow",5, ...
    MinTrainSize=366*24)

% The training observations in the first window are included in the second window, the training observations in the second window are included in the third window, and so on.
% For each window, the test observations follow the training observations in time.

% Create a cross-validated direct forecasting model by using the directforecaster function and the expandingWindowCV partition object.
% For each window, use the training observations to fit a boosted ensemble of regression trees.
% Specify the same model parameters used to create the model singleHoldoutModel.
rng("default") % For reproducibility
tree = templateTree(MaxNumSplits=255,MinLeafSize=1);
ensemble = templateEnsemble("LSBoost",150,tree,LearnRate=0.2);
singleExpandingCVModel = directforecaster(usagedata, ...
    "Electricity",Horizon=24,Learner=ensemble, ...
    CategoricalPredictors=catPredictors,LeadingPredictors="all", ...
    ResponseLags=1:23,Partition=expandingWindowCV);

% Compute the test RRSE value for each window.
% Then, compute the average RRSE across all windows.
expandingWindowRRSE = cvloss(singleExpandingCVModel, ...
    LossFun=@computeRRSE,Mode="individual")

singleCVRRSE = cvloss(singleExpandingCVModel, ...
    LossFun=@computeRRSE,Mode="average")

% The average RRSE value returned by expanding window cross-validation (singleCVRRSE) is relatively low and is similar to the RRSE value returned by holdout validation (singleHoldoutRRSE).
% These results indicate that the forecasting model generally performs well.

%%% Assess Performance at Multiple Horizon Steps
% Use holdout validation and sliding window cross-validation to assess the performance of a direct forecasting model that forecasts at multiple horizon steps.
% In this case, create and assess a model that forecasts 1 to 24 hours ahead.

%%% Holdout Validation
% Reuse the time series partition object holdoutPartition for holdout validation.
% Recall that the object reserves 20% of the observations for testing and uses the remaining observations for training.
holdoutPartition

trainIdx = holdoutPartition.training;
testIdx = holdoutPartition.test;

% Create a direct forecasting model by using the directforecaster function.
% For each horizon step, the function uses the training observations to fit a boosted ensemble of regression trees.
% Specify the same model parameters used to create the model singleHoldoutModel.
% However, to speed up training, use fewer trees (50) in each ensemble, and bin the numeric predictors into at most 256 equiprobable bins.
rng("default") % For reproducibility
tree = templateTree(MaxNumSplits=255,MinLeafSize=1);
ensemble = templateEnsemble("LSBoost",50,tree,LearnRate=0.2);
multiHoldoutModel = directforecaster(usagedata(trainIdx,:), ...
    "Electricity",Horizon=1:24,Learner=ensemble,NumBins=256, ...
    CategoricalPredictors=catPredictors,LeadingPredictors="all", ...
    ResponseLags=1:23);

% Plot the test RRSE values with respect to the horizon.
figure
multiHoldoutRRSE = loss(multiHoldoutModel,usagedata(testIdx,:), ...
    LossFun=@computeRRSE);
plot(multiHoldoutModel.Horizon,multiHoldoutRRSE,"o-")
xlabel("Horizon [hr]")
ylabel("RRSE")
title("RRSE Using Holdout Validation")

% As the horizon increases, the RRSE values stabilize to a relatively low value.
% This result indicates that the direct forecasting model predicts well for any time horizon between 1 and 24 hours.

%%% Sliding Window Cross-Validation
% Create an object that partitions the time series observations using sliding windows.
% Split the data set into 5 windows with fixed-size training and test sets by using tspartition.
% For each window, use at least one year of observations for training.
% By default, tspartition ensures that the latest observations are included in the last (fifth) window.
% Therefore, some older observations might be omitted from the cross-validation.
slidingWindowCV = tspartition(size(usagedata,1),"SlidingWindow",5, ...
    TrainSize=366*24)

% For each window, the test observations follow the training observations in time.

% Create a cross-validated direct forecasting model by using the directforecaster function and the slidingWindowCV partition object.
% For each window and horizon step, the function uses the training observations to fit a boosted ensemble of regression trees.
% Specify the same model parameters used to create the model singleHoldoutModel.
% However, to speed up training, use fewer trees (50) in each ensemble, and bin the numeric predictors.
% To further speed up the training process, set UseParallel to true and run computations in parallel.
% Parallel computation requires Parallel Computing Toolbox™.
% If you do not have Parallel Computing Toolbox, the computations do not run in parallel.
rng("default") % For reproducibility
tree = templateTree(MaxNumSplits=255,MinLeafSize=1);
ensemble = templateEnsemble("LSBoost",50,tree,LearnRate=0.2);
multiCVModel = directforecaster(usagedata,"Electricity", ...
    Horizon=1:24,Learner=ensemble,NumBins=256, ...
    CategoricalPredictors=catPredictors,LeadingPredictors="all", ...
    ResponseLags=1:23,Partition=slidingWindowCV,UseParallel=true);

% Plot the average test RRSE values with respect to the horizon.
figure
multiCVRRSE = cvloss(multiCVModel, ...
    LossFun=@computeRRSE);
plot(multiCVModel.Horizon,multiCVRRSE,"o-")
xlabel("Horizon [hr]")
ylabel("RRSE")
title("Average RRSE Using Sliding Window Partition")

% As the horizon increases, the RRSE values stabilize to a relatively low value.
% The multiCVRRSE values are slightly higher than the multiHoldoutRRSE values.
% This discrepancy might be due to the difference in the number of training observations used in the sliding window and holdout validation schemes.
slidingWindowCV.TrainSize

holdoutPartition.TrainSize

% For each horizon, the regression models in the sliding window cross-validation scheme use significantly fewer training observations than the corresponding regression model in the holdout validation scheme.

%%% Forecast Beyond Available Data
% Create a direct forecasting model to predict electricity consumption for the next 24 hours beyond the available data.
% Use the entire usagedata data set.
% For each horizon step, the function fits a boosted ensemble of regression trees.
% Specify the same model parameters used to create the model singleHoldoutModel.
% However, to speed up training, use fewer trees (50) in each ensemble, and bin the numeric predictors.
% To further speed up the training process, set UseParallel to true and run computations in parallel.
rng("default") % For reproducibility
tree = templateTree(MaxNumSplits=255,MinLeafSize=1);
ensemble = templateEnsemble("LSBoost",50,tree,LearnRate=0.2);
finalMdl = directforecaster(usagedata,"Electricity", ...
    Horizon=1:24,Learner=ensemble,NumBins=256, ...
    CategoricalPredictors=catPredictors,LeadingPredictors="all", ...
    ResponseLags=1:23,UseParallel=true);

% Because finalMdl uses the unshifted values of the leading predictors Month, Day, Hour, WeekDay, DayOfYear, and WeekOfYear as predictor values, you must specify these values for the horizon steps in the call to forecast.
% Create a timetable forecastData with the leading predictor values for the 24 hours after the last available observation in usagedata.
forecastTime = usagedata.Time(end,:) + hours(1:24);
forecastData = timetable(forecastTime');

forecastData.Month = month(forecastTime');
forecastData.Day = day(forecastTime');
forecastData.Hour = hour(forecastTime');
forecastData.WeekDay = weekday(forecastTime');
forecastData.DayOfYear = day(forecastTime',"dayofyear");
forecastData.WeekOfYear = week(forecastTime',"weekofyear");

% Normalize the Day, DayOfYear, and WeekOfYear variables using the same center and scale values derived earlier.
% Specify the remaining time variables as categorical predictors.
forecastData(:,["Day","DayOfYear","WeekOfYear"]) = normalize( ...
    forecastData(:,["Day","DayOfYear","WeekOfYear"]),center=C,scale=S);
catPredictors = ["Month","Hour","WeekDay"];

% Predict the electricity consumption for the 24 hours beyond the last observed time in usagedata.
forecastY = forecast(finalMdl,usagedata, ...
    LeadingData=forecastData)

% Plot the observed electricity consumption for the last four days in usagedata and the predicted electricity consumption for the following day.
figure
numPastDays = 4;
plot(usagedata(end-(numPastDays*24):end,:), ...
    "Electricity");
hold on
plot([usagedata(end,"Electricity");forecastY], ...
    "Electricity",LineStyle="--")
hold off
legend("Historical Data","Forecast Data")
xlabel("Time")
ylabel("Electricity Consumption [kWh]")

% The forecast values seem to follow the trend of the observed values.

%%% Compute Root Relative Squared Error (RRSE)
% The root relative squared error (RRSE) is defined as the ratio

figure
imshow("Opera Snapshot_2024-01-02_080033_www.mathworks.com.png")
axis off;

%%% References
% [1] Dua, D. and Graff, C. (2019). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, School of Information and Computer Science.
% [2] Lai, G., W. C. Chang, Y. Yang, and H. Liu. "Modeling long- and short-term temporal patterns with deep neural networks." In 41st International ACM SIGIR Conference on Research & Development in Information Retrieval, 2018, pp. 95-104.

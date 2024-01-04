%% Automated Regression Model Selection with Bayesian and ASHA Optimization
% This example shows how to use the fitrauto function to automatically try a selection of regression model types with different hyperparameter values, given training predictor and response data.
% By default, the function uses Bayesian optimization to select and assess models.
% If your training data set contains many observations, you can use an asynchronous successive halving algorithm (ASHA) instead.
% After the optimization is complete, fitrauto returns the model, trained on the entire data set, that is expected to best predict the responses for new data.
% Check the model performance on test data.

%%% Prepare Data
% Load the sample data set NYCHousing2015, which includes 10 variables with information on the sales of properties in New York City in 2015.
% This example uses some of these variables to analyze the sale prices.
load NYCHousing2015

% Instead of loading the sample data set NYCHousing2015, you can download the data from the NYC Open Data website and import the data as follows.
%folder = 'Annualized_Rolling_Sales_Update';
%ds = spreadsheetDatastore(folder,"TextType","string","NumHeaderLines",4);
%ds.Files = ds.Files(contains(ds.Files,"2015"));
%ds.SelectedVariableNames = ["BOROUGH","NEIGHBORHOOD","BUILDINGCLASSCATEGORY","RESIDENTIALUNITS", ...
%    "COMMERCIALUNITS","LANDSQUAREFEET","GROSSSQUAREFEET","YEARBUILT","SALEPRICE","SALEDATE"];
%NYCHousing2015 = readall(ds);

% Preprocess the data set to choose the predictor variables of interest.
% Some of the preprocessing steps match those in the example Train Linear Regression Model.
% First, change the variable names to lowercase for readability.
NYCHousing2015.Properties.VariableNames = lower(NYCHousing2015.Properties.VariableNames);

% Next, remove samples with certain problematic values.
% For example, retain only those samples where at least one of the area measurements grosssquarefeet or landsquarefeet is nonzero.
% Assume that a saleprice of $0 indicates an ownership transfer without a cash consideration, and remove the samples with that saleprice value.
% Assume that a yearbuilt value of 1500 or less is a typo, and remove the corresponding samples.
NYCHousing2015(NYCHousing2015.grosssquarefeet == 0 & NYCHousing2015.landsquarefeet == 0,:) = [];
NYCHousing2015(NYCHousing2015.saleprice == 0,:) = [];
NYCHousing2015(NYCHousing2015.yearbuilt <= 1500,:) = [];

% Convert the saledate variable, specified as a datetime array, into two numeric columns MM (month) and DD (day), and remove the saledate variable.
% Ignore the year values because all samples are for the year 2015.
[~,NYCHousing2015.MM,NYCHousing2015.DD] = ymd(NYCHousing2015.saledate);
NYCHousing2015.saledate = [];

% The numeric values in the borough variable indicate the names of the boroughs.
% Change the variable to a categorical variable using the names.
NYCHousing2015.borough = categorical(NYCHousing2015.borough,1:5, ...
    ["Manhattan","Bronx","Brooklyn","Queens","Staten Island"]);

% The neighborhood variable has 254 categories.
% Remove this variable for simplicity.
NYCHousing2015.neighborhood = [];

% Convert the buildingclasscategory variable to a categorical variable, and explore the variable by using the wordcloud function.
NYCHousing2015.buildingclasscategory = categorical(NYCHousing2015.buildingclasscategory);
wordcloud(NYCHousing2015.buildingclasscategory);

% Assume that you are interested only in one-, two-, and three-family dwellings.
% Find the sample indices for these dwellings and delete the other samples.
% Then, change the buildingclasscategory variable to an ordinal categorical variable, with integer-valued category names.
idx = ismember(string(NYCHousing2015.buildingclasscategory), ...
    ["01  ONE FAMILY DWELLINGS","02  TWO FAMILY DWELLINGS","03  THREE FAMILY DWELLINGS"]);
NYCHousing2015 = NYCHousing2015(idx,:);
NYCHousing2015.buildingclasscategory = categorical(NYCHousing2015.buildingclasscategory, ...
    ["01  ONE FAMILY DWELLINGS","02  TWO FAMILY DWELLINGS","03  THREE FAMILY DWELLINGS"], ...
    ["1","2","3"],'Ordinal',true);

% The buildingclasscategory variable now indicates the number of families in one dwelling.
% Explore the response variable saleprice by using the summary function.
s = summary(NYCHousing2015);
s.saleprice

% Create a histogram of the saleprice variable.
histogram(NYCHousing2015.saleprice)

% Because the distribution of saleprice values is right-skewed, with all values greater than 0, log transform the saleprice variable.
NYCHousing2015.saleprice = log(NYCHousing2015.saleprice);

% Similarly, transform the grosssquarefeet and landsquarefeet variables.
% Add a value of 1 before taking the logarithm of each variable, in case the variable is equal to 0.
NYCHousing2015.grosssquarefeet = log(1 + NYCHousing2015.grosssquarefeet);
NYCHousing2015.landsquarefeet = log(1 + NYCHousing2015.landsquarefeet);

%%% Partition Data and Remove Outliers
% Partition the data set into a training set and a test set by using cvpartition.
% Use approximately 80% of the observations for the model selection and hyperparameter tuning process, and the other 20% to test the performance of the final model returned by fitrauto.
rng("default") % For reproducibility of the partition
c = cvpartition(length(NYCHousing2015.saleprice),"Holdout",0.2);
trainData = NYCHousing2015(training(c),:);
testData = NYCHousing2015(test(c),:);

% Identify and remove the outliers of saleprice, grosssquarefeet, and landsquarefeet from the training data by using the isoutlier function.
[priceIdx,priceL,priceU] = isoutlier(trainData.saleprice);
trainData(priceIdx,:) = [];

[grossIdx,grossL,grossU] = isoutlier(trainData.grosssquarefeet);
trainData(grossIdx,:) = [];

[landIdx,landL,landU] = isoutlier(trainData.landsquarefeet);
trainData(landIdx,:) = [];

% Remove the outliers of saleprice, grosssquarefeet, and landsquarefeet from the test data by using the same lower and upper thresholds computed on the training data.
testData(testData.saleprice < priceL | testData.saleprice > priceU,:) = [];
testData(testData.grosssquarefeet < grossL | testData.grosssquarefeet > grossU,:) = [];
testData(testData.landsquarefeet < landL | testData.landsquarefeet > landU,:) = [];

%%% Use Automated Model Selection with Bayesian Optimization
% Find an appropriate regression model for the data in trainData by using fitrauto.
% By default, fitrauto uses Bayesian optimization to select models and their hyperparameter values, and computes the log(1+valLoss) value for each model, where valLoss is the cross-validation mean squared error (MSE).
% fitrauto provides a plot of the optimization and an iterative display of the optimization results.
% For more information on how to interpret these results, see Verbose Display.

% Specify to run the Bayesian optimization in parallel, which requires Parallel Computing Toolbox™.
% Due to the nonreproducibility of parallel timing, parallel Bayesian optimization does not necessarily yield reproducible results.
% Because of the complexity of the optimization, this process can take some time, especially for larger data sets.
bayesianOptions = struct("UseParallel",true);
[bayesianMdl,bayesianResults] = fitrauto(trainData,"saleprice", ...
    "HyperparameterOptimizationOptions",bayesianOptions);

% The Total elapsed time value shows that the Bayesian optimization took a while to run (about 16 minutes).

% The final model returned by fitrauto corresponds to the best estimated learner.
% Before returning the model, the function retrains it using the entire training data set (trainData), the listed Learner (or model) type, and the displayed hyperparameter values.

%%% Use Automated Model Selection with ASHA Optimization
% When fitrauto with Bayesian optimization takes a long time to run because of the number of observations in your training set, consider using fitrauto with ASHA optimization instead.
% Given that trainData contains over 10,000 observations, try using fitrauto with ASHA optimization to automatically find an appropriate regression model.
% When you use fitrauto with ASHA optimization, the function randomly chooses several models with different hyperparameter values and trains them on a small subset of the training data.
% If the log(1+valLoss) value for a particular model is promising, where valLoss is the cross-validation MSE, the model is promoted and trained on a larger amount of the training data.
% This process repeats, and successful models are trained on progressively larger amounts of data.
% By default, fitrauto provides a plot of the optimization and an iterative display of the optimization results.
% For more information on how to interpret these results, see Verbose Display.

% Specify to run the ASHA optimization in parallel.
% Note that ASHA optimization often has more iterations than Bayesian optimization by default.
% If you have a time constraint, you can specify the MaxTime field of the HyperparameterOptimizationOptions structure to limit the number of seconds fitrauto runs.
ashaOptions = struct("Optimizer","asha","UseParallel",true);
[ashaMdl,ashaResults] = fitrauto(trainData,"saleprice", ...
    "HyperparameterOptimizationOptions",ashaOptions);

% The Total elapsed time value shows that the ASHA optimization took less time to run than the Bayesian optimization (about 12 minutes).

% The final model returned by fitrauto corresponds to the best observed learner.
% Before returning the model, the function retrains it using the entire training data set (trainData), the listed Learner (or model) type, and the displayed hyperparameter values.

%%% Evaluate Test Set Performance
% Evaluate the performance of the returned bayesianMdl and ashaMdl models on the test set testData.
% For each model, compute the test set mean squared error (MSE), and take a log transform of the MSE to match the values in the verbose display of fitrauto.
% Smaller MSE (and log-transformed MSE) values indicate better performance.
bayesianTestMSE = loss(bayesianMdl,testData,"saleprice");
bayesianTestError = log(1 + bayesianTestMSE)

ashaTestMSE = loss(ashaMdl,testData,"saleprice");
ashaTestError = log(1 + ashaTestMSE)

% For each model, compare the predicted test set response values to the true response values.
% Plot the predicted sale price along the vertical axis and the true sale price along the horizontal axis.
% Points on the reference line indicate correct predictions.
% A good model produces predictions that are scattered near the line.
% Use a 1-by-2 tiled layout to compare the results for the two models.
bayesianTestPredictions = predict(bayesianMdl,testData);
ashaTestPredictions = predict(ashaMdl,testData);

figure
tiledlayout(1,2)

nexttile
plot(testData.saleprice,bayesianTestPredictions,".")
hold on
plot(testData.saleprice,testData.saleprice) % Reference line
hold off
xlabel(["True Sale Price","(log transformed)"])
ylabel(["Predicted Sale Price","(log transformed)"])
title("Bayesian Optimization Model")

nexttile
plot(testData.saleprice,ashaTestPredictions,".")
hold on
plot(testData.saleprice,testData.saleprice) % Reference line
hold off
xlabel(["True Sale Price","(log transformed)"])
ylabel(["Predicted Sale Price","(log transformed)"])
title("ASHA Optimization Model")

% Based on the log-transformed MSE values and the prediction plots, the bayesianMdl and ashaMdl models perform similarly well on the test set.

% For each model, use box plots to compare the distribution of predicted and true sale prices by borough.
% Create the box plots by using the boxchart function.
% Each box plot displays the median, the lower and upper quartiles, any outliers (computed using the interquartile range), and the minimum and maximum values that are not outliers.
% In particular, the line inside each box is the sample median, and the circular markers indicate outliers.

% For each borough, compare the red box plot (showing the distribution of predicted prices) to the blue box plot (showing the distribution of true prices).
% Similar distributions for the predicted and true sale prices indicate good predictions.
% Use a 1-by-2 tiled layout to compare the results for the two models.
figure
tiledlayout(1,2)

nexttile
boxchart(testData.borough,testData.saleprice)
hold on
boxchart(testData.borough,bayesianTestPredictions)
hold off
legend(["True Sale Prices","Predicted Sale Prices"])
xlabel("Borough")
ylabel(["Sale Price","(log transformed)"])
title("Bayesian Optimization Model")

nexttile
boxchart(testData.borough,testData.saleprice)
hold on
boxchart(testData.borough,ashaTestPredictions)
hold off
legend(["True Sale Prices","Predicted Sale Prices"])
xlabel("Borough")
ylabel(["Sale Price","(log transformed)"])
title("ASHA Optimization Model")

% For both models, the predicted median sale price closely matches the median true sale price in each borough.
% The predicted sale prices seem to vary less than the true sale prices.

% For each model, display box charts that compare the distribution of predicted and true sale prices by the number of families in a dwelling.
% Use a 1-by-2 tiled layout to compare the results for the two models.
figure
tiledlayout(1,2)

nexttile
boxchart(testData.buildingclasscategory,testData.saleprice)
hold on
boxchart(testData.buildingclasscategory,bayesianTestPredictions)
hold off
legend(["True Sale Prices","Predicted Sale Prices"])
xlabel("Number of Families in Dwelling")
ylabel(["Sale Price","(log transformed)"])
title("Bayesian Optimization Model")

nexttile
boxchart(testData.buildingclasscategory,testData.saleprice)
hold on
boxchart(testData.buildingclasscategory,ashaTestPredictions)
hold off
legend(["True Sale Prices","Predicted Sale Prices"])
xlabel("Number of Families in Dwelling")
ylabel(["Sale Price","(log transformed)"])
title("ASHA Optimization Model")

% For both models, the predicted median sale price closely matches the median true sale price in each type of dwelling.
% The predicted sale prices seem to vary less than the true sale prices.
% For each model, plot a histogram of the test set residuals, and check that they are normally distributed.
% (Recall that the sale prices are log transformed.) Use a 1-by-2 tiled layout to compare the results for the two models.
bayesianTestResiduals = testData.saleprice - bayesianTestPredictions;
ashaTestResiduals = testData.saleprice - ashaTestPredictions;

figure
tiledlayout(1,2)

nexttile
histogram(bayesianTestResiduals)
title("Test Set Residuals (Bayesian)")

nexttile
histogram(ashaTestResiduals)
title("Test Set Residuals (ASHA)")

% Although the histograms are slightly left-skewed, they are both approximately symmetric about 0.

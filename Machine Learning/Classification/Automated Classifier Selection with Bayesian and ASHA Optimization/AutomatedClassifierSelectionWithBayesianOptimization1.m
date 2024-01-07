%% Automated Classifier Selection with Bayesian and ASHA Optimization
% This example shows how to use fitcauto to automatically try a selection of classification model types with different hyperparameter values, given training predictor and response data.
% By default, the function uses Bayesian optimization to select and assess models.
% If your training data set contains many observations, you can use an asynchronous successive halving algorithm (ASHA) instead.
% After the optimization is complete, fitcauto returns the model, trained on the entire data set, that is expected to best classify new data.
% Check the model performance on test data.

%%% Load Sample Data
% This example uses the 1994 census data stored in census1994.mat.
% The data set consists of demographic information from the US Census Bureau that can be used to predict whether an individual makes over $50,000 per year.

% Load the sample data census1994, which contains the training data adultdata and the test data adulttest.
% Preview the first few rows of the training data set.
load census1994
head(adultdata)

% Each row contains the demographic information for one adult.
% The last column salary shows whether a person has a salary less than or equal to $50,000 per year or greater than $50,000 per year.
% Remove observations from adultdata and adulttest that contain missing values.
adultdata = rmmissing(adultdata);
adulttest = rmmissing(adulttest);

%%% Use Automated Model Selection with Bayesian Optimization
% Find an appropriate classifier for the data in adultdata by using fitcauto.
% By default, fitcauto uses Bayesian optimization to select models and their hyperparameter values, and computes the cross-validation classification error (Validation loss) for each model.
% By default, fitcauto provides a plot of the optimization and an iterative display of the optimization results.
% For more information on how to interpret these results, see Verbose Display.

% Set the observation weights, and specify to run the Bayesian optimization in parallel, which requires Parallel Computing Toolbox™.
% Due to the nonreproducibility of parallel timing, parallel Bayesian optimization does not necessarily yield reproducible results.
% Because of the complexity of the optimization, this process can take some time, especially for larger data sets.
bayesianOptions = struct("UseParallel",true);
[bayesianMdl,bayesianResults] = fitcauto(adultdata,"salary","Weights","fnlwgt", ...
    "HyperparameterOptimizationOptions",bayesianOptions);

% The Total elapsed time value shows that the Bayesian optimization took a while to run (about 4.8 hours).

% The final model returned by fitcauto corresponds to the best estimated learner.
% Before returning the model, the function retrains it using the entire training data set (adultdata), the listed Learner (or model) type, and the displayed hyperparameter values.

%%% Use Automated Model Selection with ASHA Optimization
% When fitcauto with Bayesian optimization takes a long time to run because of the number of observations in your training set, consider using fitcauto with ASHA optimization instead.
% Given that adultdata contains over 10,000 observations, try using fitcauto with ASHA optimization to automatically find an appropriate classifier.
% When you use fitcauto with ASHA optimization, the function randomly chooses several models with different hyperparameter values and trains them on a small subset of the training data.
% If the cross-validation classification error (Validation Loss) of a particular model is promising, the model is promoted and trained on a larger amount of the training data.
% This process repeats, and successful models are trained on progressively larger amounts of data.
% By default, fitcauto provides a plot of the optimization and an iterative display of the optimization results.
% For more information on how to interpret these results, see Verbose Display.

% Set the observation weights, and specify to run the ASHA optimization in parallel.
% Note that ASHA optimization often has more iterations than Bayesian optimization by default.
% If you have a time constraint, you can specify the MaxTime field of the HyperparameterOptimizationOptions structure to limit the number of seconds fitcauto runs.
ashaOptions = struct("Optimizer","asha","UseParallel",true);
[ashaMdl,ashaResults] = fitcauto(adultdata,"salary","Weights","fnlwgt", ...
   "HyperparameterOptimizationOptions",ashaOptions);

% The Total elapsed time value shows that the ASHA optimization took less time to run than the Bayesian optimization (about 0.3 hours).
% The final model returned by fitcauto corresponds to the best observed learner.
% Before returning the model, the function retrains it using the entire training data set (adultdata), the listed Learner (or model) type, and the displayed hyperparameter values.

%%% Evaluate Test Set Performance
% Evaluate the performance of the returned bayesianMdl and ashaMdl models on the test set adulttest by using confusion matrices and receiver operating characteristic (ROC) curves.

% For each model, find the predicted labels and score values for the test set.
[bayesianLabels,bayesianScores] = predict(bayesianMdl,adulttest);
[ashaLabels,ashaScores] = predict(ashaMdl,adulttest);

% Create confusion matrices from the test set results.
% The diagonal elements indicate the number of correctly classified instances of a given class.
% The off-diagonal elements are instances of misclassified observations.
% Use a 1-by-2 tiled layout to compare the results.
figure
tiledlayout(1,2)

nexttile
confusionchart(adulttest.salary,bayesianLabels)
title("Bayesian Optimization")

nexttile
confusionchart(adulttest.salary,ashaLabels)
title("ASHA Optimization")

% Compute the test set classification accuracy for each model, where the accuracy is the percentage of correctly classified test set observations.
bayesianAccuracy = (1-loss(bayesianMdl,adulttest,"salary"))*100

ashaAccuracy = (1-loss(ashaMdl,adulttest,"salary"))*100

% Based on the confusion matrices and the accuracy values, bayesianMdl slightly outperforms ashaMdl on the test set.
% However, both models perform well.

% For each model, plot the ROC curve and compute the area under the ROC curve (AUC).
% The ROC curve shows the true positive rate versus the false positive rate for different thresholds of classification scores.
% For a perfect classifier, whose true positive rate is always 1 regardless of the threshold, AUC = 1.
% For a binary classifier that randomly assigns observations to classes, AUC = 0.5.
% A large AUC value (close to 1) indicates good classifier performance.

% For each model, compute the metrics for the ROC curve and find the AUC value by creating a rocmetrics object.
bayesianROC = rocmetrics(adulttest.salary,bayesianScores,bayesianMdl.ClassNames);
ashaROC = rocmetrics(adulttest.salary,ashaScores,ashaMdl.ClassNames);

% Plot the ROC curves for the label <=50K by using the plot function of rocmetrics.
figure
[r1,g1] = plot(bayesianROC,"ClassNames","<=50K");
hold on
[r2,g2] = plot(ashaROC,"ClassNames","<=50K");
r1.DisplayName = replace(r1.DisplayName,"<=50K","Bayesian Optimization");
r2.DisplayName = replace(r2.DisplayName,"<=50K","ASHA Optimization");
g1(1).DisplayName = "Bayesian Optimization Model Operating Point";
g2(1).DisplayName = "ASHA Optimization Model Operating Point";
title("ROC Curves for Class <=50K")
hold off

% Based on the AUC values, both classifiers perform well on the test data.

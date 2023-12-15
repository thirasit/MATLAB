%% Train Regression Ensemble
% This example shows how to create a regression ensemble to predict mileage of cars based on their horsepower and weight, trained on the carsmall data.
% Load the carsmall data set.
load carsmall

% Prepare the predictor data.
X = [Horsepower Weight];

% The response data is MPG. The only available boosted regression ensemble type is LSBoost.
% For this example, arbitrarily choose an ensemble of 100 trees, and use the default tree options.
% Train an ensemble of regression trees.
Mdl = fitrensemble(X,MPG,'Method','LSBoost','NumLearningCycles',100)

% Plot a graph of the first trained regression tree in the ensemble.
view(Mdl.Trained{1},'Mode','graph');

figure
imshow("TrainARegressionEnsemble1Example_01.png")
axis off;

% By default, fitrensemble grows shallow trees for LSBoost.
% Predict the mileage of a car with 150 horsepower weighing 2750 lbs.
mileage = predict(Mdl,[150 2750])







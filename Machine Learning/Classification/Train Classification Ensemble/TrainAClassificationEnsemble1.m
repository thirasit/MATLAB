%% Train Classification Ensemble
% This example shows how to create a classification tree ensemble for the ionosphere data set, and use it to predict the classification of a radar return with average measurements.
% Load the ionosphere data set.
load ionosphere

% Train a classification ensemble.
% For binary classification problems, fitcensemble aggregates 100 classification trees using LogitBoost.
Mdl = fitcensemble(X,Y)

% Plot a graph of the first trained classification tree in the ensemble.
view(Mdl.Trained{1}.CompactRegressionLearner,'Mode','graph');

% By default, fitcensemble grows shallow trees for boosting algorithms.
% You can alter the tree depth by passing a tree template object to fitcensemble.
% For more details, see templateTree.
% Predict the quality of a radar return with average predictor measurements.
label = predict(Mdl,mean(X))

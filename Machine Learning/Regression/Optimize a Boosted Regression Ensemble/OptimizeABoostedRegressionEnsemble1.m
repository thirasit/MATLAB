%% Optimize a Boosted Regression Ensemble
% This example shows how to optimize hyperparameters of a boosted regression ensemble.
% The optimization minimizes the cross-validation loss of the model.

% The problem is to model the efficiency in miles per gallon of an automobile, based on its acceleration, engine displacement, horsepower, and weight.
% Load the carsmall data, which contains these and other predictors.
load carsmall
X = [Acceleration Displacement Horsepower Weight];
Y = MPG;

% Fit a regression ensemble to the data using the LSBoost algorithm, and using surrogate splits.
% Optimize the resulting model by varying the number of learning cycles, the maximum number of surrogate splits, and the learn rate.
% Furthermore, allow the optimization to repartition the cross-validation between every iteration.

% For reproducibility, set the random seed and use the 'expected-improvement-plus' acquisition function.
rng('default')
Mdl = fitrensemble(X,Y, ...
    'Method','LSBoost', ...
    'Learner',templateTree('Surrogate','on'), ...
    'OptimizeHyperparameters',{'NumLearningCycles','MaxNumSplits','LearnRate'}, ...
    'HyperparameterOptimizationOptions',struct('Repartition',true, ...
    'AcquisitionFunctionName','expected-improvement-plus'))

% Compare the loss to that of a boosted, unoptimized model, and to that of the default ensemble.
loss = kfoldLoss(crossval(Mdl,'kfold',10))

Mdl2 = fitrensemble(X,Y, ...
    'Method','LSBoost', ...
    'Learner',templateTree('Surrogate','on'));
loss2 = kfoldLoss(crossval(Mdl2,'kfold',10))

Mdl3 = fitrensemble(X,Y);
loss3 = kfoldLoss(crossval(Mdl3,'kfold',10))

% For a different way of optimizing this ensemble, see Optimize Regression Ensemble Using Cross-Validation.

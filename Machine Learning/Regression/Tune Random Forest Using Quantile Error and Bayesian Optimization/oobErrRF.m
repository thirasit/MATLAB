%%% Define Objective Function
% Define an objective function for the Bayesian optimization algorithm to optimize.
% The function should:
% - Accept the parameters to tune as an input.
% - Train a random forest using TreeBagger. In the TreeBagger call, specify the parameters to tune and specify returning the out-of-bag indices.
% - Estimate the out-of-bag quantile error based on the median.
% - Return the out-of-bag quantile error.

function oobErr = oobErrRF(params,X)
%oobErrRF Trains random forest and estimates out-of-bag quantile error
%   oobErr trains a random forest of 300 regression trees using the
%   predictor data in X and the parameter specification in params, and then
%   returns the out-of-bag quantile error based on the median. X is a table
%   and params is an array of OptimizableVariable objects corresponding to
%   the minimum leaf size and number of predictors to sample at each node.
randomForest = TreeBagger(300,X,'MPG','Method','regression',...
    'OOBPrediction','on','MinLeafSize',params.minLS,...
    'NumPredictorstoSample',params.numPTS);
oobErr = oobQuantileError(randomForest);
end
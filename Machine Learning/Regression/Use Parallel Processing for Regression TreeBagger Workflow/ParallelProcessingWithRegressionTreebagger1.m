%% Use Parallel Processing for Regression TreeBagger Workflow
% This example shows you how to:
% - Use an ensemble of bagged regression trees to estimate feature importance.
% - Improve computation speed by using parallel computing.

% The sample data is a database of 1985 car imports with 205 observations, 25 predictors, and 1 response, which is insurance risk rating, or "symboling." The first 15 variables are numeric and the last 10 are categorical.
% The symboling index takes integer values from -3 to 3.
% Load the sample data and separate it into predictor and response arrays.
load imports-85;
Y = X(:,1);
X = X(:,2:end);

% Set up the parallel environment to use the default number of workers.
% The computer that created this example has six cores.
mypool = parpool

% Set the options to use parallel processing.
paroptions = statset('UseParallel',true);

% Estimate feature importance using leaf size 1 and 5000 trees in parallel.
% Time the function for comparison purposes.
tic
b = TreeBagger(5000,X,Y,'Method','r','OOBVarImp','on', ...
    'cat',16:25,'MinLeafSize',1,'Options',paroptions);
toc

% Perform the same computation in serial for timing comparison.
tic
b = TreeBagger(5000,X,Y,'Method','r','OOBVarImp','on', ...
    'cat',16:25,'MinLeafSize',1);
toc

% The results show that computing in parallel takes a fraction of the time it takes to compute serially.
% Note that the elapsed time can vary depending on your operating system.

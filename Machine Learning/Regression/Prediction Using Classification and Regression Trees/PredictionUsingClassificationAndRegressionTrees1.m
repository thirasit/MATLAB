%% Prediction Using Classification and Regression Trees
% This example shows how to predict class labels or responses using trained classification and regression trees.

% After creating a tree, you can easily predict responses for new data.
% Suppose Xnew is new data that has the same number of columns as the original data X.
% To predict the classification or regression based on the tree (Mdl) and the new data, enter

% Ynew = predict(Mdl,Xnew)

% For each row of data in Xnew, predict runs through the decisions in Mdl and gives the resulting prediction in the corresponding element of Ynew.
% For more information on classification tree prediction, see the predict.
% For regression, see predict.

% For example, find the predicted classification of a point at the mean of the ionosphere data.
load ionosphere 
CMdl = fitctree(X,Y);
Ynew = predict(CMdl,mean(X))

% Find the predicted MPG of a point at the mean of the carsmall data.
load carsmall 
X = [Horsepower Weight];
RMdl = fitrtree(X,MPG);
Ynew = predict(RMdl,mean(X))







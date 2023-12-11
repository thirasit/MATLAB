%% View Decision Tree
% This example shows how to view a classification or regression tree.
% There are two ways to view a tree: view(tree) returns a text description and view(tree,'mode','graph') returns a graphic description of the tree.

% Create and view a classification tree.
load fisheriris % load the sample data
ctree = fitctree(meas,species); % create classification tree
view(ctree) % text description

view(ctree,'mode','graph') % graphic description

figure
imshow("ViewingAClassificationOrRegressionTreeExample_01.png")
axis off;

% Now, create and view a regression tree.
load carsmall % load the sample data, contains Horsepower, Weight, MPG
X = [Horsepower Weight];
rtree = fitrtree(X,MPG,'MinParent',30); % create classification tree
view(rtree) % text description

% view(rtree,'mode','graph') % graphic description

figure
imshow("ViewingAClassificationOrRegressionTreeExample_02.png")
axis off;

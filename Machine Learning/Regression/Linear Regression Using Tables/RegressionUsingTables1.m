%% Linear Regression Using Tables
% This example shows how to perform linear and stepwise regression analyses using tables.

%%% Load sample data.
load imports-85

%%% Store predictor and response variables in a table.
tbl = table(X(:,7),X(:,8),X(:,9),X(:,15),'VariableNames',...
{'curb_weight','engine_size','bore','price'});

%%% Fit linear regression model.
% Fit a linear regression model that explains the price of a car in terms of its curb weight, engine size, and bore.
fitlm(tbl,'price~curb_weight+engine_size+bore')

% The command fitlm(tbl) also returns the same result because fitlm, by default, assumes the response variable is in the last column of the table tbl.

%%% Recreate table and repeat analysis.
% This time, put the response variable in the first column of the table.
tbl = table(X(:,15),X(:,7),X(:,8),X(:,9),'VariableNames',...
{'price','curb_weight','engine_size','bore'});

% When the response variable is in the first column of tbl, define its location.
% For example, fitlm, by default, assumes that bore is the response variable.
% You can define the response variable in the model using either:
fitlm(tbl,'ResponseVar','price');

% or
fitlm(tbl,'ResponseVar',logical([1 0 0 0]));

%%% Perform stepwise regression.
stepwiselm(tbl,'quadratic','lower','price~1',...
'ResponseVar','price')

figure
imshow("Opera Snapshot_2023-10-30_071020_www.mathworks.com.png")
axis off;

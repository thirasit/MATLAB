%% Nonlinear Regression Workflow
% This example shows how to do a typical nonlinear regression workflow: import data, fit a nonlinear regression, test its quality, modify it to improve the quality, and make predictions based on the model.

%%% Step 1. Prepare the data.
% Load the reaction data.
load reaction

% Examine the data in the workspace.
% reactants is a matrix with 13 rows and 3 columns.
% Each row corresponds to one observation, and each column corresponds to one variable.
% The variable names are in xn:
xn

% Similarly, rate is a vector of 13 responses, with the variable name in yn:
yn

figure
imshow("Opera Snapshot_2023-12-02_053823_www.mathworks.com.png")
axis off;

% As a start point for the solution, take b as a vector of ones.
beta0 = ones(5,1);

%%% Step 2. Fit a nonlinear model to the data.
mdl = fitnlm(reactants,...
    rate,@hougen,beta0)

%%% Step 3. Examine the quality of the model.
% The root mean squared error is fairly low compared to the range of observed values.
[mdl.RMSE min(rate) max(rate)]

% Examine a residuals plot.
figure
plotResiduals(mdl)

% The model seems adequate for the data.

% Examine a diagnostic plot to look for outliers.
figure
plotDiagnostics(mdl,'cookd')

% Observation 6 seems out of line.

%%% Step 4. Remove the outlier.
% Remove the outlier from the fit using the Exclude name-value pair.
mdl1 = fitnlm(reactants,...
    rate,@hougen,ones(5,1),'Exclude',6)

% The model coefficients changed quite a bit from those in mdl.

%%% Step 5. Examine slice plots of both models.
% To see the effect of each predictor on the response, make a slice plot using plotSlice(mdl).
plotSlice(mdl)

plotSlice(mdl1) 

% The plots look very similar, with slightly wider confidence bounds for mdl1. This difference is understandable, since there is one less data point in the fit, representing over 7% fewer observations.

%%% Step 6. Predict for new data.
% Create some new data and predict the response from both models.
Xnew =  [200,200,200;100,200,100;500,50,5];
[ypred yci] = predict(mdl,Xnew)

[ypred1 yci1] = predict(mdl1,Xnew)

% Even though the model coefficients are dissimilar, the predictions are nearly identical.

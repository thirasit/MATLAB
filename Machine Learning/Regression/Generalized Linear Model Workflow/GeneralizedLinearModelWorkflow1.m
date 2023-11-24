%% Generalized Linear Model Workflow
% This example shows how to fit a generalized linear model and analyze the results.
% A typical workflow involves these steps: import data, fit a generalized linear model, test its quality, modify the model to improve its quality, and make predictions based on the model.
% In this example, you use the Fisher iris data to compute the probability that a flower is in one of two classes.

%%% Load Data
% Load the Fisher iris data.
load fisheriris

% Extract rows 51 to 150, which have the classification versicolor or virginica.
X = meas(51:end,:);

% Create logical response variables that are true for versicolor and false for virginica.
y = strcmp('versicolor',species(51:end));

%%% Fit Generalized Linear Model
% Fit a binomial generalized linear model to the data.
mdl = fitglm(X,y,'linear','Distribution','binomial')

% According to the model display, some p-values in the pValue column are not small, which implies that you can simplify the model.

%%% Examine and Improve Model
% Determine if 95% confidence intervals for the coefficients include 0.
% If so, you can remove the model terms with those intervals.
confint = coefCI(mdl)

% Only the fourth predictor x3 has a coefficient whose confidence interval does not include 0.
% The coefficients of x1 and x2 have large p-values and their 95% confidence intervals include 0.
% Test whether both coefficients can be zero.
% Specify a hypothesis matrix to select the coefficients of x1 and x2.
M = [0 1 0 0 0     
     0 0 1 0 0];   
p = coefTest(mdl,M)

% The p-value is approximately 0.14, which is not small.
% Remove x1 and x2 from the model.
mdl1 = removeTerms(mdl,'x1 + x2')

% Alternatively, you can identify important predictors using stepwiseglm.
mdl2 = stepwiseglm(X,y,'constant','Distribution','binomial','Upper','linear')

% The p-value (pValue) for x2 in the coefficient table is greater than 0.05, but stepwiseglm includes x2 in the model because the p-value (PValue) for adding x2 is smaller than 0.05.
% The stepwiseglm function computes PValue using the fits with and without x2, whereas the function computes pValue based on an approximate standard error computed only from the final model.
% Therefore, PValue is more reliable than pValue.

%%% Identify Outliers
% Examine a leverage plot to look for influential outliers.
figure
plotDiagnostics(mdl2,'leverage')

% An observation can be considered an outlier if its leverage substantially exceeds p/n, where p is the number of coefficients and n is the number of observations.
% The dotted reference line is a recommended threshold, computed by 2*p/n, which corresponds to 0.08 in this plot.
% Some observations have leverage values larger than 10*p/n (that is, 0.40).
% Identify these observation points.
idxOutliers = find(mdl2.Diagnostics.Leverage > 10*mdl2.NumCoefficients/mdl2.NumObservations)

% See if the model coefficients change when you fit a model excluding these points.
oldCoeffs = mdl2.Coefficients.Estimate;
mdl3 = fitglm(X,y,'linear','Distribution','binomial', ...
    'PredictorVars',2:4,'Exclude',idxOutliers);
newCoeffs = mdl3.Coefficients.Estimate;
disp([oldCoeffs newCoeffs])

% The model coefficients in mdl3 are different from those in mdl2.
% This result implies that the responses at the high-leverage points are not consistent with the predicted values from the reduced model.

%%% Predict Probability of Being Versicolor
% Use mdl3 to predict the probability that a flower with average measurements is versicolor.
% Generate confidence intervals for the prediction.
[newf,newc] = predict(mdl3,mean(X))

% The model gives almost a 46% probability that the average flower is versicolor, with a wide confidence interval.

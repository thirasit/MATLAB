%% Regularize Logistic Regression
% This example shows how to regularize binomial regression.
% The default (canonical) link function for binomial regression is the logistic function.

%%% Step 1. Prepare the data.
% Load the ionosphere data. The response Y is a cell array of 'g' or 'b' characters.
% Convert the cells to logical values, with true representing 'g'.
% Remove the first two columns of X because they have some awkward statistical properties, which are beyond the scope of this discussion.
load ionosphere
Ybool = strcmp(Y,'g');
X = X(:,3:end);

%%% Step 2. Create a cross-validated fit.
% Construct a regularized binomial regression using 25 Lambda values and 10-fold cross validation.
% This process can take a few minutes.
rng('default') % for reproducibility
[B,FitInfo] = lassoglm(X,Ybool,'binomial',...
    'NumLambda',25,'CV',10);

%%% Step 3. Examine plots to find appropriate regularization.
% lassoPlot can give both a standard trace plot and a cross-validated deviance plot.
% Examine both plots.
figure
lassoPlot(B,FitInfo,'PlotType','CV');
legend('show','Location','best') % show legend

% The plot identifies the minimum-deviance point with a green circle and dashed line as a function of the regularization parameter Lambda.
% The blue circled point has minimum deviance plus no more than one standard deviation.
figure
lassoPlot(B,FitInfo,'PlotType','Lambda','XScale','log');

% The trace plot shows nonzero model coefficients as a function of the regularization parameter Lambda.
% Because there are 32 predictors and a linear model, there are 32 curves.
% As Lambda increases to the left, lassoglm sets various coefficients to zero, removing them from the model.
% The trace plot is somewhat compressed. Zoom in to see more detail.
figure
lassoPlot(B,FitInfo,'PlotType','Lambda','XScale','log');
xlim([.01 .1])
ylim([-3 3])

% As Lambda increases toward the left side of the plot, fewer nonzero coefficients remain.
% Find the number of nonzero model coefficients at the Lambda value with minimum deviance plus one standard deviation point.
% The regularized model coefficients are in column FitInfo.Index1SE of the B matrix.
indx = FitInfo.Index1SE;
B0 = B(:,indx);
nonzeros = sum(B0 ~= 0)

% When you set Lambda to FitInfo.Index1SE, lassoglm removes over half of the 32 original predictors.

%%% Step 4. Create a regularized model.
% The constant term is in the FitInfo.Index1SE entry of the FitInfo.Intercept vector.
% Call that value cnst.
% The model is logit(mu) = log(mu/(1 - mu)) = X*B0 + cnst .
% Therefore, for predictions, mu = exp(X*B0 + cnst)/(1+exp(x*B0 + cnst)).
% The glmval function evaluates model predictions.
% It assumes that the first model coefficient relates to the constant term.
% Therefore, create a coefficient vector with the constant term first.
cnst = FitInfo.Intercept(indx);
B1 = [cnst;B0];

%%% Step 5. Examine residuals.
% Plot the training data against the model predictions for the regularized lassoglm model.
figure
preds = glmval(B1,X,'logit');
histogram(Ybool - preds) % plot residuals
title('Residuals from lassoglm model')

%%% Step 6. Alternative: Use identified predictors in a least-squares generalized linear model.
% Instead of using the biased predictions from the model, you can make an unbiased model using just the identified predictors.
predictors = find(B0); % indices of nonzero predictors
mdl = fitglm(X,Ybool,'linear',...
    'Distribution','binomial','PredictorVars',predictors)

% Plot the residuals of the model.
figure
plotResiduals(mdl)

% As expected, residuals from the least-squares model are slightly smaller than those of the regularized model.
% However, this does not mean that mdl is a better predictor for new data.

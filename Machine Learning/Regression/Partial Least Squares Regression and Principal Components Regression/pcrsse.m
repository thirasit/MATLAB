function sse = pcrsse(Xtrain,ytrain,Xtest,ytest)
%PCRSSE SSE for Principal Components Regression cross-validation.
% This function is used in the demo PLSPCRDEMO.
%
% SSE = PCRSSE(XTRAIN,YTRAIN,XTEST,YTEST,NCOMP) returns a vector of sum of
% squared prediction errors for principal components regression models with
% 0:10 components, with XTRAIN and YTRAIN as training data, and XTEST and
% YTEST as test data.

%   Copyright 2008 The MathWorks, Inc.


maxNumComp = 10;
sse = zeros(1,maxNumComp+1);

% The 0'th model is just the mean of the training response data.
yfit0 = mean(ytrain);
sse(1) = sum((ytest - yfit0).^2);

% Compute PCA loadings from the training predictor data, and regress the first
% 10 principal components on the centered traiing response data.
[Loadings,Scores] = pca(Xtrain,'Economy',false);
beta = regress(ytrain-yfit0, Scores(:,1:maxNumComp));

% Compute predictions for the 1st through 10th model.
for ncomp = 1:maxNumComp
    beta0 = Loadings(:,1:ncomp)*beta(1:ncomp);
    beta1 = [yfit0 - mean(Xtrain)*beta0; beta0];
    yfit = [ones(size(Xtest,1),1) Xtest]*beta1;
    sse(ncomp+1) = sum((ytest - yfit).^2);
end

function helperPlotSVM(SVMModel,TestData)
%helperPlotSVM Generate SVM boundary and view outliers.
%
% This function is only in support of
% CentrifugalPumpFaultDiagnosisUsingSteadyStateExperimentsExample. It may
% change in a future release.

% Copyright 2017-2018 The MathWorks, Inc.

svInd = SVMModel.IsSupportVector;
dd = min(abs(diff(TestData)))/10;

[X1,X2] = meshgrid(min(TestData(:,1)):dd(1):max(TestData(:,1)),...
   min(TestData(:,2)):dd(2):max(TestData(:,2)));
[~,score] = predict(SVMModel,[X1(:),X2(:)]);
scoreGrid = reshape(score,size(X1,1),size(X2,2));
[~,score1] = predict(SVMModel,TestData);
outlierInd = score1>0;

plot(TestData(:,1),TestData(:,2),'k.')
hold on
plot(TestData(svInd,1),TestData(svInd,2),'go','MarkerSize',6)
plot(TestData(outlierInd,1),TestData(outlierInd,2),'ro','MarkerSize',10)
[C,h] = contour(X1,X2,scoreGrid);
clabel(C,h,0,'Color','k','LabelSpacing',50,'FontSize',6);
colorbar;
legend('Data','Support Vector','Outliers')
hold off
end
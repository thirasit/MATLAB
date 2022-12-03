function helperAddDistanceLines(PlotNo, Distance, Mean, TestTheta, Threshold)
%helperAddDistanceLines Add Mahanobis distance lines to the confidence region plot.
%
% This function is only in support of
% CentrifugalPumpFaultDiagnosisUsingSteadyStateExperimentsExample. It may
% change in a future release.

% Copyright 2017 The MathWorks, Inc.

subplot(1,2,PlotNo)
hold on
for ct = 1:size(TestTheta,1)
   if Distance(ct)>Threshold^2
      Color = [1 0 0];
   else
      Color = [0 1 .2];
   end
   line([Mean(1);TestTheta(ct,1)],...
      [Mean(2);TestTheta(ct,2)],...
      [Mean(3); TestTheta(ct,3)],'Color',Color)
   text(TestTheta(ct,1),TestTheta(ct,2),TestTheta(ct,3),num2str(Distance(ct),2))
end

function [hFig,batchLine,validationLine] = initializeTrainingPlotRAWToRGB

% Copyright 2021 The MathWorks, Inc.

hFig = figure;
hAx = axes;
batchLine = animatedline(Color="red",Parent=hAx);
validationLine = animatedline(Color="blue",LineStyle="--",Parent=hAx);
legend(hAx,"MiniBatchLoss","ValidationLoss");

grid on
grid minor

end
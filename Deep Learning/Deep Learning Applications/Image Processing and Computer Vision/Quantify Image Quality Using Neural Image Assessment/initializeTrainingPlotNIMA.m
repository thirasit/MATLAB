function [hFig,lineLossTrain,lineLossValid] = initializeTrainingPlotNIMA

% Copyright 2020 The MathWorks, Inc.

hFig = figure;
hAx = axes;
lineLossTrain = animatedline('Color',[0.85 0.325 0.098], ...
    'DisplayName','Training Loss','Parent',hAx);
lineLossValid = animatedline('LineStyle','--', ...
    'Marker','o','MarkerFaceColor','black', ...
    'DisplayName','Validation Loss','Parent',hAx);
ylim([0 inf])
xlabel("Iteration")
ylabel("Loss")
legend
grid on

end
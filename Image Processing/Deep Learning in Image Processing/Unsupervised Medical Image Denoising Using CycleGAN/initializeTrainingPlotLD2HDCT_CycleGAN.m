function [figureHandle, tileHandle, imageAxes, scoreAxesX, scoreAxesY, ...
    lineScoreGeneratorLowDoseToHighDose, lineScoreGeneratorHighDoseToLowDose, ...
    lineScoreDiscriminatorHighDose, lineScoreDiscriminatorLowDose] = initializeTrainingPlotLD2HDCT_CycleGAN()
% initializeTrainingPlotLD2HDCT_CycleGAN - Initialize the handles for training scores and generated images 

%   Copyright 2021 The MathWorks, Inc.

figureHandle = figure;
figureHandle.Position(3) = 2*figureHandle.Position(3);

% Create subplots to plot generated images and network scores.
tileHandle = tiledlayout(figureHandle,1,6);

imageAxes = nexttile(1,[1 2]);
% Customize the appearance of the plots.
xticklabels([]);
yticklabels([]);
grid off

scoreAxesX = nexttile(3,[1 2]);
% Customize the appearance of the plots.
xlabel("Iteration")
ylabel("Score")
grid on

scoreAxesY = nexttile(5,[1 2]);
% Customize the appearance of the plots.
xlabel("Iteration")
ylabel("Score")
grid on

% Initialize animated lines for the plot containing scores for each iteration.
lineScoreGeneratorHighDoseToLowDose = animatedline(scoreAxesX,'Color',[0 0.4470 0.7410]);
lineScoreGeneratorLowDoseToHighDose = animatedline(scoreAxesY,'Color',[0.8500 0.3250 0.0980]);

lineScoreDiscriminatorLowDose = animatedline(scoreAxesX,'Color', [0.9290 0.6940 0.1250]);
lineScoreDiscriminatorHighDose = animatedline(scoreAxesY,'Color', [0.4940 0.1840 0.5560]);

end
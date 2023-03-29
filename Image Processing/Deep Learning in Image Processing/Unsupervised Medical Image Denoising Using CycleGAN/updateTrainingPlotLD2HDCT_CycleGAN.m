function updateTrainingPlotLD2HDCT_CycleGAN(scores, iteration, epoch, start, scoreAxesX, scoreAxesY,...
    lineScoreGeneratorLowDoseToHighDose, lineScoreGeneratorHighDoseToLowDose, ...
    lineScoreDiscriminatorHighDose, lineScoreDiscriminatorLowDose)
%updateTrainingPlotLD2HDCT_CycleGAN - Plot the scores for the two generators
%  and two discriminators of the CycleGAN network at each iteration.

%   Copyright 2021 The MathWorks, Inc.

% Generator_{LowDoseToHighDose} and Discriminator_{HighDose}
addpoints(lineScoreGeneratorLowDoseToHighDose,iteration,...
    double(gather(extractdata(scores{2}))));

addpoints(lineScoreDiscriminatorHighDose,iteration,...
    double(gather(extractdata(scores{4}))));

legend(scoreAxesX, 'Generator_{LowDoseToHighDose}','Discriminator_{HighDose}');

% Generator_{HighDoseToLowDose} and Discriminator_{LowDose}
addpoints(lineScoreGeneratorHighDoseToLowDose,iteration,...
    double(gather(extractdata(scores{1}))));

addpoints(lineScoreDiscriminatorLowDose,iteration,...
    double(gather(extractdata(scores{3}))));

legend(scoreAxesY,'Generator_{HighDoseToLowDose}','Discriminator_{LowDose}');

% Update the title with training progress information.
D = duration(0,0,toc(start),'Format','hh:mm:ss');
title(...
    "Epoch: " + epoch + ", " + ...
    "Iteration: " + iteration + ", " + ...
    "Elapsed: " + string(D))

drawnow;

end
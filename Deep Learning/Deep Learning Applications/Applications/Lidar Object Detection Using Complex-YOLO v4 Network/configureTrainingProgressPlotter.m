%% Utility Functions
function [lossPlotter,learningRatePlotter] = configureTrainingProgressPlotter(f)
% Create the subplots to display the loss and learning rate.

    figure(f);
    clf
    subplot(2,1,1);
    ylabel('Learning Rate');
    xlabel('Iteration');
    learningRatePlotter = animatedline;
    subplot(2,1,2);
    ylabel('Total Loss');
    xlabel('Iteration');
    lossPlotter = animatedline;
end

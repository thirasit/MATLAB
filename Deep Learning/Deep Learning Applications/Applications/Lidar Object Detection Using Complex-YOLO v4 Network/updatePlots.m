%% Utility Functions
function updatePlots(lossPlotter,learningRatePlotter,iteration,currentLR,totalLoss)
% Update loss and learning rate plots.
    addpoints(lossPlotter,iteration,double(extractdata(gather(totalLoss))));
    addpoints(learningRatePlotter, iteration,currentLR);
    drawnow
end

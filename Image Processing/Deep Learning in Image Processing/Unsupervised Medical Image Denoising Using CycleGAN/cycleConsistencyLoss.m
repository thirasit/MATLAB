%%% Supporting Functions
% Specify cycle consistency loss functions for real and generated images.
function loss = cycleConsistencyLoss(imageReal,imageGenerated,lambda)
    loss = mean(abs(imageReal-imageGenerated),"all") * lambda;
end
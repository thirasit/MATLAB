%% Supporting Functions
% Loss Functions
% The computeReconLoss helper function calculates the self-reconstruction loss and cycle-consistency loss for the generator.
% Self-reconstruction loss is the L^1 distance between the input images and their self-reconstructed versions.
% Cycle-consistency loss is the L^1 distance between the input images and their cycle-reconstructed versions.
% selfReconstructionLoss=‖(Y_real−Y_self−reconstructed)‖_1
% cycleConsistencyLoss=‖(Y_real−Y_cycle−reconstructed)‖_1
function reconLoss = computeReconLoss(Yreal,Yrecon)
    reconLoss = mean(abs(Yreal-Yrecon),"all");
end

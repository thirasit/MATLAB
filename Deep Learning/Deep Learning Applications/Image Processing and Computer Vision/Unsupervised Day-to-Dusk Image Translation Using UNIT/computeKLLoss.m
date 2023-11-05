%% Supporting Functions
% Loss Functions
% The computeKLLoss helper function calculates the hidden KL loss and cycle-hidden KL loss for the generator.
% Hidden KL loss is the squared difference between a vector of zeros and the encoderSharedBlock activation for the self-reconstruction stream.
% Cycle-hidden KL loss is the squared difference between a vector of zeros and the encoderSharedBlock activation for the cycle-reconstruction stream.
% hiddenKLLoss=(0−Y_encoderSharedBlockActivation)^2
% cycleHiddenKLLoss=(0−Y_encoderSharedBlockActivation)^2
function klLoss = computeKLLoss(hidden)
    klLoss = mean(abs(hidden.^2),"all");
end

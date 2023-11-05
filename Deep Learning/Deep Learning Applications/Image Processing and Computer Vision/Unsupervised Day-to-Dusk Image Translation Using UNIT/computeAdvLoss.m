%% Supporting Functions
% Loss Functions
% The computeAdvLoss helper function calculates the adversarial loss for the generator.
% Adversarial loss is the squared difference between a vector of ones and the discriminator predictions on the translated image.
% adversarialLoss=(1−ˆY_translated)^2
function advLoss = computeAdvLoss(Ytranslated)
    advLoss = mean(((Ytranslated-1).^2),"all");
end

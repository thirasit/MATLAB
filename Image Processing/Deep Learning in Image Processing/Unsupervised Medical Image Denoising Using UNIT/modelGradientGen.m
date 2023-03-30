%%% Supporting Functions
% Model Gradients Function
% The modelGradientGen helper function calculates the gradients and loss for the generator.
function [genGrad,genLoss,images] = modelGradientGen(gen,discLD,discHD,imLD,imHD,lossWeights)
    
    [imLD2LD,imHD2LD,imLD2HD,imHD2HD] = forward(gen,imLD,imHD);
    hidden = forward(gen,imLD,imHD,Outputs="encoderSharedBlock");
    
    [~,imLD2HD2LD,imHD2LD2HD,~] = forward(gen,imHD2LD,imLD2HD);
    cycle_hidden = forward(gen,imHD2LD,imLD2HD,Outputs="encoderSharedBlock");
    
    % Calculate different losses
    selfReconLoss = computeReconLoss(imLD,imLD2LD) + computeReconLoss(imHD,imHD2HD);
    hiddenKLLoss = computeKLLoss(hidden);
    cycleReconLoss = computeReconLoss(imLD,imLD2HD2LD) + computeReconLoss(imHD,imHD2LD2HD);
    cycleHiddenKLLoss = computeKLLoss(cycle_hidden);
    
    outA = forward(discLD,imHD2LD);
    outB = forward(discHD,imLD2HD);
    advLoss = computeAdvLoss(outA) + computeAdvLoss(outB);
    
    % Calculate the total loss of generator as a weighted sum of five losses
    genTotalLoss = ...
        selfReconLoss*lossWeights.selfReconLossWeight + ...
        hiddenKLLoss*lossWeights.hiddenKLLossWeight + ...
        cycleReconLoss*lossWeights.cycleConsisLossWeight + ...
        cycleHiddenKLLoss*lossWeights.cycleHiddenKLLossWeight + ...
        advLoss*lossWeights.advLossWeight;
    
    % Update the parameters of generator
    genGrad = dlgradient(genTotalLoss,gen.Learnables); 
    
    % Convert the data type from dlarray to single
    genLoss = extractdata(genTotalLoss);
    images = {imLD,imLD2HD,imHD,imHD2LD};
end
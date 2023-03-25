% The modelGradientGen helper function calculates the gradients and loss for the generator.
function [genGrad,genLoss,images] = modelGradientGen(gen, ...
    discA,discB,ImageA,ImageB,lossWeights)
    
    [ImageAA,ImageBA,ImageAB,ImageBB] = forward(gen,ImageA,ImageB);
    hidden = forward(gen,ImageA,ImageB,Outputs="encoderSharedBlock");
    
    [~,ImageABA,ImageBAB,~] = forward(gen,ImageBA,ImageAB);
    cycle_hidden = forward(gen,ImageBA,ImageAB,Outputs="encoderSharedBlock");
    
    % Calculate different losses
    selfReconLoss = computeReconLoss(ImageA,ImageAA) + computeReconLoss(ImageB,ImageBB);
    hiddenKLLoss = computeKLLoss(hidden);
    cycleReconLoss = computeReconLoss(ImageA,ImageABA) + computeReconLoss(ImageB,ImageBAB);
    cycleHiddenKLLoss = computeKLLoss(cycle_hidden);
    
    outA = forward(discA,ImageBA);
    outB = forward(discB,ImageAB);
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
    images = {ImageA,ImageAB,ImageB,ImageBA};
end
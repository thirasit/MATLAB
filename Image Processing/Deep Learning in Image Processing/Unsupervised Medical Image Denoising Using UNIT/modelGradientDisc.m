%%% Supporting Functions
% The modelGradientDisc helper function calculates the gradients and loss for the two discriminators.
function [discLDGrads,discHDGrads,discLDLoss,discHDLoss] = modelGradientDisc(gen, ...
    discLD,discHD,imRealLD,imRealHD,discLossWeight)

    [~,imFakeLD,imFakeHD,~] = forward(gen,imRealLD,imRealHD);
    
    % Calculate loss of the discriminator for low-dose images
    outRealLD = forward(discLD,imRealLD); 
    outFakeLD = forward(discLD,imFakeLD);
    discLDLoss = discLossWeight*computeDiscLoss(outRealLD,outFakeLD);
    
    % Update parameters of the discriminator for low-dose images
    discLDGrads = dlgradient(discLDLoss,discLD.Learnables); 
    
    % Calculate loss of the discriminator for high-dose images
    outRealHD = forward(discHD,imRealHD); 
    outFakeHD = forward(discHD,imFakeHD);
    discHDLoss = discLossWeight*computeDiscLoss(outRealHD,outFakeHD);
    
    % Update parameters of the discriminator for high-dose images
    discHDGrads = dlgradient(discHDLoss,discHD.Learnables);
    
    % Convert the data type from dlarray to single
    discLDLoss = extractdata(discLDLoss);
    discHDLoss = extractdata(discHDLoss);
end

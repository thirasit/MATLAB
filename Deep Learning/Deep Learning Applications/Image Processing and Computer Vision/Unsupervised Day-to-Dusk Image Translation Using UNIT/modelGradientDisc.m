%% Supporting Functions
% Model Gradients Functions
% The modelGradientDisc helper function calculates the gradients and loss for the two discriminators.
function [discAGrads,discBGrads,discALoss,discBLoss] = modelGradientDisc(gen, ...
    discA,discB,ImageA,ImageB,discLossWeight)

    [~,fakeA,fakeB,~] = forward(gen,ImageA,ImageB);
    
    % Calculate loss of the discriminator for X_A
    outA = forward(discA,ImageA); 
    outfA = forward(discA,fakeA);
    discALoss = discLossWeight*computeDiscLoss(outA,outfA);
    
    % Update parameters of the discriminator for X
    discAGrads = dlgradient(discALoss,discA.Learnables); 
    
    % Calculate loss of the discriminator for X_B
    outB = forward(discB,ImageB); 
    outfB = forward(discB,fakeB);
    discBLoss = discLossWeight*computeDiscLoss(outB,outfB);
    
    % Update parameters of the discriminator for Y
    discBGrads = dlgradient(discBLoss,discB.Learnables);
    
    % Convert the data type from dlarray to single
    discALoss = extractdata(discALoss);
    discBLoss = extractdata(discBLoss);
end

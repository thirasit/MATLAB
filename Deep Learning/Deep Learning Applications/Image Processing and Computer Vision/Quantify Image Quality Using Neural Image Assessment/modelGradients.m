%% Supporting Functions
%%% Model Gradients Function
% The modelGradients function takes as input a dlnetwork object dlnet and a mini-batch of input data dlX with corresponding target cumulative probabilities cdfY.
% The function returns the gradients of the loss with respect to the learnable parameters in dlnet as well as the loss.
% To compute the gradients automatically, use the dlgradient function.
function [gradients,loss] = modelGradients(dlnet,dlX,cdfY)
    dlYPred = forward(dlnet,dlX);    
    loss = earthMoverDistance(dlYPred,cdfY,2);    
    gradients = dlgradient(loss,dlnet.Learnables);    
end

%%% Supporting Functions
%%% Model Gradients Function
% The modelGradients helper function calculates the gradients and overall loss.
% The gradient information is returned as a table which includes the layer, parameter name and value for each learnable parameter in the model.
function [gradients,loss] = modelGradients(dlnet,vggNet,X,T,weightContent)
    Y = forward(dlnet,X);
    lossMAE = maeLoss(Y,T);
    lossContent = contentLoss(vggNet,Y,T);
    loss = lossMAE + weightContent.*lossContent;
    gradients = dlgradient(loss,dlnet.Learnables);
end
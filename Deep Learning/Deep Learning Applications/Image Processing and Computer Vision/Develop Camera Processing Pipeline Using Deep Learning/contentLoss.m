%% Supporting Functions
%%% Content Loss Function
% The helper function contentLoss calculates a weighted sum of the MSE between network predictions, Y, and target images, T, for each activation layer. The contentLoss helper function calculates the MSE for each activation layer using the mseLoss helper function. Weights are selected such that the loss from each activation layers contributes roughly equally to the overall content loss.
function loss = contentLoss(net,Y,T)

    layers = ["relu1_1","relu1_2","relu2_1","relu2_2", ...
        "relu3_1","relu3_2","relu3_3","relu4_1"];
    [T1,T2,T3,T4,T5,T6,T7,T8] = forward(net,T,Outputs=layers);
    [X1,X2,X3,X4,X5,X6,X7,X8] = forward(net,Y,Outputs=layers);
    
    l1 = mseLoss(X1,T1);
    l2 = mseLoss(X2,T2);
    l3 = mseLoss(X3,T3);
    l4 = mseLoss(X4,T4);
    l5 = mseLoss(X5,T5);
    l6 = mseLoss(X6,T6);
    l7 = mseLoss(X7,T7);
    l8 = mseLoss(X8,T8);
    
    layerLosses = [l1 l2 l3 l4 l5 l6 l7 l8];
    weights = [1 0.0449 0.0107 0.0023 6.9445e-04 2.0787e-04 2.0118e-04 6.4759e-04];
    loss = sum(layerLosses.*weights);  
end
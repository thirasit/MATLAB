%%% Supporting Functions
%%% Mean Square Error Loss Function
% The helper function mseLoss computes the MSE between network predictions, Y, and target images, T.
function loss = mseLoss(Y,T)
    loss = mean((Y-T).^2,"all");
end
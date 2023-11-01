%% Supporting Functions
%%% Mean Absolute Error Loss Function
% The helper function maeLoss computes the mean absolute error between network predictions, Y, and target images, T.
function loss = maeLoss(Y,T)
    loss = mean(abs(Y-T),"all");
end

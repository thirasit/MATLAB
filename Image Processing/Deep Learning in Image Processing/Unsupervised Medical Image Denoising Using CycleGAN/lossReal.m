%%% Supporting Functions
% Loss Functions
% Specify MSE loss functions for real and generated images.
function loss = lossReal(predictions)
    loss = mean((1-predictions).^2,"all");
end

function loss = lossGenerated(predictions)
    loss = mean((predictions).^2,"all");
end
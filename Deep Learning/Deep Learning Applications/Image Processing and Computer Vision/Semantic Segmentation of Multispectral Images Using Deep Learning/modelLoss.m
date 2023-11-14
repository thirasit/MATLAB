%% Helper Function
% The modelLoss function calculates cross entropy loss over all unmasked pixels of an image.
function loss = modelLoss(y,targets)
    mask = ~isnan(targets);
    targets(isnan(targets)) = 0;
    loss = crossentropy(y,targets,Mask=mask);
end
%% Loss Functions
% Compute the binary cross-entropy loss for the class confidence score.
function clsLoss = classConfidenceLoss(classPredCell,classTarget,boxMaskTarget)
    clsLoss = sum(cellfun(@(a,b,c) crossentropy(a.*c,b.*c,'ClassificationMode','multilabel'),classPredCell,classTarget,boxMaskTarget(:,3)));
end

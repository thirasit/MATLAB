%% Loss Functions
% Compute the binary cross-entropy loss for the objectness score.
function objLoss = objectnessLoss(objectnessPredCell,objectnessDeltaTarget,boxMaskTarget)
    objLoss = sum(cellfun(@(a,b,c) crossentropy(a.*c,b.*c,'ClassificationMode','multilabel'),objectnessPredCell,objectnessDeltaTarget,boxMaskTarget(:,2)));
end

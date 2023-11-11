function [tpr, fpr, ppv] = computeROCCurvesForCamelyon16(bheatMapImages, testMasks, testTissueMasks, THRESHOLDS)
% Compute ROC stats from heatmaps and ground truth masks.

% Copyright 2021 The MathWorks, Inc.

tpr = zeros(1, numel(THRESHOLDS));
fpr = zeros(1, numel(THRESHOLDS));
ppv = zeros(1, numel(THRESHOLDS));

cInd = 1;

for THRESHOLD = THRESHOLDS
    
    % Compute confusion matrix at this threshold for all images/blocks.
    for ind = 1:numel(testMasks)
        bcmatrix(ind) = apply(bheatMapImages(ind),...
            @(bs,tum, tim)computeBlockConfusionMatrixForCamelyon16(bs, tum, tim, THRESHOLD),...
            'ExtraImages', [testMasks(ind), testTissueMasks(ind)]);
    end
    
    % Read confusion matrix into memory
    cmArray = arrayfun(@(c)gather(c), bcmatrix);
    
    % Sum across images/blocks.
    cm = [sum([cmArray.tp]), sum([cmArray.fp]);
        sum([cmArray.fn]), sum([cmArray.tn])];
    
    % Compute curve stats. Units: number of blocks at finest level
    tpr(cInd) = cm(1,1)/sum(cm(:,1)); % tp/(tp+fn)
    fpr(cInd) = cm(1,2)/sum(cm(:,2)); % fp/(fp+tn)
    % Precision, positive predictive value
    ppv(cInd) = cm(1,1)/sum(cm(1,:)); % tp/(tp+fp)
    cInd = cInd+1;
end
end
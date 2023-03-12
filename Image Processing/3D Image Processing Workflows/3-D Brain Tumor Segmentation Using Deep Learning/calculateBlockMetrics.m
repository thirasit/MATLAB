function blockMetrics = calculateBlockMetrics(bstruct,gtBlockLabels,net)

% Segment block
predBlockLabels = semanticseg(bstruct.Data,net);

% Trim away border region from gtBlockLabels 
blockStart = bstruct.BorderSize + 1;
blockEnd = blockStart + bstruct.BlockSize - 1;
gtBlockLabels = gtBlockLabels( ...
    blockStart(1):blockEnd(1), ...
    blockStart(2):blockEnd(2), ...
    blockStart(3):blockEnd(3));

% Evaluate segmentation results against ground truth
confusionMat = segmentationConfusionMatrix(predBlockLabels,gtBlockLabels);

% blockMetrics is a struct with confusion matrices, image number,
% and block information. 
blockMetrics.ConfusionMatrix = confusionMat;
blockMetrics.ImageNumber = bstruct.ImageNumber;
blockInfo.Start = bstruct.Start;
blockInfo.End = bstruct.End;
blockMetrics.BlockInfo = blockInfo;

end

%%% Supporting Function
% The calculateBlockMetrics helper function performs semantic segmentation of a block and calculates the confusion matrix between the predicted and ground truth labels. 
% The function returns a structure with fields containing the confusion matrix and metadata about the block. 
% You can use the structure with the evaluateSemanticSegmentation function to calculate metrics and aggregate block-based results.

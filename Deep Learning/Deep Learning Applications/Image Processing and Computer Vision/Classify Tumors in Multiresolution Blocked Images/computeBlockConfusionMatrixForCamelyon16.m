function [cmatrix, cmatrixImage] = computeBlockConfusionMatrixForCamelyon16(bstruct, tumorMask, tissueMask, THRESHOLD)
% Compute the confusion matrix at the block level.

% Copyright 2021 The MathWorks, Inc.

heatMap = bstruct.Data;

% The detection heatmap is smaller than the mask (since its a single value
% per block). So resize the masks down.
tissueMask = imresize(tissueMask, size(heatMap), 'nearest');
tumorMask = imresize(tumorMask, size(heatMap), 'nearest');

% The heatMap is computed on blocks which at least have one tissue pixel in
% them. The tissueMask needs to be expanded to account for this
% InclusionThreshold used to compute the heat maps.
tissueMask = tissueMask | heatMap>0;

% Apply chosen threshold. true implies Tumor.
detection = heatMap>=THRESHOLD;

% Compute confusion matrix images
tp = detection&tumorMask & tissueMask;
fp = detection&~tumorMask & tissueMask;
tn = ~detection& ~tumorMask & tissueMask;
fn = ~detection&tumorMask & tissueMask;

% Create a visualization of the confusion matrix image for a deeper
% understanding. Use uint8 type to save space.
cmatrixImage = onehotdecode(uint8(cat(3,tn, fp, fn, tp)),...
    uint8([0 1 2 3]), 3, 'uint8');

% Compute confusion matrix (units: number of pixels at the mask level)
cmatrix.tp = sum(tp,'all');
cmatrix.fp = sum(fp,'all');
cmatrix.tn = sum(tn,'all');
cmatrix.fn = sum(fn,'all');
end
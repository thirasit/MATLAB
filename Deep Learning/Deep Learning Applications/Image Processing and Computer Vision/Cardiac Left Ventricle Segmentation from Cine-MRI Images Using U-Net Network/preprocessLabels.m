%%% Supporting Functions
% The preprocessLabels helper function preprocesses label images using these steps:
% 1. Resize the input label image to the target size of the network. The function uses nearest neighbor interpolation so that the output is a binary image without partial decimal values.
% 2. Return the preprocessed image in a cell array.
function out = preprocessLabels(labels, targetSize)
% Copyright 2023 The MathWorks, Inc.

    targetSize = targetSize(1:2);
    labels = imresize(labels{1},targetSize,"nearest");

    out = {labels};

end

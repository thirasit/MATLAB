%%% Supporting Functions
% The preprocessImage helper function preprocesses the MRI images using these steps:
% 1. Resize the input image to the target size of the network.
% 2. Convert grayscale images to three channel images.
% 3. Return the preprocessed image in a cell array.
function out = preprocessImage(img,targetSize)
% Copyright 2023 The MathWorks, Inc.

    targetSize = targetSize(1:2);
    img = imresize(img,targetSize);

    if size(img,3) == 1
        img = repmat(img,[1 1 3]);
    end

    out = {img};

end

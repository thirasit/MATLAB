%%% Supporting Functions
% The augmentDataForLVSegmentation helper function randomly applies these augmentations to each input image and its corresponding label image. The function returns the output data in a cell array.
% - Random rotation between 0 to 180 degrees.
% - Random translation along the x- and y-axes of -10 to 10 pixels.
% - Random reflection to flip the image in the x-axis.
function out = augmentDataForLVSegmentation(data)
% Copyright 2023 The MathWorks, Inc.

    img = data{1};
    labels = data{2};
    inputSize = size(img,[1 2]);

    tform = randomAffine2d(...
        Rotation=[-5 5],...
        XTranslation=[-10 10],...
        YTranslation=[-10 10]);

    sameAsInput = affineOutputView(inputSize,tform,BoundsStyle="sameAsInput");
    img = imwarp(img,tform,"linear",OutputView=sameAsInput);
    labels = imwarp(labels,tform,"nearest",OutputView=sameAsInput);

    out = {img,labels};

end

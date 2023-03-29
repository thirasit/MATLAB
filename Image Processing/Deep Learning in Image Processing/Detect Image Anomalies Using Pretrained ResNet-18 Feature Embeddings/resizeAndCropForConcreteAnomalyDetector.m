function imageOut = resizeAndCropForConcreteAnomalyDetector(imageIn,resizeSize,targetSize)
% resizeAndCropForConcreteAnomalyDetector Resize and center crop the image.

% Copyright 2021 The MathWorks, Inc.

% Initialize outputs
if size(imageIn,3) == 1
    imageOut = zeros([targetSize 3 size(imageIn,4)],'like',imageIn);
else
    imageOut = zeros([targetSize size(imageIn,[3 4])],'like',imageIn);
end

for idx = 1:size(imageIn,4)
    % Resize
    imageTemp = imresize(uint8(imageIn(:,:,:,idx)),resizeSize,'bilinear');

    % Center-crop
    win = centerCropWindow2d(size(imageTemp),targetSize);
    [r,c] = deal(win.YLimits(1):win.YLimits(2),win.XLimits(1):win.XLimits(2));
    imageOut(:,:,:,idx) =  imageTemp(r,c,:);
end

end
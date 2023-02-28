function [boundingBox, orientation, Idilated] = segmentationLocalization(Ihoughlines)

%------------------------------------------------------------------------
% Use image dilation to separate the barcodes
%------------------------------------------------------------------------

% Create binary image with the detected lines.
Ibw = ~Ihoughlines(:,:,1);
Ibw(Ibw > 0) = true;

% Dilate the image using a disk structuring element.
diskRadius = 10; % Might need tuning depending on the input image.
se = strel('disk', diskRadius);
Idilated = imdilate(Ibw, se);

%------------------------------------------------------------------------
% Localization parameters for the barcode
%------------------------------------------------------------------------

% Compute region properties Orientation and BoundingBox.
regionStatistics = regionprops(Idilated, 'Orientation', 'BoundingBox');

% Padding for the cropped images of barcodes.
padding = 40;

boundingBox = zeros(length(regionStatistics), 4);

for idx = 1:length(regionStatistics)
    
    boundingBox(idx,:) = regionStatistics(idx).BoundingBox;
    
    % Bounding box coordinates with padding.
    boundingBox(idx,1) = boundingBox(idx,1) - padding;
    boundingBox(idx,2) = boundingBox(idx,2) - padding;
    boundingBox(idx,3) = boundingBox(idx,3) + 2*padding;
    boundingBox(idx,4) = boundingBox(idx,4) + 2*padding;
    
end

orientation = [regionStatistics(:).Orientation];

end
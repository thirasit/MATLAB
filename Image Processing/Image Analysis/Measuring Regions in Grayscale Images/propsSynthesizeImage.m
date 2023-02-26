function I = propsSynthesizeImage
%propsSynthesizeImage create image for MeasureGrayscaleRegionsExample example

% Copyright 2007-2015 The MathWorks, Inc.

% Create image
I = abs(peaks(200));
I = conv2(I,ones(3),'same');
I = I/max(I(:));
I = im2uint8(I);

% Break up one of the regions by "drawing" a line between them.
BW = roipoly(I,[120 154 117 120],[117 152 119 117]);
I(BW) = min(I(:));

% Make the grayscale values of the regions more variable.
BW = imbinarize(I);
K = repmat(uint8(linspace(215,255,20)),[100 5]);
J = repmat(uint8(linspace(150, 20,20)),[100 5]);
I = [J K;K J];
I(~BW) = 0;

%% Low-Light Image Enhancement
% This example shows how to brighten dark regions of an image while preventing oversaturation of bright regions.

% Images can be highly degraded due to poor lighting conditions.
% These images can have low dynamic ranges with high noise levels that affect the overall performance of computer vision algorithms.
% To make computer vision algorithms robust in low-light conditions, use low-light image enhancement to improve the visibility of an image.

% Read and display an RGB image captured in low light.
A = imread("lowlight_1.jpg");
imshow(A)
title("Original Image")

%%% Localized Brightening
% Brighten the low-light image in proportion to the darkness of the local region, then display the brightened image.
% Dark regions brighten significantly.
% Bright regions also have a small increase in brightness, causing oversaturation.
% The image looks somewhat unnatural and is perhaps brightened too much.
B = imlocalbrighten(A);
imshow(B)

% Display a histogram of the pixel values for the original image and the brightened image.
% For the original image, the histogram is skewed towards darker pixel values.
% For the brightened image, the pixel values are more evenly distributed throughout the full range of pixel values.
figure
subplot(1,2,1)
imhist(A)
title("Original Image")
subplot(1,2,2)
imhist(B)
title("Brightened Image")

% Brighten the original low-light image again and specify a smaller brightening amount.
amt = 0.5;
B2 = imlocalbrighten(A,amt);

% Display the brightened image.
% The image looks more natural.
% The dark regions of the image are enhanced, but the bright regions by the windows are still oversaturated.
figure
imshow(B2)
title("Image with Less Brightening")

% To reduce oversaturation of bright regions, apply alpha blending when brightening the image.
% The dark regions are brighter, and the bright pixels retain their original pixel values.
B3 = imlocalbrighten(A,amt,AlphaBlend=true);
imshow(B3)
title("Image with Alpha Blending")

% For comparison, display the three enhanced images in a montage.
figure
montage({B,B2,B3},Size=[1 3],BorderSize=5,BackgroundColor="w")

%%% References
% [1] Dong, X., G. Wang, Y. Pang, W. Li, J. Wen, W. Meng, and Y. Lu. "Fast efficient algorithm for enhancement of low lighting video." Proceedings of IEEE® International Conference on Multimedia and Expo (ICME). 2011, pp. 1–6.

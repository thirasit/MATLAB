%% Register Two Images Using Spatial Referencing to Enhance Display
% This example shows how to use spatial referencing objects to understand the spatial relationship between two images in image registration and display them effectively. 
% This example brings one of the images, called the moving image, into alignment with the other image, called the fixed image.

% Read the two images of the same scene that are slightly misaligned.
fixed = imread("westconcordorthophoto.png");
moving = imread("westconcordaerial.png");

% Display the moving (unregistered) image.
iptsetpref(ImshowAxesVisible="on")
figure
imshow(moving)
text(size(moving,2),size(moving,1)+35,"Image courtesy of mPower3/Emerge", ...
    FontSize=7,HorizontalAlignment="right")

% Load a MAT file that contains preselected control points for the fixed and moving images.
load westconcordpoints

% Fit a projective geometric transformation to the control point pairs using the fitgeotform2d function.
tform = fitgeotform2d(movingPoints,fixedPoints,"projective");

% Perform the transformation necessary to register the moving image with the fixed image, using the imwarp function. 
% This example uses the optional "FillValues" name-value argument to specify a fill value (white), which will help when displaying the fixed image over the transformed moving image, to check registration. 
% Notice that the full content of the geometrically transformed moving image is present, now called registered. 
% Also note that there are no blank rows or columns.
registered = imwarp(moving,tform,FillValues=255);
figure
imshow(registered)

% Overlay the transformed image, registered, over the fixed image using the imshowpair function. 
% Notice how the two images appear misregistered. 
% This happens because imshowpair assumes that the images are both in the default intrinsic coordinate system. 
% The next steps provide two ways to remedy this display problem.
figure
imshowpair(fixed,registered,"blend");

% Constrain the transformed image, registered, to the same number of rows and columns, and the same spatial limits, as the fixed image. 
% This ensures that the registered image appears registered with the fixed image but areas of the registered image that would extrapolate beyond the extent of the fixed image are discarded. 
% To do this, create a default spatial referencing object that specifies the size and location of the fixed image, and use the "OutputView" name-value argument of imwarp to create a constrained resampled image registered1. 
% Display the registered image over the fixed image. 
% In this view, the images appear to have been registered, but not all of the unregistered image is visible.
Rfixed = imref2d(size(fixed));
registered1 = imwarp(moving,tform,FillValues=255,OutputView=Rfixed);
figure
imshowpair(fixed,registered1,"blend");

% As an alternative, use the optional imwarp syntax that returns the output spatial referencing object that indicates the position of the full transformed image in the same default intrinsic coordinate system as the fixed image. 
% Display the registered image over the fixed image and note that now the full registered image is visible.
[registered2,Rregistered] = imwarp(moving,tform,FillValues=255);
figure
imshowpair(fixed,Rfixed,registered2,Rregistered,"blend")

% Clean up.
iptsetpref("ImshowAxesVisible","off")

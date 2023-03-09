%% Use Phase Correlation as Preprocessing Step in Registration
% This example shows how to use phase correlation as a preliminary step for automatic image registration. 
% In this process, you perform phase correlation using imregcorr, and then pass the result of that registration as the initial condition of an optimization-based registration using imregister. 
% Phase correlation and optimization-based registration are complementary algorithms. 
% Phase correlation is good for finding gross alignment, even for severely misaligned images. 
% Optimization-based registration is good for finding precise alignment, given a good initial condition.

% Read an image that will be the reference image in the registration.
fixed = imread("cameraman.tif");
figure
imshow(fixed)

% Create an unregistered image by deliberately distorting this image using rotation, isotropic scaling, and shearing in the y direction.
theta = 170;
rot = [
    cosd(theta) -sind(theta) 0; ... 
    sind(theta)  cosd(theta) 0; ... 
    0 0 1]; 
sc = 2.3;
scale = [sc 0 0; 0 sc 0; 0 0 1]; 
sh = 0.1;
shear = [1 sh 0; 0 1 0; 0 0 1]; 

tform = affinetform2d(shear*scale*rot);
moving = imwarp(fixed,tform); 

% Add noise to the image, and display the result.
moving = imnoise(moving,"gaussian");
figure
imshow(moving)

% Estimate the registration required to bring these two images into alignment. 
% imregcorr returns a simtform2d object that defines the transformation.
tformEstimate = imregcorr(moving,fixed)

% Apply the estimated geometric transform to the misaligned image. 
% Specify the OutputView name-value argument to ensure the registered image is the same size as the reference image.
Rfixed = imref2d(size(fixed));
movingReg = imwarp(moving,tformEstimate,OutputView=Rfixed);

% Display the original image and the registered image in a montage. 
% You can see that imregcorr has done a good job handling the rotation and scaling differences between the images. 
% The registered image, movingReg, is very close to being aligned with the original image, fixed. 
% However, some misalignment remains. 
% imregcorr can handle rotation and scale distortions well, but not shear distortion.
figure
imshowpair(fixed,movingReg,"montage");

% View the aligned image overlaid on the original image, using imshowpair. In this view, imshowpair uses color to highlight areas of misalignment.
figure
imshowpair(fixed,movingReg,"falsecolor");

% To finish the registration, use imregister, passing the estimated transformation returned by imregcorr as the initial condition. 
% imregister is more effective if the two images are roughly in alignment at the start of the operation. 
% The transformation estimated by imregcorr provides this information for imregister. 
% The example uses the default optimizer and metric values for a registration of two images taken with the same sensor, which is a monomodal configuration.
[optimizer,metric] = imregconfig("monomodal");
movingRegistered = imregister(moving,fixed,"affine", ...
    optimizer,metric,InitialTransformation=tformEstimate);

% Display the result of this registration. 
% Note that imregister achieves a very accurate registration, given the good initial condition provided by imregcorr.
figure
imshowpair(fixed,movingRegistered,Scaling="joint");

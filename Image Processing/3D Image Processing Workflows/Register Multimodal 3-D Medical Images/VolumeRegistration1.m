%% Register Multimodal 3-D Medical Images
% This example shows how you can automatically align two volumetric images using intensity-based registration.

% In registration problems, consider one image to be the fixed image and the other image to be the moving image. 
% The goal of registration is to align the moving image with the fixed image. 
% This example uses two approaches to automatically align volumetric images:
% - Register the images directly using imregister.
% - Estimate the geometric transformation required to map the moving image to the fixed image, then apply the transformation using imwarp.
% Unlike some other techniques, imregister and imregtform do not find features or use control points. 
% Intensity-based registration is often well-suited for medical and remotely sensed imagery.

%%% Load Images
% This example uses a CT image and a T1 weighted MR image collected from the same patient at different time. 
% The 3-D CT and MRI data sets were provided by Dr. Michael Fitzpatrick as part of The Retrospective Image Registration Evaluation (RIRE) Dataset.

% This example specifies the MRI image as the fixed image and the CT image as the moving image. 
% The data is stored in the file format used by the Retrospective Image Registration Evaluation (RIRE) Project. 
% Use multibandread to read the binary files that contain image data. 
% Use the helperReadHeaderRIRE function to obtain the metadata associated with each image.
fixedHeader  = helperReadHeaderRIRE("rirePatient007MRT1.header");
movingHeader = helperReadHeaderRIRE("rirePatient007CT.header");

fixedVolume  = multibandread("rirePatient007MRT1.bin", ...
                            [fixedHeader.Rows,fixedHeader.Columns,fixedHeader.Slices], ...
                            "int16=>single",0,"bsq","ieee-be" );
                        
movingVolume = multibandread("rirePatient007CT.bin",...
                            [movingHeader.Rows,movingHeader.Columns,movingHeader.Slices], ...
                            "int16=>single",0,"bsq","ieee-be" );

% The helperVolumeRegistration function is a helper function that is provided to help judge the quality of 3-D registration results. 
% You can interactively rotate the view and both axes will remain in sync.
helperVolumeRegistration(fixedVolume,movingVolume);

% You can also use imshowpair to look at single planes from the fixed and moving volumes to get a sense of the overall alignment of the volumes. 
% In the overlapping image from imshowpair, gray areas correspond to areas that have similar intensities, while magenta and green areas show places where one image is brighter than the other. 
% Use imshowpair to observe the misregistration of the image volumes along an axial slice taken through the center of each volume. 
% It is clear that the images have different spatial referencing information, such as different world limits and pixel extents.
centerFixed = size(fixedVolume,3)/2;
centerMoving = size(movingVolume,3)/2;
figure
imshowpair(movingVolume(:,:,centerMoving),fixedVolume(:,:,centerFixed))
title("Unregistered Axial Slice")

% You can improve the display and registration results by incorporating spatial referencing information. 
% For this data, the resolution of the CT and MRI data sets is defined in the image metadata. 
% Use this metadata to create imref3d spatial referencing objects.
Rfixed  = imref3d(size(fixedVolume),fixedHeader.PixelSize(2), ...
    fixedHeader.PixelSize(1),fixedHeader.SliceThickness)

Rmoving = imref3d(size(movingVolume),movingHeader.PixelSize(2), ...
    movingHeader.PixelSize(1),movingHeader.SliceThickness)

% The properties of the spatial referencing objects define where the associated image volumes are in the world coordinate system and what the pixel extent in each dimension is. 
% The XWorldLimits property of Rmoving defines the position of the moving volume in the X dimension. 
% The PixelExtentInWorld property defines the size of each pixel in world units in the X dimension (along columns). 
% The moving volume extends from 0.3269 to 334.97 mm in the world X coordinate system and each pixel has an extent of 0.6536 mm. 
% Units are in millimeters because the header information used to construct the spatial referencing was in millimeters. 
% The ImageExtentInWorldX property determines the full extent of the moving image volume in world units.

%%% Approach 1: Register Images Using imregister
% The imregister function enables you to obtain a registered output image volume that you can view and observe directly to access the quality of registration results.

% Pick the correct optimizer and metric configuration to use with imregister by using the imregconfig function. 
% These two images are from two different modalities, MRI and CT, so the "multimodal" option is appropriate. 
% Change the value of the InitialRadius property of the optimizer to achieve better convergence in registration results.
[optimizer,metric] = imregconfig("multimodal");
optimizer.InitialRadius = 0.004;

% The misalignment between the two volumes includes translation and rotation so use a rigid transformation to register the images. 
% Specify the spatial referencing information so that the algorithm used by imregister will converge to better results more quickly.
movingRegisteredVolume = imregister(movingVolume,Rmoving, ...
    fixedVolume,Rfixed,"rigid",optimizer,metric);

% Display an axial slice taken through the center of the registered volumes to get a sense of how successful the registration is. 
% In addition to aligning the images, the registration process adjusts the spatial referencing information of the moving image so that it is consistent with the fixed image. 
% The images are now the same size and are successfully aligned.
figure
imshowpair(movingRegisteredVolume(:,:,centerFixed), ...
    fixedVolume(:,:,centerFixed));
title("Axial Slice of Registered Volume")

% Use helperVolumeRegistration again to view the registered volume to continue judging the success of registration.
helperVolumeRegistration(fixedVolume,movingRegisteredVolume);

%%% Approach 2: Estimate and Apply 3-D Geometric Transformation
% The imregister function registers images but does not return information about the geometric transformation applied to the moving image. 
% When you are interested in the estimated geometric transformation, you can use the imregtform function to get a geometric transformation object that stores information about the transformation. 
% imregtform uses the same algorithm as imregister and takes the same input arguments as imregister.
tform = imregtform(movingVolume,Rmoving,fixedVolume,Rfixed, ...
    "rigid",optimizer,metric)

% The property A defines the 3-D affine transformation matrix used to align the moving image to the fixed image.
tform.T

% The transformPointsForward function can be used to determine where a point [u,v,w] in the moving image maps as a result of the registration. 
% Because spatially referenced inputs were specified to imregtform, the geometric transformation maps points in the world coordinate system from moving to fixed. 
% The transformPointsForward function is used below to determine the transformed location of the center of the moving image in the world coordinate system.
centerXWorld = mean(Rmoving.XWorldLimits);
centerYWorld = mean(Rmoving.YWorldLimits);
centerZWorld = mean(Rmoving.ZWorldLimits);
[xWorld,yWorld,zWorld] = transformPointsForward(tform, ...
    centerXWorld,centerYWorld,centerZWorld);

% You can use the worldToSubscript function to determine the element of the fixed volume that aligns with the center of the moving volume.
[r,c,p] = worldToSubscript(Rfixed,xWorld,yWorld,zWorld)

% Apply the geometric transformation estimate from imregtform to a 3-D volume using the imwarp function. 
% The "OutputView" name-value argument is used to define a spatial referencing argument that determines the world limits and resolution of the output resampled image. 
% You can produce the same results given by imregister by using the spatial referencing object associated with the fixed image. 
% This creates an output volume in which the world limits and resolution of the fixed and moving image are the same. 
% Once the world limits and resolution of both volumes are the same, there is pixel to pixel correspondence between each sample of the moving and fixed volumes.
movingRegisteredVolume = imwarp(movingVolume,Rmoving,tform, ...
    "bicubic",OutputView=Rfixed);

% View an axial slice through the center of the registered volume produced by imwarp.
figure 
imshowpair(movingRegisteredVolume(:,:,centerFixed), ...
    fixedVolume(:,:,centerFixed));
title("Axial Slice of Registered Volume")

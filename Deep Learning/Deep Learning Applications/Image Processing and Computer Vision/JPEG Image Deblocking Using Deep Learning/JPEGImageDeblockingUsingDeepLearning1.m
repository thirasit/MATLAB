%% JPEG Image Deblocking Using Deep Learning
% This example shows how to reduce JPEG compression artifacts in an image using a denoising convolutional neural network (DnCNN).

% Image compression is used to reduce the memory footprint of an image.
% One popular and powerful compression method is employed by the JPEG image format, which uses a quality factor to specify the amount of compression.
% Reducing the quality value results in higher compression and a smaller memory footprint, at the expense of visual quality of the image.

% JPEG compression is lossy, meaning that the compression process causes the image to lose information.
% For JPEG images, this information loss appears as blocking artifacts in the image.
% As shown in the figure, more compression results in more information loss and stronger artifacts.
% Textured regions with high-frequency content, such as the grass and clouds, look blurry.
% Sharp edges, such as the roof of the house and the guardrails atop the lighthouse, exhibit ringing.
figure
imshow("JPEGImageDeblockingUsingDeepLearningExample_01.png")
axis off;

% JPEG deblocking is the process of reducing the effects of compression artifacts in JPEG images.
% Several JPEG deblocking methods exist, including more effective methods that use deep learning.
% This example implements one such deep learning-based method that attempts to minimize the effect of JPEG compression artifacts.

%%% The DnCNN Network
% This example uses a built-in deep feed-forward convolutional neural network, called DnCNN.
% The network was primarily designed to remove noise from images.
% However, the DnCNN architecture can also be trained to remove JPEG compression artifacts or increase image resolution.
% The reference paper [1] employs a residual learning strategy, meaning that the DnCNN network learns to estimate the residual image.
% A residual image is the difference between a pristine image and a distorted copy of the image.
% The residual image contains information about the image distortion.
% For this example, distortion appears as JPEG blocking artifacts.
% The DnCNN network is trained to detect the residual image from the luminance of a color image.
% The luminance channel of an image, Y, represents the brightness of each pixel through a linear combination of the red, green, and blue pixel values.
% In contrast, the two chrominance channels of an image, Cb and Cr, are different linear combinations of the red, green, and blue pixel values that represent color-difference information.
% DnCNN is trained using only the luminance channel because human perception is more sensitive to changes in brightness than changes in color.
figure
imshow("JPEGImageDeblockingUsingDeepLearningExample_02.png")
axis off;

% If Y_Original is the luminance of the pristine image and Y_Compressed is the luminance of the image containing JPEG compression artifacts, then the input to the DnCNN network is Y_Compressed and the network learns to predict Y_Residual=Y_Compressed−Y_Original from the training data.
% Once the DnCNN network learns how to estimate a residual image, it can reconstruct an undistorted version of a compressed JPEG image by adding the residual image to the compressed luminance channel, then converting the image back to the RGB color space.

%%% Download Training Data
% Download the IAPR TC-12 Benchmark, which consists of 20,000 still natural images [2].
% The data set includes photos of people, animals, cities, and more.
% The size of the data file is ~1.8 GB. If you do not want to download the training data or train the network, then you can load the pretrained DnCNN network by typing load("trainedJPEGDnCNN.mat") at the command line.
% Then, go directly to the Perform JPEG Deblocking Using DnCNN Network section in this example.
% Use the helper function, downloadIAPRTC12Data, to download the data.
% This function is attached to the example as a supporting file.
% Specify dataDir as the desired location of the data.
dataDir = tempdir;
downloadIAPRTC12Data(dataDir);

% This example will train the network with a small subset of the IAPR TC-12 Benchmark data.
% Load the imageCLEF training data. All images are 32-bit JPEG color images.
trainImagesDir = fullfile(dataDir,"iaprtc12","images","00");
exts = [".jpg",".bmp",".png"];
imdsPristine = imageDatastore(trainImagesDir,FileExtensions=exts);

% List the number of training images.
numel(imdsPristine.Files)

%%% Prepare Training Data
% To create a training data set, read in pristine images and write out images in the JPEG file format with various levels of compression.
% Specify the JPEG image quality values used to render image compression artifacts.
% Quality values must be in the range [0, 100].
% Small quality values result in more compression and stronger compression artifacts.
% Use a denser sampling of small quality values so the training data has a broad range of compression artifacts.
JPEGQuality = [5:5:40 50 60 70 80];

% The compressed images are stored on disk as MAT files in the directory compressedImagesDir.
% The computed residual images are stored on disk as MAT files in the directory residualImagesDir.
% The MAT files are stored as data type double for greater precision when training the network.
compressedImagesDir = fullfile(dataDir,"iaprtc12","JPEGDeblockingData","compressedImages");
residualImagesDir = fullfile(dataDir,"iaprtc12","JPEGDeblockingData","residualImages");

% Use the helper function createJPEGDeblockingTrainingSet to preprocess the training data.
% This function is attached to the example as a supporting file.

% For each pristine training image, the helper function writes a copy of the image with quality factor 100 to use as a reference image and copies of the image with each quality factor to use as the network inputs.
% The function computes the luminance (Y) channel of the reference and compressed images in data type double for greater precision when calculating the residual images.
% The compressed images are stored on disk as .MAT files in the directory compressedDirName.
% The computed residual images are stored on disk as .MAT files in the directory residualDirName.
[compressedDirName,residualDirName] = createJPEGDeblockingTrainingSet(imdsPristine,JPEGQuality);

%%% Create Random Patch Extraction Datastore for Training
% Use a random patch extraction datastore to feed the training data to the network.
% This datastore extracts random corresponding patches from two image datastores that contain the network inputs and desired network responses.
% In this example, the network inputs are the compressed images.
% The desired network responses are the residual images.
% Create an image datastore called imdsCompressed from the collection of compressed image files.
% Create an image datastore called imdsResidual from the collection of computed residual image files.
% Both datastores require a helper function, matRead, to read the image data from the image files.
% This function is attached to the example as a supporting file.
imdsCompressed = imageDatastore(compressedDirName,FileExtensions=".mat",ReadFcn=@matRead);
imdsResidual = imageDatastore(residualDirName,FileExtensions=".mat",ReadFcn=@matRead);

% Create an imageDataAugmenter that specifies the parameters of data augmentation.
% Use data augmentation during training to vary the training data, which effectively increases the amount of available training data.
% Here, the augmenter specifies random rotation by 90 degrees and random reflections in the x-direction.
augmenter = imageDataAugmenter( ...
    RandRotation=@()randi([0,1],1)*90, ...
    RandXReflection=true);

% Create the randomPatchExtractionDatastore (Image Processing Toolbox) from the two image datastores.
% Specify a patch size of 50-by-50 pixels.
% Each image generates 128 random patches of size 50-by-50 pixels.
% Specify a mini-batch size of 128.
patchSize = 50;
patchesPerImage = 128;
dsTrain = randomPatchExtractionDatastore(imdsCompressed,imdsResidual,patchSize, ...
    PatchesPerImage=patchesPerImage, ...
    DataAugmentation=augmenter);
dsTrain.MiniBatchSize = patchesPerImage;

% The random patch extraction datastore dsTrain provides mini-batches of data to the network at iteration of the epoch.
% Preview the result of reading from the datastore.
inputBatch = preview(dsTrain);
disp(inputBatch)

%%% Set up DnCNN Layers
% Create the layers of the built-in DnCNN network by using the dnCNNLayers (Image Processing Toolbox) function.
% By default, the network depth (the number of convolution layers) is 20.
layers = dnCNNLayers

%%% Select Training Options
% Train the network using stochastic gradient descent with momentum (SGDM) optimization.
% Specify the hyperparameter settings for SGDM by using the trainingOptions function.
% Training a deep network is time-consuming.
% Accelerate the training by specifying a high learning rate.
% However, this can cause the gradients of the network to explode or grow uncontrollably, preventing the network from training successfully.
% To keep the gradients in a meaningful range, enable gradient clipping by setting "GradientThreshold" to 0.005, and specify "GradientThresholdMethod" to use the absolute value of the gradients.
maxEpochs = 30;
initLearningRate = 0.1;
l2reg = 0.0001;
batchSize = 64;

options = trainingOptions("sgdm", ...
    Momentum=0.9, ...
    InitialLearnRate=initLearningRate, ...
    LearnRateSchedule="piecewise", ...
    GradientThresholdMethod="absolute-value", ...
    GradientThreshold=0.005, ...
    L2Regularization=l2reg, ...
    MiniBatchSize=batchSize, ...
    MaxEpochs=maxEpochs, ...
    Plots="training-progress", ...
    Verbose=false);

%%% Train the Network
% By default, the example loads a pretrained DnCNN network.
% The pretrained network enables you to perform JPEG deblocking without waiting for training to complete.

% To train the network, set the doTraining variable in the following code to true.
% Train the DnCNN network using the trainNetwork function.

% Train on a GPU if one is available.
% Using a GPU requires Parallel Computing Toolbox™ and a CUDA® enabled NVIDIA® GPU.
% For more information, see GPU Computing Requirements (Parallel Computing Toolbox).
% Training takes about 40 hours on an NVIDIA™ Titan X.
doTraining = false; 
if doTraining  
    [net,info] = trainNetwork(dsTrain,layers,options);
    modelDateTime = string(datetime("now",Format="yyyy-MM-dd-HH-mm-ss"));
    save("trainedJPEGDnCNN-"+modelDateTime+".mat","net");
else 
    load("trainedJPEGDnCNN.mat"); 
end

% You can now use the DnCNN network to remove JPEG compression artifacts from images.

%%% Perform JPEG Deblocking Using DnCNN Network
% To perform JPEG deblocking using DnCNN, follow the remaining steps of this example:
% - Create sample test images with JPEG compression artifacts at three different quality levels.
% - Remove the compression artifacts using the DnCNN network.
% - Visually compare the images before and after deblocking.
% - Evaluate the quality of the compressed and deblocked images by quantifying their similarity to the undistorted reference image.

%%% Create Sample Images with Blocking Artifacts
% The test data set, testImages, contains 20 undistorted images shipped in Image Processing Toolbox™.
% Load the images into an imageDatastore.
fileNames = ["sherlock.jpg","peacock.jpg","fabric.png","greens.jpg", ...
    "hands1.jpg","kobi.png","lighthouse.png","office_4.jpg", ...
    "onion.png","pears.png","yellowlily.jpg","indiancorn.jpg", ...
    "flamingos.jpg","sevilla.jpg","llama.jpg","parkavenue.jpg", ...
    "strawberries.jpg","trailer.jpg","wagon.jpg","football.jpg"];
filePath = fullfile(matlabroot,"toolbox","images","imdata")+filesep;
filePathNames = strcat(filePath,fileNames);
testImages = imageDatastore(filePathNames);

% Display the test images as a montage.
figure
montage(testImages)

% Select one of the test images to use for testing the JPEG deblocking network.
figure
testImage = "lighthouse.png";
Ireference = imread(testImage);
imshow(Ireference)
title("Uncompressed Reference Image")

% Create three compressed test images with the JPEG Quality values of 10, 20, and 50.
imwrite(Ireference,fullfile(tempdir,"testQuality10.jpg"),"Quality",10);
imwrite(Ireference,fullfile(tempdir,"testQuality20.jpg"),"Quality",20);
imwrite(Ireference,fullfile(tempdir,"testQuality50.jpg"),"Quality",50);

%%% Preprocess Compressed Images
% Read the compressed versions of the image into the workspace.
I10 = imread(fullfile(tempdir,"testQuality10.jpg"));
I20 = imread(fullfile(tempdir,"testQuality20.jpg"));
I50 = imread(fullfile(tempdir,"testQuality50.jpg"));

% Display the compressed images as a montage.
figure
montage({I50,I20,I10},Size=[1 3])
title("JPEG-Compressed Images with Quality Factor: 50, 20 and 10 (left to right)")

% Recall that DnCNN is trained using only the luminance channel of an image because human perception is more sensitive to changes in brightness than changes in color.
% Convert the JPEG-compressed images from the RGB color space to the YCbCr color space using the rgb2ycbcr (Image Processing Toolbox) function.
I10ycbcr = rgb2ycbcr(I10);
I20ycbcr = rgb2ycbcr(I20);
I50ycbcr = rgb2ycbcr(I50);

%%% Apply the DnCNN Network
% In order to perform the forward pass of the network, use the denoiseImage (Image Processing Toolbox) function.
% This function uses exactly the same training and testing procedures for denoising an image.
% You can think of the JPEG compression artifacts as a type of image noise.
I10y_predicted = denoiseImage(I10ycbcr(:,:,1),net);
I20y_predicted = denoiseImage(I20ycbcr(:,:,1),net);
I50y_predicted = denoiseImage(I50ycbcr(:,:,1),net);

% The chrominance channels do not need processing.
% Concatenate the deblocked luminance channel with the original chrominance channels to obtain the deblocked image in the YCbCr color space.
I10ycbcr_predicted = cat(3,I10y_predicted,I10ycbcr(:,:,2:3));
I20ycbcr_predicted = cat(3,I20y_predicted,I20ycbcr(:,:,2:3));
I50ycbcr_predicted = cat(3,I50y_predicted,I50ycbcr(:,:,2:3));

% Convert the deblocked YCbCr image to the RGB color space by using the ycbcr2rgb (Image Processing Toolbox) function.
I10_predicted = ycbcr2rgb(I10ycbcr_predicted);
I20_predicted = ycbcr2rgb(I20ycbcr_predicted);
I50_predicted = ycbcr2rgb(I50ycbcr_predicted);

% Display the deblocked images as a montage.
figure
montage({I50_predicted,I20_predicted,I10_predicted},Size=[1 3])
title("Deblocked Images with Quality Factor 50, 20 and 10 (Left to Right)")

% To get a better visual understanding of the improvements, examine a smaller region inside each image.
% Specify a region of interest (ROI) using vector roi in the format [x y width height].
% The elements define the x- and y-coordinate of the top left corner, and the width and height of the ROI.
roi = [30 440 100 80];

% Crop the compressed images to this ROI, and display the result as a montage.
figure
i10 = imcrop(I10,roi);
i20 = imcrop(I20,roi);
i50 = imcrop(I50,roi);
montage({i50 i20 i10},Size=[1 3])
title("Patches from JPEG-Compressed Images with Quality Factor 50, 20 and 10 (Left to Right)")

% Crop the deblocked images to this ROI, and display the result as a montage.
figure
i10predicted = imcrop(I10_predicted,roi);
i20predicted = imcrop(I20_predicted,roi);
i50predicted = imcrop(I50_predicted,roi);
montage({i50predicted,i20predicted,i10predicted},Size=[1 3])
title("Patches from Deblocked Images with Quality Factor 50, 20 and 10 (Left to Right)")

%%% Quantitative Comparison
% Quantify the quality of the deblocked images through four metrics. You can use the jpegDeblockingMetrics helper function to compute these metrics for compressed and deblocked images at the quality factors 10, 20, and 50. This function is attached to the example as a supporting file.
% - Structural Similarity Index (SSIM). SSIM assesses the visual impact of three characteristics of an image: luminance, contrast and structure, against a reference image. The closer the SSIM value is to 1, the better the test image agrees with the reference image. Here, the reference image is the undistorted original image, Ireference, before JPEG compression. See ssim (Image Processing Toolbox) for more information about this metric.
% - Peak signal-to-noise ratio (PSNR). The larger the PSNR value, the stronger the signal compared to the distortion. See psnr (Image Processing Toolbox) for more information about this metric.
% - Naturalness Image Quality Evaluator (NIQE). NIQE measures perceptual image quality using a model trained from natural scenes. Smaller NIQE scores indicate better perceptual quality. See niqe (Image Processing Toolbox) for more information about this metric.
% - Blind/Referenceless Image Spatial Quality Evaluator (BRISQUE). BRISQUE measures perceptual image quality using a model trained from natural scenes with image distortion. Smaller BRISQUE scores indicate better perceptual quality. See brisque (Image Processing Toolbox) for more information about this metric.
jpegDeblockingMetrics(Ireference,I10,I20,I50,I10_predicted,I20_predicted,I50_predicted)

%%% References
% [1] Zhang, K., W. Zuo, Y. Chen, D. Meng, and L. Zhang, "Beyond a Gaussian Denoiser: Residual Learning of Deep CNN for Image Denoising." IEEE® Transactions on Image Processing. Feb 2017.
% [2] Grubinger, M., P. Clough, H. Müller, and T. Deselaers. "The IAPR TC-12 Benchmark: A New Evaluation Resource for Visual Information Systems." Proceedings of the OntoImage 2006 Language Resources For Content-Based Image Retrieval. Genoa, Italy. Vol. 5, May 2006, p. 10.

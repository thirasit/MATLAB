%% Semantic Segmentation of Multispectral Images Using Deep Learning
% This example shows how to perform semantic segmentation of a multispectral image with seven channels using U-Net.

% Semantic segmentation involves labeling each pixel in an image with a class.
% One application of semantic segmentation is tracking deforestation, which is the change in forest cover over time.
% Environmental agencies track deforestation to assess and quantify the environmental and ecological health of a region.

% Deep learning based semantic segmentation can yield a precise measurement of vegetation cover from high-resolution aerial photographs.
% One challenge is differentiating classes with similar visual characteristics, such as trying to classify a green pixel as grass, shrubbery, or tree.
% To increase classification accuracy, some data sets contain multispectral images that provide additional information about each pixel.
% For example, the Hamlin Beach State Park data set supplements the color images with three near-infrared channels that provide a clearer separation of the classes.

figure
imshow("SemanticSegmentationOfMultispectralImagesExample_01.png")

% This example first shows you how to perform semantic segmentation using a pretrained U-Net and then use the segmentation results to calculate the extent of vegetation cover.
% Then, you can optionally train a U-Net network on the Hamlin Beach State Parck data set using a patch-based training methodology.

%%% Download Dataset
% This example uses a high-resolution multispectral data set to train the network [1].
% The image set was captured using a drone over the Hamlin Beach State Park, NY.
% The data contains labeled training, validation, and test sets, with 18 object class labels.
% The size of the data file is 3.0 GB.

% Download the MAT-file version of the data set using the downloadHamlinBeachMSIData helper function.
% This function is attached to the example as a supporting file.
% Specify dataDir as the desired location of the data.
dataDir = fullfile(tempdir,"rit18_data"); 
downloadHamlinBeachMSIData(dataDir);

% Load the dataset.
load(fullfile(dataDir,"rit18_data.mat"));
whos train_data val_data test_data

% The multispectral image data is arranged as numChannels-by-width-by-height arrays.
% However, in MATLAB®, multichannel images are arranged as width-by-height-by-numChannels arrays.
% To reshape the data so that the channels are in the third dimension, use the switchChannelsToThirdPlane helper function.
% This function is attached to the example as a supporting file.
train_data = switchChannelsToThirdPlane(train_data);
val_data   = switchChannelsToThirdPlane(val_data);
test_data  = switchChannelsToThirdPlane(test_data);

% Confirm that the data has the correct structure.
whos train_data val_data test_data

% Save the training data as a MAT file and the training labels as a PNG file.
% This facilitates loading the training data using an imageDatastore and a pixelLabelDatastore during training.
save("train_data.mat","train_data");
imwrite(train_labels,"train_labels.png");

%%% Visualize Multispectral Data
% In this dataset, the RGB color channels are the 3rd, 2nd, and 1st image channels.
% Display the color component of the training, validation, and test images as a montage.
% To make the images appear brighter on the screen, equalize their histograms by using the histeq function.
figure
montage(...
    {histeq(train_data(:,:,[3 2 1])), ...
    histeq(val_data(:,:,[3 2 1])), ...
    histeq(test_data(:,:,[3 2 1]))}, ...
    BorderSize=10,BackgroundColor="white")
title("RGB Component of Training, Validation, and Test Image (Left to Right)")

% Display the last three histogram-equalized channels of the training data as a montage.
% These channels correspond to the near-infrared bands and highlight different components of the image based on their heat signatures.
% For example, the trees near the center of the second channel image show more detail than the trees in the other two channels.
figure
montage(...
    {histeq(train_data(:,:,4)),histeq(train_data(:,:,5)),histeq(train_data(:,:,6))}, ...
    BorderSize=10,BackgroundColor="white")
title("Training Image IR Channels 1, 2, and 3 (Left to Right)")

% Channel 7 is a mask that indicates the valid segmentation region.
% Display the mask for the training, validation, and test images.
figure
montage(...
    {train_data(:,:,7),val_data(:,:,7),test_data(:,:,7)}, ...
    BorderSize=10,BackgroundColor="white")
title("Mask of Training, Validation, and Test Image (Left to Right)")

%%% Visualize Ground Truth Labels
% The labeled images contain the ground truth data for the segmentation, with each pixel assigned to one of the 18 classes.
% Get a list of the classes with their corresponding IDs.
disp(classes)

% Create a vector of class names.
classNames = [ "RoadMarkings","Tree","Building","Vehicle","Person", ...
               "LifeguardChair","PicnicTable","BlackWoodPanel",...
               "WhiteWoodPanel","OrangeLandingPad","Buoy","Rocks",...
               "LowLevelVegetation","Grass_Lawn","Sand_Beach",...
               "Water_Lake","Water_Pond","Asphalt"]; 

% Overlay the labels on the histogram-equalized RGB training image.
% Add a color bar to the image.
cmap = jet(numel(classNames));
B = labeloverlay(histeq(train_data(:,:,4:6)),train_labels,Transparency=0.8,Colormap=cmap);

figure
imshow(B)
title("Training Labels")
N = numel(classNames);
ticks = 1/(N*2):1/N:1;
colorbar(TickLabels=cellstr(classNames),Ticks=ticks,TickLength=0,TickLabelInterpreter="none");
colormap(cmap)

%%% Perform Semantic Segmentation
% Download a pretrained U-Net network.
trainedUnet_url = "https://www.mathworks.com/supportfiles/vision/data/multispectralUnet.mat";
downloadTrainedNetwork(trainedUnet_url,dataDir);
load(fullfile(dataDir,"multispectralUnet.mat"));

% To perform the semantic segmentation on the trained network, use the segmentMultispectralImage helper function with the validation data.
% This function is attached to the example as a supporting file.
% The segmentMultispectralImage function performs segmentation on image patches using the semanticseg (Computer Vision Toolbox) function.
% Processing patches is required because the size of the image prevents processing the entire image at once.
predictPatchSize = [1024 1024];
segmentedImage = segmentMultispectralImage(val_data,net,predictPatchSize);

% To extract only the valid portion of the segmentation, multiply the segmented image by the mask channel of the validation data.
segmentedImage = uint8(val_data(:,:,7)~=0) .* segmentedImage;

figure
imshow(segmentedImage,[])
title("Segmented Image")

% The output of semantic segmentation is noisy.
% Perform post image processing to remove noise and stray pixels.
% Use the medfilt2 function to remove salt-and-pepper noise from the segmentation.
% Visualize the segmented image with the noise removed.
segmentedImage = medfilt2(segmentedImage,[7,7]);
imshow(segmentedImage,[]);
title("Segmented Image with Noise Removed")

% Overlay the segmented image on the histogram-equalized RGB validation image.
B = labeloverlay(histeq(val_data(:,:,[3 2 1])),segmentedImage,Transparency=0.8,Colormap=cmap);

figure
imshow(B)
title("Labeled Segmented Image")
colorbar(TickLabels=cellstr(classNames),Ticks=ticks,TickLength=0,TickLabelInterpreter="none");
colormap(cmap)

%%% Calculate Extent of Vegetation Cover
% The semantic segmentation results can be used to answer pertinent ecological questions.
% For example, what percentage of land area is covered by vegetation?
% To answer this question, find the number of pixels labeled vegetation.
% The label IDs 2 ("Trees"), 13 ("LowLevelVegetation"), and 14 ("Grass_Lawn") are the vegetation classes.
% Also find the total number of valid pixels by summing the pixels in the ROI of the mask image.
vegetationClassIds = uint8([2,13,14]);
vegetationPixels = ismember(segmentedImage(:),vegetationClassIds);
validPixels = (segmentedImage~=0);

numVegetationPixels = sum(vegetationPixels(:));
numValidPixels = sum(validPixels(:));

% Calculate the percentage of vegetation cover by dividing the number of vegetation pixels by the number of valid pixels.
percentVegetationCover = (numVegetationPixels/numValidPixels)*100;
fprintf("The percentage of vegetation cover is %3.2f%%.",percentVegetationCover);

% The rest of the example shows you how to train U-Net on the Hamlin Beach dataset.

%%% Create Random Patch Extraction Datastore for Training
% Use a random patch extraction datastore to feed the training data to the network.
% This datastore extracts multiple corresponding random patches from an image datastore and pixel label datastore that contain ground truth images and pixel label data.
% Patching is a common technique to prevent running out of memory for large images and to effectively increase the amount of available training data.

% Begin by loading the training images from "train_data.mat" in an imageDatastore.
% Because the MAT file format is a nonstandard image format, you must use a MAT file reader to enable reading the image data.
% You can use the helper MAT file reader, matRead6Channels, that extracts the first six channels from the training data and omits the last channel containing the mask.
% This function is attached to the example as a supporting file.
imds = imageDatastore("train_data.mat",FileExtensions=".mat",ReadFcn=@matRead6Channels);

% Create a pixelLabelDatastore (Computer Vision Toolbox) to store the label patches containing the 18 labeled regions.
pixelLabelIds = 1:18;
pxds = pixelLabelDatastore("train_labels.png",classNames,pixelLabelIds);

% Create a randomPatchExtractionDatastore from the image datastore and the pixel label datastore.
% Each mini-batch contains 16 patches of size 256-by-256 pixels.
% One thousand mini-batches are extracted at each iteration of the epoch.
dsTrain = randomPatchExtractionDatastore(imds,pxds,[256,256],PatchesPerImage=16000);

% The random patch extraction datastore dsTrain provides mini-batches of data to the network at each iteration of the epoch.
% Preview the datastore to explore the data.
inputBatch = preview(dsTrain);
disp(inputBatch)

%%% Create U-Net Network Layers
% This example uses a variation of the U-Net network.
% In U-Net, the initial series of convolutional layers are interspersed with max pooling layers, successively decreasing the resolution of the input image.
% These layers are followed by a series of convolutional layers interspersed with upsampling operators, successively increasing the resolution of the input image [2].
% The name U-Net comes from the fact that the network can be drawn with a symmetric shape like the letter U.

% This example modifies the U-Net to use zero-padding in the convolutions, so that the input and the output to the convolutions have the same size.
% Use the helper function, createUnet, to create a U-Net with a few preselected hyperparameters.
% This function is attached to the example as a supporting file.
inputTileSize = [256,256,6];
lgraph = createUnet(inputTileSize);
disp(lgraph.Layers)

%%% Select Training Options
% Train the network using stochastic gradient descent with momentum (SGDM) optimization.
% Specify the hyperparameter settings for SGDM by using the trainingOptions (Deep Learning Toolbox) function.

% Training a deep network is time-consuming.
% Accelerate the training by specifying a high learning rate.
% However, this can cause the gradients of the network to explode or grow uncontrollably, preventing the network from training successfully.
% To keep the gradients in a meaningful range, enable gradient clipping by specifying "GradientThreshold" as 0.05, and specify "GradientThresholdMethod" to use the L2-norm of the gradients.
initialLearningRate = 0.05;
maxEpochs = 150;
minibatchSize = 16;
l2reg = 0.0001;

options = trainingOptions("sgdm",...
    InitialLearnRate=initialLearningRate, ...
    Momentum=0.9,...
    L2Regularization=l2reg,...
    MaxEpochs=maxEpochs,...
    MiniBatchSize=minibatchSize,...
    LearnRateSchedule="piecewise",...    
    Shuffle="every-epoch",...
    GradientThresholdMethod="l2norm",...
    GradientThreshold=0.05, ...
    Plots="training-progress", ...
    VerboseFrequency=20);

%%% Train the Network or Download Pretrained Network
% To train the network, set the doTraining variable in the following code to true.
% Train the model by using the trainNetwork (Deep Learning Toolbox) function.

% Train on a GPU if one is available.
% Using a GPU requires Parallel Computing Toolbox™ and a CUDA® enabled NVIDIA® GPU.
% For more information, see GPU Computing Requirements (Parallel Computing Toolbox).
% Training takes about 20 hours on an NVIDIA Titan X.
doTraining = false; 
if doTraining
    net = trainNetwork(dsTrain,lgraph,options);
    modelDateTime = string(datetime("now",Format="yyyy-MM-dd-HH-mm-ss"));
    save(fullfile(dataDir,"multispectralUnet-"+modelDateTime+".mat"),"net");
end

%%% Evaluate Segmentation Accuracy
% Segment the validation data.
segmentedImage = segmentMultispectralImage(val_data,net,predictPatchSize);

% Save the segmented image and ground truth labels as PNG files.
% The example uses these files to calculate accuracy metrics.
imwrite(segmentedImage,"results.png");
imwrite(val_labels,"gtruth.png");

% Load the segmentation results and ground truth using pixelLabelDatastore (Computer Vision Toolbox).
pxdsResults = pixelLabelDatastore("results.png",classNames,pixelLabelIds);
pxdsTruth = pixelLabelDatastore("gtruth.png",classNames,pixelLabelIds);

% Measure the global accuracy of the semantic segmentation by using the evaluateSemanticSegmentation (Computer Vision Toolbox) function.
ssm = evaluateSemanticSegmentation(pxdsResults,pxdsTruth,Metrics="global-accuracy");

% The global accuracy score indicates that just over 90% of the pixels are classified correctly.

%%% References
% [1] Kemker, R., C. Salvaggio, and C. Kanan. "High-Resolution Multispectral Dataset for Semantic Segmentation." CoRR, abs/1703.01918. 2017.
% [2] Ronneberger, O., P. Fischer, and T. Brox. "U-Net: Convolutional Networks for Biomedical Image Segmentation." CoRR, abs/1505.04597. 2015.
% [3] Kemker, Ronald, Carl Salvaggio, and Christopher Kanan. "Algorithms for Semantic Segmentation of Multispectral Remote Sensing Imagery Using Deep Learning." ISPRS Journal of Photogrammetry and Remote Sensing, Deep Learning RS Data, 145 (November 1, 2018): 60-77. https://doi.org/10.1016/j.isprsjprs.2018.04.014.

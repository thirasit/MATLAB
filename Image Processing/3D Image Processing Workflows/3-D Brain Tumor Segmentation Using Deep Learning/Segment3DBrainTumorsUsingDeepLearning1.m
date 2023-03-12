%% 3-D Brain Tumor Segmentation Using Deep Learning
% This example shows how to perform semantic segmentation of brain tumors from 3-D medical images.

% Semantic segmentation involves labeling each pixel in an image or voxel of a 3-D volume with a class. 
% This example illustrates the use of a 3-D U-Net deep learning network to perform binary semantic segmentation of brain tumors in magnetic resonance imaging (MRI) scans. 
% U-Net is a fast, efficient and simple network that has become popular in the semantic segmentation domain [1].

% One challenge of medical image segmentation is the amount of memory needed to store and process 3-D volumes. 
% Training a network and performing segmentation on the full input volume is impractical due to GPU resource constraints. 
% This example solves the problem by dividing the image into smaller patches, or blocks, for training and segmentation.

% A second challenge of medical image segmentation is class imbalance in the data that hampers training when using conventional cross entropy loss. 
% This example solves the problem by using a weighted multiclass Dice loss function [4]. 
% Weighting the classes helps to counter the influence of larger regions on the Dice score, making it easier for the network to learn how to segment smaller regions.

% This example shows how to perform brain tumor segmentation using a pretrained 3-D U-Net architecture, and how to evaluate the network performance using a set of test images. 
% You can optionally train a 3-D U-Net on the BraTS data set [2].

%%% Perform Brain Tumor Segmentation Using Pretrained 3-D U-Net
% Download Pretrained 3-D U-Net
% Download a pretrained 3-D U-Net into a variable called net.
dataDir = fullfile(tempdir,"BraTS");
if ~exist(dataDir,'dir')
    mkdir(dataDir);
end
trained3DUnetURL = "https://www.mathworks.com/supportfiles/"+ ...
    "vision/data/brainTumor3DUNetValid.mat";
downloadTrainedNetwork(trained3DUnetURL,dataDir);
load(dataDir+filesep+"brainTumor3DUNetValid.mat");

%%% Download BraTS Sample Data
% Download five sample test volumes and their corresponding labels from the BraTS data set using the downloadBraTSSampleTestData helper function [3]. 
% The helper function is attached to the example as a supporting file. 
% The sample data enables you to perform segmentation on test data without downloading the full data set.
downloadBraTSSampleTestData(dataDir);

% Load one of the volume samples along with its pixel label ground truth.
testDir = dataDir+filesep+"sampleBraTSTestSetValid";
data = load(fullfile(testDir,"imagesTest","BraTS446.mat"));
labels = load(fullfile(testDir,"labelsTest","BraTS446.mat"));
volTest = data.cropVol;
volTestLabels = labels.cropLabel;

%%% Perform Semantic Segmentation
% The example uses an overlap-tile strategy to process the large volume. 
% The overlap-tile strategy selects overlapping blocks, predicts the labels for each block by using the semanticseg (Computer Vision Toolbox) function, and then recombines the blocks into a complete segmented test volume. 
% The strategy enables efficient processing on the GPU, which has limited memory resources. 
% The strategy also reduces border artifacts by using the valid part of the convolution in the neural network [5].

% Implement the overlap-tile strategy by storing the volume data as a blockedImage object and processing blocks using the apply function.

% Create a blockedImage object for the sample volume downloaded in the previous section.
bim = blockedImage(volTest);

% The apply function executes a custom function for each block within the blockedImage. 
% Define semanticsegBlock as the function to execute for each block.
semanticsegBlock = @(bstruct)semanticseg(bstruct.Data,net);

% Specify the block size as the network output size. 
% To create overlapping blocks, specify a nonzero border size. 
% This example uses a border size such that the block plus the border match the network input size.
networkInputSize = net.Layers(1).InputSize;
networkOutputSize = net.Layers(end).OutputSize;
blockSize = [networkOutputSize(1:3) networkInputSize(end)];
borderSize = (networkInputSize(1:3) - blockSize(1:3))/2;

% Perform semantic segmentation using blockedImage apply with partial block padding set to true. 
% The default padding method, "replicate", is appropriate because the volume data contains multiple modalities. 
% The batch size is specified as 1 to prevent out-of-memory errors on GPUs with constrained memory resources. 
% However, if your GPU has sufficient memory, then you can increase the processessing speed by increasing the block size.
batchSize = 1;
results = apply(bim, ...
    semanticsegBlock, ...
    BlockSize=blockSize, ...
    BorderSize=borderSize,...
    PadPartialBlocks=true, ...
    BatchSize=batchSize);
predictedLabels = results.Source;

% Display a montage showing the center slice of the ground truth and predicted labels along the depth direction.
zID = size(volTest,3)/2;
zSliceGT = labeloverlay(volTest(:,:,zID),volTestLabels(:,:,zID));
zSlicePred = labeloverlay(volTest(:,:,zID),predictedLabels(:,:,zID));

figure
montage({zSliceGT,zSlicePred},Size=[1 2],BorderSize=5) 
title("Labeled Ground Truth (Left) vs. Network Prediction (Right)")

% The following image shows the result of displaying slices sequentially across the one of the volumes. 
% The labeled ground truth is on the left and the network prediction is on the right.
figure
imshow("Segment3DBrainTumorsUsingDeepLearningExample_02.gif")

%%% Train 3-D U-Net
% This part of the example shows how to train a 3-D U-Net. 
% If you do not want to download the training data set or train the network, then you can skip to the Evaluate Network Performance section of this example.

%%% Download BraTS Data Set
% This example uses the BraTS data set [2]. 
% The BraTS data set contains MRI scans of brain tumors, namely gliomas, which are the most common primary brain malignancies. 
% The size of the data file is ~7 GB.

% To download the BraTS data, go to the Medical Segmentation Decathlon website and click the "Download Data" link. 
% Download the "Task01_BrainTumour.tar" file [3]. 
% Unzip the TAR file into the directory specified by the imageDir variable. 
% When unzipped successfully, imageDir will contain a directory named Task01_BrainTumour that has three subdirectories: imagesTr, imagesTs, and labelsTr.

% The data set contains 750 4-D volumes, each representing a stack of 3-D images. 
% Each 4-D volume has size 240-by-240-by-155-by-4, where the first three dimensions correspond to height, width, and depth of a 3-D volumetric image. 
% The fourth dimension corresponds to different scan modalities. 
% The data set is divided into 484 training volumes with voxel labels and 266 test volumes. 
% The test volumes do not have labels so this example does not use the test data. 
% Instead, the example splits the 484 training volumes into three independent sets that are used for training, validation, and testing.

%%% Preprocess Training and Validation Data
% To train the 3-D U-Net network more efficiently, preprocess the MRI data using the helper function preprocessBraTSDataset. This function is attached to the example as a supporting file. The helper function performs these operations:
% - Crop the data to a region containing primarily the brain and tumor. Cropping the data reduces the size of data while retaining the most critical part of each MRI volume and its corresponding labels.
% - Normalize each modality of each volume independently by subtracting the mean and dividing by the standard deviation of the cropped brain region.
% - Split the 484 training volumes into 400 training, 29 validation, and 55 test sets.
% Preprocessing the data can take about 30 minutes to complete.
sourceDataLoc = dataDir+filesep+"Task01_BrainTumour";
preprocessDataLoc = dataDir+filesep+"preprocessedDataset";
preprocessBraTSDataset(preprocessDataLoc,sourceDataLoc);

%%% Create Random Patch Extraction Datastore for Training and Validation
% Create an imageDatastore to store the 3-D image data. 
% Because the MAT file format is a nonstandard image format, you must use a MAT file reader to enable reading the image data. 
% You can use the helper MAT file reader, matRead. 
% This function is attached to the example as a supporting file.
volLoc = fullfile(preprocessDataLoc,"imagesTr");
volds = imageDatastore(volLoc,FileExtensions=".mat",ReadFcn=@matRead);

% Create a pixelLabelDatastore (Computer Vision Toolbox) to store the labels.
lblLoc = fullfile(preprocessDataLoc,"labelsTr");
classNames = ["background","tumor"];
pixelLabelID = [0 1];
pxds = pixelLabelDatastore(lblLoc,classNames,pixelLabelID, ...
    FileExtensions=".mat",ReadFcn=@matRead);

% Create a randomPatchExtractionDatastore that extracts random patches from ground truth images and corresponding pixel label data. 
% Specify a patch size of 132-by-132-by-132 voxels. 
% Specify "PatchesPerImage" to extract 16 randomly positioned patches from each pair of volumes and labels during training. 
% Specify a mini-batch size of 8.
patchSize = [132 132 132];
patchPerImage = 16;
miniBatchSize = 8;
patchds = randomPatchExtractionDatastore(volds,pxds,patchSize, ...
    PatchesPerImage=patchPerImage);
patchds.MiniBatchSize = miniBatchSize;

% Create a randomPatchExtractionDatastore that extracts patches from the validation image and pixel label data. 
% You can use validation data to evaluate whether the network is continuously learning, underfitting, or overfitting as time progresses.
volLocVal = fullfile(preprocessDataLoc,"imagesVal");
voldsVal = imageDatastore(volLocVal,FileExtensions=".mat", ...
    ReadFcn=@matRead);

lblLocVal = fullfile(preprocessDataLoc,"labelsVal");
pxdsVal = pixelLabelDatastore(lblLocVal,classNames,pixelLabelID, ...
    FileExtensions=".mat",ReadFcn=@matRead);

dsVal = randomPatchExtractionDatastore(voldsVal,pxdsVal,patchSize, ...
    PatchesPerImage=patchPerImage);
dsVal.MiniBatchSize = miniBatchSize;

%%% Set Up 3-D U-Net Layers
% This example uses the 3-D U-Net network [1]. 
% In U-Net, the initial series of convolutional layers are interspersed with max pooling layers, successively decreasing the resolution of the input image. 
% These layers are followed by a series of convolutional layers interspersed with upsampling operators, successively increasing the resolution of the input image. 
% A batch normalization layer is introduced before each ReLU layer. 
% The name U-Net comes from the fact that the network can be drawn with a symmetric shape like the letter U.

% Create a default 3-D U-Net network by using the unetLayers (Computer Vision Toolbox) function. 
% Specify two class segmentation. 
% Also specify valid convolution padding to avoid border artifacts when using the overlap-tile strategy for prediction of the test volumes.
numChannels = 4;
inputPatchSize = [patchSize numChannels];
numClasses = 2;
[lgraph,outPatchSize] = unet3dLayers(inputPatchSize, ...
    numClasses,ConvolutionPadding="valid");

% Augment the training and validation data by using the transform function with custom preprocessing operations specified by the helper function augmentAndCrop3dPatch. 
% This function is attached to the example as a supporting file. 
% The augmentAndCrop3dPatch function performs these operations:
% 1. Randomly rotate and reflect training data to make the training more robust. The function does not rotate or reflect validation data.
% 2. Crop response patches to the output size of the network, 44-by-44-by-44 voxels.
dsTrain = transform(patchds, ...
    @(patchIn)augmentAndCrop3dPatch(patchIn,outPatchSize,"Training"));
dsVal = transform(dsVal, ...
    @(patchIn)augmentAndCrop3dPatch(patchIn,outPatchSize,"Validation"));

% To better segment smaller tumor regions and reduce the influence of larger background regions, this example uses a dicePixelClassificationLayer (Computer Vision Toolbox). 
% Replace the pixel classification layer with the Dice pixel classification layer.
outputLayer = dicePixelClassificationLayer(Name="Output");
lgraph = replaceLayer(lgraph,"Segmentation-Layer",outputLayer);

% The data has already been normalized in the Preprocess Training and Validation Data section of this example. 
% Data normalization in the image3dInputLayer (Deep Learning Toolbox) is unnecessary, so replace the input layer with an input layer that does not have data normalization.
inputLayer = image3dInputLayer(inputPatchSize, ...
    Normalization="none",Name="ImageInputLayer");
lgraph = replaceLayer(lgraph,"ImageInputLayer",inputLayer);

% Alternatively, you can modify the 3-D U-Net network by using the Deep Network Designer app.
deepNetworkDesigner(lgraph)
figure
imshow("Segment3DBrainTumorsUsingDeepLearningExample_03.png")

%%% Specify Training Options
% Train the network using the adam optimization solver. 
% Specify the hyperparameter settings using the trainingOptions (Deep Learning Toolbox) function. 
% The initial learning rate is set to 5e-4 and gradually decreases over the span of training. 
% You can experiment with the MiniBatchSize property based on your GPU memory. 
% To maximize GPU memory utilization, favor large input patches over a large batch size. 
% Note that batch normalization layers are less effective for smaller values of MiniBatchSize. 
% Tune the initial learning rate based on the MiniBatchSize.
options = trainingOptions("adam", ...
    MaxEpochs=50, ...
    InitialLearnRate=5e-4, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=5, ...
    LearnRateDropFactor=0.95, ...
    ValidationData=dsVal, ...
    ValidationFrequency=400, ...
    Plots="training-progress", ...
    Verbose=false, ...
    MiniBatchSize=miniBatchSize);

%%% Train Network
% By default, the example uses the downloaded pretrained 3-D U-Net network. 
% The pretrained network enables you to perform semantic segmentation and evaluate the segmentation results without waiting for training to complete.

% To train the network, set the doTraining variable in the following code to true. 
% Train the network using the trainNetwork (Deep Learning Toolbox) function.

% Train on a GPU if one is available. 
% Using a GPU requires Parallel Computing Toolbox™ and a CUDA® enabled NVIDIA® GPU. 
% For more information, see GPU Computing Requirements (Parallel Computing Toolbox). 
% Training takes about 30 hours on a multi-GPU system with 4 NVIDIA™ Titan Xp GPUs and can take even longer depending on your GPU hardware.
doTraining = false;
if doTraining
    [net,info] = trainNetwork(dsTrain,lgraph,options);
    modelDateTime = string(datetime("now",Format="yyyy-MM-dd-HH-mm-ss"));
    save("trained3DUNet-"+modelDateTime+".mat","net");
end

%%% Evaluate Network Performance
% Select the source of test data that contains ground truth volumes and labels for testing. 
% If you keep the useFullTestSet variable in the following code as false, then the example uses five sample volumes for testing. 
% If you set the useFullTestSet variable to true, then the example uses 55 test images selected from the full data set.
useFullTestSet = false;
if useFullTestSet
    volLocTest = fullfile(preprocessDataLoc,"imagesTest");
    lblLocTest = fullfile(preprocessDataLoc,"labelsTest");
else
    volLocTest = fullfile(testDir,"imagesTest");
    lblLocTest = fullfile(testDir,"labelsTest");
end

% The voldsTest variable stores the ground truth test images. 
% The pxdsTest variable stores the ground truth labels.
voldsTest = imageDatastore(volLocTest,FileExtensions=".mat", ...
    ReadFcn=@matRead);
pxdsTest = pixelLabelDatastore(lblLocTest,classNames,pixelLabelID, ...
    FileExtensions=".mat",ReadFcn=@matRead);

% For each test volume, process each block using the apply function. 
% The apply function performs the operations specified by the helper function calculateBlockMetrics, which is defined at the end of this example. 
% The calculateBlockMetrics function performs semantic segmentation of each block and calculates the confusion matrix between the predicted and ground truth labels.
imageIdx = 1;
datasetConfMat = table;
while hasdata(voldsTest)

    % Read volume and label data
    vol = read(voldsTest);
    volLabels = read(pxdsTest);

    % Create blockedImage for volume and label data
    testVolume = blockedImage(vol);
    testLabels = blockedImage(volLabels{1});

    % Calculate block metrics
    blockConfMatOneImage = apply(testVolume, ...
        @(block,labeledBlock) ...
            calculateBlockMetrics(block,labeledBlock,net), ...
        ExtraImages=testLabels, ...
        PadPartialBlocks=true, ...
        BlockSize=blockSize, ...
        BorderSize=borderSize, ...
        UseParallel=false);

    % Read all the block results of an image and update the image number
    blockConfMatOneImageDS = blockedImageDatastore(blockConfMatOneImage);
    blockConfMat = readall(blockConfMatOneImageDS);
    blockConfMat = struct2table([blockConfMat{:}]);
    blockConfMat.ImageNumber = imageIdx.*ones(height(blockConfMat),1);
    datasetConfMat = [datasetConfMat;blockConfMat];

    imageIdx = imageIdx + 1;
end

% Evaluate the data set metrics and block metrics for the segmentation using the evaluateSemanticSegmentation (Computer Vision Toolbox) function.
[metrics,blockMetrics] = evaluateSemanticSegmentation( ...
    datasetConfMat,classNames,Metrics="all");

% Display the Jaccard score calculated for each image.
metrics.ImageMetrics.MeanIoU

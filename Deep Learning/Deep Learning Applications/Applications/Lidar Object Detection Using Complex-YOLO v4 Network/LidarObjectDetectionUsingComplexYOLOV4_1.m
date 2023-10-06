%% Lidar Object Detection Using Complex-YOLO v4 Network
% This example shows how to train a Complex-YOLO v4 network to perform object detection on point clouds.

% The Complex-YOLO [1] approach is effective for lidar object detection as it directly operates on bird's-eye-view RGB maps that are transformed from the point clouds.
% In this example, using the Complex-YOLO approach, you train a YOLO v4 [2] network to predict both 2-D box positions and orientation in the bird's-eye-view frame.
% You then project the 2-D positions along with the orientation predictions back onto the point cloud to generate 3-D bounding boxes around the object of interest.

%%% Download Lidar Data Set
% This example uses a subset of the PandaSet data set [3] that contains 2560 preprocessed organized point clouds.
% Each point cloud covers 360 degrees of view and is specified as a 64-by-1856 matrix.
% The point clouds are stored in PCD format and their corresponding ground truth data is stored in the PandaSetLidarGroundTruth.mat file.
% The file contains 3-D bounding box information for three classes, which are car, truck, and pedestrian. The size of the data set is 5.2 GB.

% Download the PandaSet data set from the given URL using the helperDownloadPandasetData helper function, defined at the end of this example.
outputFolder = fullfile(tempdir,'Pandaset');

lidarURL = ['https://ssd.mathworks.com/supportfiles/lidar/data/' ...
            'Pandaset_LidarData.tar.gz'];

helperDownloadPandasetData(outputFolder,lidarURL);

% Depending on your internet connection, the download process can take some time.
% The code suspends MATLAB® execution until the download process is complete.
% Alternatively, you can download the data set to your local disk using your web browser and extract the file.
% If you do so, change the outputFolder variable in the code to the location of the downloaded file.
% The download file contains Lidar, Cuboids, and semanticLabels folders, which contain the point clouds, cuboid label information, and semantic label information respectively.

%%% Download Pretrained Model
% This example implements two variants of the complex YOLO v4 object detectors:
% - complex-yolov4-pandaset — Standard complex YOLO v4 network trained on bird's-eye-view generated from point clouds of the PandaSet data set
% - tiny-complex-yolov4-pandaset — Lightweight complex YOLO v4 network trained on bird's-eye-view images generated from point clouds of the PandaSet data set
% The pretrained networks are trained on three object categories: car, truck and pedestrian.
modelName = 'tiny-complex-yolov4-pandaset';
mdl = downloadPretrainedComplexYOLOv4(modelName);
net = mdl.net; 

%%% Load Data
% Create a file datastore to load the PCD files from the specified path using the pcread (Computer Vision Toolbox) function.
path = fullfile(outputFolder,'Lidar');
lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));

% Load the 3-D bounding box labels of the car, truck, and pedestrian objects.
gtPath = fullfile(outputFolder,'Cuboids','PandaSetLidarGroundTruth.mat');
data = load(gtPath,'lidarGtLabels');
Labels = timetable2table(data.lidarGtLabels);
boxLabels = Labels(:,2:end);

% Display the full-view point cloud.
figure
ptCld = read(lidarData);
ax = pcshow(ptCld.Location);
set(ax,'XLim',[-50 50],'YLim',[-40 40]);
zoom(ax,2.5);
axis off;

%%% Create Bird's-eye-view Image from Point Cloud Data
% The PandaSet data consists of full-view point clouds.
% For this example, crop the full-view point clouds and convert them to a bird's-eye-view images using the standard parameters.
% These parameters determine the size of the input passed to the network.
% Selecting a smaller range of point clouds along the x-, y-, and z-axes helps you detect objects that are closer to the origin.
xMin = -25.0;     
xMax = 25.0;      
yMin = 0.0;      
yMax = 50.0;      
zMin = -7.0;     
zMax = 15.0;  

% Define the dimensions for the bird's-eye-view image.
% You can set any dimensions for the bird's-eye-view image but the preprocessData helper function resizes it to network input size.
% For this example, the network input size is 608-by-608.
bevHeight = 608;
bevWidth = 608;

% Find the grid resolution.
gridW = (yMax - yMin)/bevWidth;
gridH = (xMax - xMin)/bevHeight;

% Define the grid parameters.
gridParams = {{xMin,xMax,yMin,yMax,zMin,zMax},{bevWidth,bevHeight},{gridW,gridH}};

% Convert the training data to bird's-eye-view images by using the transformPCtoBEV helper function, attached to this example as a supporting file.
% You can set writeFiles to false if your training data is already present in the outputFolder.
writeFiles = true;
if writeFiles
    transformPCtoBEV(lidarData,boxLabels,gridParams,outputFolder);
end

%%% Create Datastore Objects for Training
% Create a datastore for loading the bird's-eye-view images.
dataPath = fullfile(outputFolder,'BEVImages');
imds = imageDatastore(dataPath);

% Create a datastore for loading the ground truth boxes.
labelPath = fullfile(outputFolder,'Cuboids','BEVGroundTruthLabels.mat');
load(labelPath,'processedLabels');
blds = boxLabelDatastore(processedLabels);

% Remove the data that has no labels from the training data.
[imds,blds] = removeEmptyData(imds,blds);

% Split the data set into a training set for training the network and a test set for evaluating the network.
% Use 60% of the data for training set and the rest for testing..
rng(0);
shuffledIndices = randperm(size(imds.Files,1));
idx = floor(0.6 * length(shuffledIndices));

% Split the image datastore into training and test sets.
imdsTrain = subset(imds,shuffledIndices(1:idx));
imdsTest = subset(imds,shuffledIndices(idx+1:end));

% Split the box label datastore into training and test sets.
bldsTrain = subset(blds,shuffledIndices(1:idx));
bldsTest = subset(blds,shuffledIndices(idx+1:end));

% Combine the image and box label datastores.
trainData = combine(imdsTrain,bldsTrain);
testData = combine(imdsTest,bldsTest);

% Use the validateInputDataComplexYOLOv4 helper function, attached to this example as a supporting file, to detect:
% - Samples with an invalid image format or that contain NaNs
% - Bounding boxes containing zeros, NaNs, Infs, or are empty
% - Missing or noncategorical labels.

% The values of the bounding boxes must be finite and positive and cannot be NaNs.
% They must also be within the image boundary with a positive height and width.
validateInputDataComplexYOLOv4(trainData);
validateInputDataComplexYOLOv4(testData);

%%% Preprocess Training Data
% Preprocess the training data to prepare for training.
% The preprocessData helper function, listed at the end of the example, applies the following operations to the input data.
% - Resize the images to the network input size.
% - Scale the image pixels in the range [0 1].
% - Set isRotRect to true to return the rotated rectangles.
networkInputSize = [608 608 3];
isRotRect = true;
preprocessedTrainingData = transform(trainData,@(data)preprocessData(data,networkInputSize,isRotRect));

% Read the preprocessed training data.
data = read(preprocessedTrainingData);

% Display an image with the bounding boxes.
I = data{1,1};
bbox = data{1,2};
labels = data{1,3};
helperDisplayBoxes(I,bbox,labels);

% Reset the datastore.
reset(preprocessedTrainingData);

%%% Modify Pretrained Complex-YOLO V4 Network
% The Complex-YOLO V4 network uses anchor boxes estimated from the training data to have better initial estimate corresponding to the type of data set and to help the network learn to predict the boxes accurately.
% First, because the training images vary in size, use the transform function to preprocess the training data and resize all the images to the same size.
% Specify the number of anchors:
% - complex-yolov4-pandaset model — Specify 9 anchors
% - tiny-complex-yolov4-pandaset model — Specify 6 anchors

% For reproducibility, set the random seed.
% Estimate the anchor boxes using estimateAnchorBoxes function.
% You can set isRotRect to false because the rotation angle is not necessary for the bounding boxes to estimate the anchors.
% For more information about anchor boxes, refer to "Specify Anchor Boxes" section of Getting Started with YOLO v4 (Computer Vision Toolbox).
rng(0)
isRotRect = false;
trainingDataForEstimation = transform(trainData,@(data)preprocessData(data,networkInputSize,isRotRect));
numAnchors = 6;
[anchorBoxes,meanIoU] = estimateAnchorBoxes(trainingDataForEstimation,numAnchors)

% Configure the pretrained model for training using the configureComplexYOLOV4 function.
% This function configures the detection head of the YOLO v4 model to predict the angle regression along with bounding boxes, the objectness score, and classification scores.

% This function returns a the modified layer graph, network output names, reordered anchor boxes, and anchor box masks to select anchor boxes to use in the detected heads.
% The size of an anchor box assigned to a detection head corresponds to the size of the feature map output from the detection head.
% The function reorders the anchor boxes in such a way that the large anchor boxes are assigned to the feature maps with low resolution and small anchor boxes to the feature maps with high resolution.
% Specify the class names to use for training.
classNames = {'Car'
              'Truck'
              'Pedestrain'};
[net,networkOutputs,anchorBoxes] = configureComplexYOLOv4(net,classNames,anchorBoxes,modelName);

%%% Specify Training Options
% Specify these training options.
% - Set the number of epochs to 90.
% - Set the mini batch size to 8. Stable training is possible with higher learning rates when higher mini batch size is used. Set this value depending on the memory available.
% - Set the learning rate to 0.001.
% - Set the warmup period to 1000 iterations. It helps in stabilizing the gradients at higher learning rates.
% - Set the L2 regularization factor to 0.001.
% - Specify the penalty threshold as 0.5. Detections that overlap less than 0.5 with the ground truth are penalized.
% - Initialize the velocity of the gradient as [ ], which is used by SGDM to store the velocity of the gradients.
maxEpochs = 90;
miniBatchSize = 8;
learningRate = 0.001;
warmupPeriod = 1000;
l2Regularization = 0.001;
penaltyThreshold = 0.5;
velocity = [];

%%% Train Model
% Train on a GPU, if one is available.
% Using a GPU requires Parallel Computing Toolbox™ and a CUDA® enabled NVIDIA® GPU.
% For information on supported devices, see GPU Computing Requirements (Parallel Computing Toolbox).

% Use the minibatchqueue function to split the preprocessed training data into batches with the supporting function createBatchData, defined at the end of the example, which returns the batched images and bounding boxes combined with the respective class IDs.
% For faster extraction of the batch data for training, set the dispatchInBackground to true to use a parallel pool.

% minibatchqueue automatically detects whether a GPU is available.
% If you do not have a GPU or do not want to use one for training, set the OutputEnvironment parameter to cpu.
if canUseParallelPool
   dispatchInBackground = true;
else
   dispatchInBackground = false;
end

mbqTrain = minibatchqueue(preprocessedTrainingData,2, ...
        "MiniBatchSize",miniBatchSize,...
        "MiniBatchFcn",@(images,boxes,labels) createBatchData(images,boxes,labels,classNames), ...
        "MiniBatchFormat",["SSCB",""],...
        "DispatchInBackground",dispatchInBackground,...
        "OutputCast",["","double"]);

% Create the training progress plot using the supporting function configureTrainingProgressPlotter.
% Finally, specify the custom training loop.
% For each iteration:
% - Read data from the minibatchqueue. If it has no more data, reset the minibatchqueue and shuffle.
% - Evaluate the model gradients using the dlfeval and the modelGradients supporting function, listed at the end of this example.
% - Apply a weight decay factor to the gradients to regularization for more robust training.
% - Determine the learning rate based on the iterations using the piecewiseLearningRateWithWarmup supporting function.
% - Update the net parameters using the sgdmupdate function.
% - Update the state parameters of net with the moving average.
% - Display the learning rate, total loss, and the individual losses (box loss, object loss, and class loss) for every iteration. Use these values to interpret how the respective losses change in each iteration. For example, a sudden spike in the box loss after a few iterations implies that the predictions contain Inf values or NaNs.
% - Update the training progress plot.

% You can terminate the training if the loss saturates for a few epochs.
doTraining = false;

if doTraining
    iteration = 0;
   
    % Create subplots for the learning rate and mini-batch loss.
    fig = figure;
    [lossPlotter, learningRatePlotter] = configureTrainingProgressPlotter(fig);

    % Custom training loop.
    for epoch = 1:maxEpochs
          
        reset(mbqTrain);
        shuffle(mbqTrain);
        
        while(hasdata(mbqTrain))
            iteration = iteration + 1;
           
            [XTrain,YTrain] = next(mbqTrain);
            
            % Evaluate the model gradients and loss using dlfeval and the
            % modelGradients function.
            [gradients,state,lossInfo] = dlfeval(@modelGradients,net,XTrain,YTrain,anchorBoxes,penaltyThreshold,networkOutputs);
    
            % Apply L2 regularization.
            gradients = dlupdate(@(g,w) g + l2Regularization*w, gradients, net.Learnables);
    
            % Determine the current learning rate value.
            currentLR = piecewiseLearningRateWithWarmup(iteration,epoch,learningRate,warmupPeriod,maxEpochs);
            
            % Update the network learnable parameters using the SGDM optimizer.
            [net,velocity] = sgdmupdate(net,gradients,velocity,currentLR);
    
            % Update the state parameters of dlnetwork.
            net.State = state;
            
            % Display progress.
            if mod(iteration,10)==1
                displayLossInfo(epoch,iteration,currentLR,lossInfo);
            end
                
            % Update training plot with new points.
            updatePlots(lossPlotter,learningRatePlotter,iteration,currentLR,lossInfo.totalLoss);
        end
    end
else
    net = mdl.net;
    anchorBoxes = mdl.anchorBoxes;
end

% To find optimal training options by sweeping through ranges of hyperparameter values, use the Deep Network Designer app.

%%% Evaluate Model
% Computer Vision Toolbox™ provides object detector evaluation functions to measure common metrics such as average precision (evaluateDetectionAOS) for rotated rectangles.
% This example uses the average orientation similarity (AOS) metric.
% AOS is a metric for measuring detector performance on rotated rectangle detections.
% This metric provides a single number that incorporates the ability of the detector to make correct classifications (precision) and the ability of the detector to find all relevant objects (recall).
% Create a table to hold the bounding boxes, scores, and labels returned by
% the detector. 
results = table('Size',[0 3], ...
    'VariableTypes',{'cell','cell','cell'}, ...
    'VariableNames',{'Boxes','Scores','Labels'});

% Run the detector on images in the test set and collect the results.
reset(testData)
while hasdata(testData)
    % Read the datastore and get the image.
    data = read(testData);
    image = data{1,1};
    
    % Run the detector.
    executionEnvironment = 'auto';
    [bboxes,scores,labels] = detectComplexYOLOv4(net,image,anchorBoxes,classNames,executionEnvironment);
    
    % Collect the results.
    tbl = table({bboxes},{scores},{labels},'VariableNames',{'Boxes','Scores','Labels'});
    results = [results; tbl];
end

% Evaluate the object detector using the average precision metric.
metrics = evaluateDetectionAOS(results, testData)

%%% Detect Objects Using Trained Complex-YOLO V4
% Use the network for object detection.
% Read the datastore.
reset(testData)
data = read(testData);

% Get the image.
I = data{1,1};

% Run the detector.
executionEnvironment = 'auto';
[bboxes,scores,labels] = detectComplexYOLOv4(net,I,anchorBoxes,classNames,executionEnvironment);

% Display the output.
figure
helperDisplayBoxes(I,bboxes,labels);

% Transfer the detected boxes to a point cloud using the transferbboxToPointCloud helper function, attached to this example as a supporting file.
lidarTestData = subset(lidarData,shuffledIndices(idx+1:end));
ptCld = read(lidarTestData);
[ptCldOut,bboxCuboid] = transferbboxToPointCloud(bboxes,gridParams,ptCld);
helperDisplayBoxes(ptCldOut,bboxCuboid,labels);

%%% References
% [1] Simon, Martin, Stefan Milz, Karl Amende, and Horst-Michael Gross. "Complex-YOLO: Real-Time 3D Object Detection on Point Clouds". ArXiv:1803.06199 [Cs], 24 September 2018. https://arxiv.org/abs/1803.06199.
% [2] Bochkovskiy, Alexey, Chien-Yao Wang, and Hong-Yuan Mark Liao. "YOLOv4: Optimal Speed and Accuracy of Object Detection". ArXiv:2004.10934 [Cs, Eess], 22 April 2020. https://arxiv.org/abs/2004.10934.
% [3] PandaSet is provided by Hesai and Scale under the CC-BY-4.0 license.

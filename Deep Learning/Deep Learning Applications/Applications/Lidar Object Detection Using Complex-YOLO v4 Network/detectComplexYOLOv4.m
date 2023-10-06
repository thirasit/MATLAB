function [bboxes, scores, labels] = detectComplexYOLOv4(dlnet, image, anchors, classNames, executionEnvironment)
% detectComplexYOLOv4 runs prediction on a trained complex yolov4 network.
%
% Inputs:
% dlnet                - Pretrained complex yolov4 dlnetwork.
% image                - RGB image to run prediction on. (H x W x 3)
% anchors              - Anchors used in training of the pretrained model.
% classNames           - Classnames to be used in detection.
% executionEnvironment - Environment to run predictions on. Specify cpu,
%                        gpu, or auto.
%
% Outputs:
% bboxes     - Final bounding box detections ([x y w h rot]) formatted as
%              NumDetections x 5.
% scores     - NumDetections x 1 classification scores.
% labels     - NumDetections x 1 categorical class labels.

% Copyright 2021 The MathWorks, Inc.

% Get the input size of the network.
inputSize = dlnet.Layers(1).InputSize;

% Process the input image.
imgSize = [size(image,1),size(image,2)];
image =  im2single(imresize(image,inputSize(:,1:2)));
scale = imgSize./inputSize(1:2);

% Convert to dlarray.
dlInput = dlarray(image, 'SSCB');

% If GPU is available, then convert data to gpuArray.
if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
    dlInput = gpuArray(dlInput);
end

% Perform prediction on the input image.
outFeatureMaps = cell(length(dlnet.OutputNames), 1);
[outFeatureMaps{:}] = predict(dlnet, dlInput);

% Apply postprocessing on the output feature maps.
[bboxes,scores,labels] = postprocess(outFeatureMaps, anchors, ...
                                     inputSize, scale, classNames);
end

%% Get the boxes, scores and labels from the activations.
function [bboxes,scores,labels] = postprocess(outFeatureMaps, anchorBoxes, inputSize, scale, classNames)
% The postprocess function applies postprocessing on the generated feature
% maps and returns bounding boxes, detection scores and labels.
%
% Copyright 2021 The MathWorks, Inc.

% Get number of classes.
classNames = categorical(classNames);
numClasses = numel(classNames);

% Get anchor boxes and anchor boxes masks.
anchorBoxesSet = cell2mat(anchorBoxes);

maskIdx = 1:size(anchorBoxesSet,1);
cellsz = cellfun(@size,anchorBoxes,'uni',false);
convMask = cellfun(@(v)v(1),cellsz);
anchorBoxMasks = mat2cell(maskIdx,1,convMask)';

% Postprocess generated feature maps.
outputFeatures = [];
for i = 1:size(outFeatureMaps,1)
    currentFeatureMap = outFeatureMaps{i};
    numY = size(currentFeatureMap,1);
    numX = size(currentFeatureMap,2);
    stride = max(inputSize)./max(numX, numY);
    batchsize = size(currentFeatureMap,4);
    h = numY;
    w = numX;
    numAnchors = size(anchorBoxMasks{i},2);

    currentFeatureMap = reshape(currentFeatureMap,h,w,7+numClasses,numAnchors,batchsize);
    currentFeatureMap = permute(currentFeatureMap,[5,4,1,2,3]);
    
    [~,~,yv,xv] = ndgrid(1:batchsize,1:numAnchors,0:h-1,0:w-1);
    gridXY = cat(5,xv,yv);
    currentFeatureMap(:,:,:,:,1:2) = sigmoid(currentFeatureMap(:,:,:,:,1:2)) + gridXY;
    anchorBoxesCurrentLevel= anchorBoxes(i,:);
    anchorBoxesCurrentLevel = anchorBoxesCurrentLevel{1};
    anchorBoxesCurrentLevel(:,[2,1]) = anchorBoxesCurrentLevel(:,[1,2]);
    anchor_grid = anchorBoxesCurrentLevel/stride;
    anchor_grid = reshape(anchor_grid,1,numAnchors,1,1,2);
    currentFeatureMap(:,:,:,:,3:4) = exp(currentFeatureMap(:,:,:,:,3:4)).*anchor_grid;
    currentFeatureMap(:,:,:,:,1:4) = currentFeatureMap(:,:,:,:,1:4)*stride;
    currentFeatureMap(:,:,:,:,5:6) = tanh(currentFeatureMap(:,:,:,:,5:6));
    currentFeatureMap(:,:,:,:,7:end) = sigmoid(currentFeatureMap(:,:,:,:,7:end));

    if numClasses == 1
        currentFeatureMap(:,:,:,:,8) = 1;
    end
    currentFeatureMap = reshape(currentFeatureMap,batchsize,[],7+numClasses);
    
    if isempty(outputFeatures)
        outputFeatures = currentFeatureMap;
    else
        outputFeatures = cat(2,outputFeatures,currentFeatureMap);
    end
end

% Coordinate conversion to the original image.
outputFeatures = extractdata(outputFeatures);                                         % [x_center,y_center,w,h,Pobj,p1,p2,...,pn]
outputFeatures(:,:,[1,3]) = outputFeatures(:,:,[1,3])*scale(2);                       % x_center,width
outputFeatures(:,:,[2,4]) = outputFeatures(:,:,[2,4])*scale(1);                       % y_center,height

outputFeatures(:,:,5) = rad2deg(atan2(outputFeatures(:,:,5),outputFeatures(:,:,6)));
outputFeatures = squeeze(outputFeatures); % If it is a single image detection, the output size is M*(7+numClasses), otherwise it is bs*M*(7+numClasses)

if(canUseGPU())
    outputFeatures = gather(outputFeatures);
end

% Apply Confidence threshold and Non-maximum suppression.
confidenceThreshold = 0.5;
overlapThresold = 0.01;

scores = outputFeatures(:,7);
outFeatures = outputFeatures(scores>confidenceThreshold,:);

allBBoxes = outFeatures(:,1:5);
allScores = outFeatures(:,7);
[maxScores,indxs] = max(outFeatures(:,8:end),[],2);
allScores = allScores.*maxScores;
allLabels = classNames(indxs);

bboxes = [];
scores = [];
labels = [];
if ~isempty(allBBoxes)
    [bboxes,scores,labels] = selectStrongestBboxMulticlass(allBBoxes,allScores,allLabels,...
        'RatioType','Min','OverlapThreshold',overlapThresold);
end
end
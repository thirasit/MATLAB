function [net, networkOutputs, anchorBoxes] = configureComplexYOLOv4(net, classNames, anchorBoxes, modelName)
% Configure the pretrained network for transfer learning.

% Copyright 2021 The MathWorks, Inc.

% Specify anchorBoxMasks to select anchor boxes to use in both the detection 
% heads. anchorBoxMasks is a cell array of [Mx1], where M denotes the number 
% of detection heads. Each detection head consists of a [1xN] array of row 
% index of anchors in anchorBoxes, where N is the number of anchor boxes to 
% use. 
% Select anchor boxes for each detection head based on size. Use larger 
% anchor boxes at lower scale and smaller anchor boxes at higher scale.
if strcmp(modelName, 'complex-yolov4-pandaset')
    area = anchorBoxes(:, 1).*anchorBoxes(:, 2);
    [~, idx] = sort(area, 'ascend');
    anchorBoxes = anchorBoxes(idx, :);
    anchorBoxes = {anchorBoxes(1:3,:)
                   anchorBoxes(4:6,:)
                   anchorBoxes(7:9,:)};
elseif strcmp(modelName, 'tiny-complex-yolov4-pandaset')
    area = anchorBoxes(:, 1).*anchorBoxes(:, 2);
    [~, idx] = sort(area, 'descend');
    anchorBoxes = anchorBoxes(idx, :);
    anchorBoxes = {anchorBoxes(1:3,:)
                   anchorBoxes(4:6,:)};
end
 
% Specify the number of object classes to detect, and number of prediction 
% elements per anchor box. The number of predictions per anchor box is set 
% to 7 plus the number of object classes. "7" denoted the 4 bounding box 
% attributes, two angle attributes and 1 object confidence.
numClasses = size(classNames, 1);
numPredictorsPerAnchor = 7 + numClasses;
 
% Modify the layegraph to train with new set of classes.
lgraph = layerGraph(net);

if strcmp(modelName, 'complex-yolov4-pandaset')
    yoloModule1 = convolution2dLayer(1,length(anchorBoxes{1})*numPredictorsPerAnchor,'Name','yoloconv1');
    yoloModule2 = convolution2dLayer(1,length(anchorBoxes{2})*numPredictorsPerAnchor,'Name','yoloconv2');
    yoloModule3 = convolution2dLayer(1,length(anchorBoxes{3})*numPredictorsPerAnchor,'Name','yoloconv3');

    lgraph = replaceLayer(lgraph,'yoloconv1',yoloModule1);
    lgraph = replaceLayer(lgraph,'yoloconv2',yoloModule2);
    lgraph = replaceLayer(lgraph,'yoloconv3',yoloModule3);

    networkOutputs = ["yoloconv1"
                      "yoloconv2"
                      "yoloconv3"
                     ];
elseif strcmp(modelName, 'tiny-complex-yolov4-pandaset')
    yoloModule1 = convolution2dLayer(1,length(anchorBoxes{1})*numPredictorsPerAnchor,'Name','yoloconv1');
    yoloModule2 = convolution2dLayer(1,length(anchorBoxes{2})*numPredictorsPerAnchor,'Name','yoloconv2');

    lgraph = replaceLayer(lgraph,'yoloconv1',yoloModule1);
    lgraph = replaceLayer(lgraph,'yoloconv2',yoloModule2);

    networkOutputs = ["yoloconv1"
                      "yoloconv2"
                     ];
end   

net = dlnetwork(lgraph);
end
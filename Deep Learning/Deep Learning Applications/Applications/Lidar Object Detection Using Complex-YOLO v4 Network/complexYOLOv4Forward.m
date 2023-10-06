function [YPredCell, state] = complexYOLOv4Forward(net, XTrain, networkOutputs, anchorBoxes)
% Predict the output of network and extract the confidence score, x, y,
% width, height, rotation and class.

% Copyright 2021 The MathWorks, Inc.

YPredictions = cell(size(networkOutputs));
[YPredictions{:}, state] = forward(net, XTrain, 'Outputs', networkOutputs);
YPredCell = extractPredictions(YPredictions, anchorBoxes);

% Append predicted width and height to the end as they are required
% for computing the loss.
YPredCell(:,9:10) = YPredCell(:,4:5);

% Apply sigmoid and exponential activation.
YPredCell(:,1:8) = applyActivationsComplexYOLOv4(YPredCell(:,1:8));
end

%% Applying activations

function YPredCell = applyActivationsComplexYOLOv4(YPredCell)
% Apply activation functions on YOLOv4 outputs.

% Copyright 2021 The MathWorks, Inc.

YPredCell(:,1:3) = cellfun(@ sigmoid, YPredCell(:,1:3), 'UniformOutput', false);
YPredCell(:,4:5) = cellfun(@ exp, YPredCell(:,4:5), 'UniformOutput', false);    
YPredCell(:,6:7) = cellfun(@ tanh, YPredCell(:,6:7), 'UniformOutput', false);    
YPredCell(:,8) = cellfun(@ sigmoid, YPredCell(:,8), 'UniformOutput', false);
end

%% Extract predictions

function predictions = extractPredictions(YPredictions, anchorBoxes)
% Function extractPrediction extracts and rearranges the prediction outputs
% from YOLOv4 network.

% Copyright 2021 The MathWorks, Inc.

predictions = cell(size(YPredictions, 1),6);
for ii = 1:size(YPredictions, 1)
    % Get the required info on feature size.
    numChannelsPred = size(YPredictions{ii},3);
    numAnchors = size(anchorBoxes{ii},1);
    numPredElemsPerAnchors = numChannelsPred/numAnchors;
    allIds = (1:numChannelsPred);
    
    stride = numPredElemsPerAnchors;
    endIdx = numChannelsPred;

    % X positions.
    startIdx = 1;
    predictions{ii,2} = YPredictions{ii}(:,:,startIdx:stride:endIdx,:);
    xIds = startIdx:stride:endIdx;
    
    % Y positions.
    startIdx = 2;
    predictions{ii,3} = YPredictions{ii}(:,:,startIdx:stride:endIdx,:);
    yIds = startIdx:stride:endIdx;
    
    % Width.
    startIdx = 3;
    predictions{ii,4} = YPredictions{ii}(:,:,startIdx:stride:endIdx,:);
    wIds = startIdx:stride:endIdx;
    
    % Height.
    startIdx = 4;
    predictions{ii,5} = YPredictions{ii}(:,:,startIdx:stride:endIdx,:);
    hIds = startIdx:stride:endIdx;

    % Cos angle.
    startIdx = 5;
    predictions{ii,6} = YPredictions{ii}(:,:,startIdx:stride:endIdx,:);
    angleIds1 = startIdx:stride:endIdx;
    
    % Sin angle.
    startIdx = 6;
    predictions{ii,7} = YPredictions{ii}(:,:,startIdx:stride:endIdx,:);
    angleIds2 = startIdx:stride:endIdx;
    
    % Confidence scores.
    startIdx = 7;
    predictions{ii,1} = YPredictions{ii}(:,:,startIdx:stride:endIdx,:);
    confIds = startIdx:stride:endIdx;
    
    % Accummulate all the non-class indexes
    nonClassIds = [xIds yIds wIds hIds angleIds1 angleIds2 confIds];
    
    % Class probabilities.
    % Get the indexes which do not belong to the nonClassIds
    classIdx = setdiff(allIds,nonClassIds);
    predictions{ii,8} = YPredictions{ii}(:,:,classIdx,:);
end
end
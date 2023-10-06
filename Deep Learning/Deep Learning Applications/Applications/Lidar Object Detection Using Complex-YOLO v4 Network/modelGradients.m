%% Model Gradients
% The function modelGradients takes as input the Complex-YOLO v4 network, a mini-batch of input data XTrain with corresponding ground truth boxes YTrain, and the specified penalty threshold.
% It returns the gradients of the loss with respect to the learnable parameters in net, the corresponding mini-batch loss information, and the state of the current batch.
% The modelGradients function computes the total loss and gradients by performing these operations.
% - Generate predictions from the input batch of images using the complexYOLOv4Forward method.
% - Collect predictions on the CPU for postprocessing.
% - Convert the predictions from the Complex-YOLO v4 grid cell coordinates to bounding box coordinates to allow easy comparison with the ground truth data.
% - Generate targets for loss computation by using the converted predictions and ground truth data. Generate the targets for bounding box positions (x, y, width, height, yaw), object confidence, and class probabilities. See the supporting function generateComplexYOLOv4Targets.
% - Calculate the mean squared error of the predicted bounding box coordinates with target boxes using the supporting function bboxOffsetLoss, defined at the end of the example.
% - Calculate the binary cross-entropy of the predicted object confidence score with a target object confidence score using the supporting function objectnessLoss, defined at the end of the example.
% - Calculate the binary cross-entropy of the predicted class of object with the target using the supporting function classConfidenceLoss, defined at the end of the example.
% - Compute the total loss as the sum of all losses.
% - Compute the gradients of learnables with respect to the total loss.
function [gradients,state,info] = modelGradients(net,XTrain,YTrain,anchors,penaltyThreshold,networkOutputs)

    inputImageSize = size(XTrain,1:2);
    
    % Gather the ground truths in the CPU for postprocessing.
    YTrain = gather(extractdata(YTrain));
    
    % Extract the predictions from the network.
    [YPredCell,state] = complexYOLOv4Forward(net,XTrain,networkOutputs,anchors);
    
    % Gather the activations in the CPU for postprocessing and extract dlarray data. 
    gatheredPredictions = cellfun(@ gather,YPredCell(:,1:8),'UniformOutput',false); 
    gatheredPredictions = cellfun(@ extractdata, gatheredPredictions,'UniformOutput', false);
    
    % Convert predictions from grid cell coordinates to box coordinates.
    tiledAnchors = generateTiledAnchorsComplexYolov4(gatheredPredictions(:,2:5),anchors);
    gatheredPredictions(:,2:5) = applyAnchorBoxOffsetsComplexYolov4(tiledAnchors,gatheredPredictions(:,2:5),inputImageSize);
    
    % Generate targets for predictions from the ground truth data.
    [boxTarget,objectnessTarget,classTarget,objectMaskTarget,boxErrorScale] = generateComplexYOLOv4Targets(gatheredPredictions,YTrain,inputImageSize,anchors,penaltyThreshold);
    
    % Compute the loss.
    boxLoss = bboxOffsetLoss(YPredCell(:,[2 3 9 10 6 7]),boxTarget,objectMaskTarget,boxErrorScale);
    objLoss = objectnessLoss(YPredCell(:,1),objectnessTarget,objectMaskTarget);
    clsLoss = classConfidenceLoss(YPredCell(:,8),classTarget,objectMaskTarget);
    totalLoss = boxLoss + objLoss + clsLoss;
    
    info.boxLoss = boxLoss;
    info.objLoss = objLoss;
    info.clsLoss = clsLoss;
    info.totalLoss = totalLoss;
    
    % Compute the gradients of learnables with regard to the loss.
    gradients = dlgradient(totalLoss,net.Learnables);
end

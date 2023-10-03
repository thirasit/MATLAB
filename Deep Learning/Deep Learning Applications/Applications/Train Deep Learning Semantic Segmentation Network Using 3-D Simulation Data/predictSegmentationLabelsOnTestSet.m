% The helper function predictSegmentationLabelsOnTestSet calculates the confusion matrix of the predicted and ground truth labels using the segmentationConfusionMatrix (Computer Vision Toolbox) function.
function confusionMatrix =  predictSegmentationLabelsOnTestSet(net, minbatchTestData)   
    
confusionMatrix = {};
i = 1;
while hasdata(minbatchTestData)
    
    % Use next to retrieve a mini-batch from the datastore.
    [dlX, gtlabels] = next(minbatchTestData);
    
    % Predict the output of the network.
    [genPrediction, ~] = forward(net,dlX);
    
    % Get the label, which is the index with maximum value in the channel dimension.
    [~, labels] = max(genPrediction,[],3);
    
    % Get the confusion matrix of each image.
    confusionMatrix{i}  = segmentationConfusionMatrix(double(gather(extractdata(labels))),double(gather(extractdata(gtlabels))));
  
    i = i+1;
end

confusionMatrix = confusionMatrix';
    
end
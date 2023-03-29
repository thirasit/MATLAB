%%% Supporting Functions
% The createAnomalyScoreMap helper function creates an anomaly score map for each image with embeddings vectors specified by XEmbeddings. The createAnomalyScoreMap function reshapes and resizes the anomaly score map to match the size and resolution of the original input images.
function anomalyScoreMap = createAnomalyScoreMap(distances,H,W,B,targetImageSize)
    anomalyScoreMap = reshape(distances,[H W 1 B]);
    anomalyScoreMap = imresize(anomalyScoreMap,targetImageSize,"bilinear");
    for mIdx = 1:size(anomalyScoreMap,4)
        anomalyScoreMap(:,:,1,mIdx) = imgaussfilt(anomalyScoreMap(:,:,1,mIdx),4,FilterSize=33);
    end
end
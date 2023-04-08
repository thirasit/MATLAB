%%% Supporting Functions
%%% Calculate Gram Matrix
% The calculateGramMatrix helper function is used by the styleLoss helper function to calculate the Gram matrix of a feature map.
function gramMatrix = calculateGramMatrix(featureMap)
    [H,W,C] = size(featureMap);
    reshapedFeatures = reshape(featureMap,H*W,C);
    gramMatrix = reshapedFeatures' * reshapedFeatures;
end
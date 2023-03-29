%%% Supporting Functions
% The concatenateEmbeddings helper function combines features extracted from three layers of ResNet-18 into one feature embedding vector. The features from the second and third blocks of ResNet-18 are resized to match the spatial resolution of the first block.
function XEmbeddings = concatenateEmbeddings(XFeatures1,XFeatures2,XFeatures3)
    XFeatures2Resize = imresize(XFeatures2,2,"nearest");
    XFeatures3Resize = imresize(XFeatures3,4,"nearest");
    XEmbeddings = cat(3,XFeatures1,XFeatures2Resize,XFeatures3Resize);
end
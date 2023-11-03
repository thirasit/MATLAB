%% Supporting Functions
% The buildEncoderBlock helper function defines the layers of a single encoder module within the encoder subnetwork.
function block = buildEncoderBlock(blockIdx,numChannelsEncoder)

    if blockIdx < 2
        instanceNorm = [];
    else
        instanceNorm = instanceNormalizationLayer;
    end
    
    filterSize = 3;
    numFilters = numChannelsEncoder(blockIdx);
    block = [
        convolution2dLayer(filterSize,numFilters,Padding="same", ...
            PaddingValue="replicate",WeightsInitializer="he")
        instanceNorm
        leakyReluLayer(0.2)
        convolution2dLayer(filterSize,numFilters,Padding="same", ...
            PaddingValue="replicate",WeightsInitializer="he")
        instanceNorm
        leakyReluLayer(0.2)
        maxPooling2dLayer(2,Stride=2,Padding="same")];
end
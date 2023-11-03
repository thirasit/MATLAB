%% Supporting Functions
% The buildDecoderBlock helper function defines the layers of a single encoder module within the decoder subnetwork.
function block = buildDecoderBlock(blockIdx,numChannelsDecoder)

    if blockIdx < 4
        instanceNorm = instanceNormalizationLayer;
    else
        instanceNorm = [];
    end
    
    filterSize = 3;
    numFilters = numChannelsDecoder(blockIdx);
    block = [
        transposedConv2dLayer(filterSize,numFilters,Stride=2, ...
            WeightsInitializer="he",Cropping="same")
        convolution2dLayer(filterSize,numFilters,Padding="same", ...
            PaddingValue="replicate",WeightsInitializer="he")
        instanceNorm
        leakyReluLayer(0.2)
        convolution2dLayer(filterSize,numFilters,Padding="same", ...
            PaddingValue="replicate",WeightsInitializer="he")
        instanceNorm
        leakyReluLayer(0.2)];
end
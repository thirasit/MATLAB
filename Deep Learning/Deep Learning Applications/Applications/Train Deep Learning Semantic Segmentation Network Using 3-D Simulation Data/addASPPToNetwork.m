% The helper function addASPPToNetwork creates the atrous spatial pyramid pooling (ASPP) layers and adds them to the input layer graph.
% The function returns the layer graph with ASPP layers connected to it.
function lgraph  = addASPPToNetwork(lgraph, numClasses)

% Define the ASPP dilation factors.
asppDilationFactors = [6,12];

% Define the ASPP filter sizes.
asppFilterSizes = [3,3];

% Extract the last layer of the layer graph.
lastLayerName = lgraph.Layers(end).Name;

% Define the addition layer.
addLayer = additionLayer(numel(asppDilationFactors),'Name','additionLayer');

% Add the addition layer to the layer graph.
lgraph = addLayers(lgraph,addLayer);

% Create the ASPP layers connected to the addition layer
% and connect the layer graph.
for i = 1: numel(asppDilationFactors)
    asppConvName = "asppConv_" + string(i);
    branchFilterSize = asppFilterSizes(i);
    branchDilationFactor = asppDilationFactors(i);
    asspLayer  = convolution2dLayer(branchFilterSize, numClasses,'DilationFactor', branchDilationFactor,...
        'Padding','same','Name',asppConvName,'WeightsInitializer','narrow-normal','BiasInitializer','zeros');
    lgraph = addLayers(lgraph,asspLayer);
    lgraph = connectLayers(lgraph,lastLayerName,asppConvName);
    lgraph = connectLayers(lgraph,asppConvName,strcat(addLayer.Name,'/',addLayer.InputNames{i}));
end
end

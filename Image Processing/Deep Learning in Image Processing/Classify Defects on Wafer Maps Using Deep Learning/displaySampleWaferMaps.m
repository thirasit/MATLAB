function displaySampleWaferMaps(inData)
% displaySampleWaferMaps displays one sample image from each class

% Copyright 2021, The MathWorks, Inc.

    labels = cellstr(categories(inData.FailureType));
    
    figure
    tiledlayout(3,3,TileSpacing="tight")
    
    for cnt = 1:numel(labels)
        label = labels(cnt);
        idx = find(inData.FailureType == label);
        sampleImage = inData.WaferImage{idx(1)};

        nexttile
        imshow(sampleImage,[0 2])
        title(label)
    end
    
end
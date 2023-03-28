function outData = oversampleWaferDefectClasses(inData)
% oversampleWaferDefectClasses augments the input images with defects by
% performing flips (horizontal and vertical) and rotations (90, 180, 270).

% Copyright 2021, The MathWorks, Inc.

    % Start with the complete original data set
    outData = inData;

    % Create a copy of the data set that omits the non-defective class images
    inData( inData.FailureType == "none", :) = [];

    defectClasses = categories(inData.FailureType)';
    for d = defectClasses
        % Extract images of a specific defect type
        dimages = inData(inData.FailureType == d, :);
        dimages = performAugmentation(dimages);
        % Append the augmented images to the data set
        outData = [outData; dimages];
    end
end

function outData = performAugmentation(inputData)

    outData = table();

    ads = arrayDatastore(inputData,OutputType="same");

    % Flip UD
    tds = transform(ads, @(x) dataAugmentFunc(x, "ud"));
    out = readall(tds);
    outData = [outData; out];

    % Flip LR
    tds = transform(ads, @(x) dataAugmentFunc(x, "lr"));
    out = readall(tds);
    outData = [outData; out];

    % Rotate
    for theta = 90:90:270
        tds = transform(ads, @(x) dataAugmentFunc(x, "rot", theta));
        out = readall(tds);
        outData = [outData; out];
    end
end

function out = dataAugmentFunc(in, type, theta)

    out = in;
    switch(type)
        case "ud"
            out.WaferImage{1} = flipud(in.WaferImage{1}); 
        case "lr"
            out.WaferImage{1} = fliplr(in.WaferImage{1}); 
        case "rot"
            out.WaferImage{1} = imrotate(in.WaferImage{1}, theta, "loose"); 
    end
end
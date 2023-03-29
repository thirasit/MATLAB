function displayGeneratedLD2HDCTImages(mbq,imageAxes, ...
    generatorLowDoseToHighDose,generatorHighDoseToLowDose)
% displayGeneratedLD2HDCTImages Displays generated HDCT images
% from LDCT images.

%   Copyright 2021 The MathWorks, Inc.

% Read validation data
if hasdata(mbq) == 0
    reset(mbq);
    shuffle(mbq);
end

% Read mini-batch of data
[imageLowDose,imageHighDose] = next(mbq);

% Convert mini-batch of data to dlarray and specify the dimension labels
% 'SSCB' (spatial, spatial, channel, batch).
imageLowDose = dlarray(imageLowDose,'SSCB');
imageHighDose = dlarray(imageHighDose,'SSCB');

% If training on a GPU, then convert data to gpuArray.
if canUseGPU
    imageLowDose = gpuArray(imageLowDose);
    imageHighDose = gpuArray(imageHighDose);
end

% Generate images using the held-out generator input.
imageHighDoseGenerated = predict(generatorLowDoseToHighDose,imageLowDose);
imageLowDoseGenerated = predict(generatorHighDoseToLowDose,imageHighDose);

% Display the real and translated images.
imageResultsLD2HD = cat(2,imageLowDose,imageHighDoseGenerated);
imageResultsHD2LD = cat(2,imageHighDose,imageLowDoseGenerated);
imageResults = extractdata(cat(1,imageResultsLD2HD,imageResultsHD2LD));

imshow(imageResults(:,:,:,1),[],'Parent',imageAxes)
title(imageAxes, "Real (Left) and Generated (Right) Images");

drawnow;

end
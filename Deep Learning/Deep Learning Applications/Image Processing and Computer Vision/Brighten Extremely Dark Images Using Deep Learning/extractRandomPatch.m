%% Supporting Functions
% The extractRandomPatch helper function crops multiple random patches from a planar RAW image and corresponding patches from an RGB image.
% The RAW data patch has size m-by-n-by-4 and the RGB image patch has size 2m-by-2n-by-3, where [m n] is the value of the targetRAWSize input argument.
% Both patches have the same scene content.
function dataOut = extractRandomPatch(data,targetRAWSize,patchesPerImage)
    dataOut = cell(patchesPerImage,2);
    raw = data{1};
    rgb = data{2};
    for idx = 1:patchesPerImage
        windowRAW = randomCropWindow3d(size(raw),targetRAWSize);
        windowRGB = images.spatialref.Rectangle( ...
            2*windowRAW.XLimits+[-1,0],2*windowRAW.YLimits+[-1,0]);
        dataOut(idx,:) = {imcrop3(raw,windowRAW),imcrop(rgb,windowRGB)};
    end
end

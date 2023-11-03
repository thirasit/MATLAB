%% Supporting Functions
% The extractCenterPatch helper function crops a single patch from the center of a planar RAW image and the corresponding patch from an RGB image.
% The RAW data patch has size m-by-n-by-4 and the RGB image patch has size 2m-by-2n-by-3, where [m n] is the value of the targetRAWSize input argument.
% Both patches have the same scene content.
function dataOut = extractCenterPatch(data,targetRAWSize)
    raw = data{1};
    rgb = data{2};
    windowRAW = centerCropWindow3d(size(raw),targetRAWSize);
    windowRGB = images.spatialref.Rectangle( ...
        2*windowRAW.XLimits+[-1,0],2*windowRAW.YLimits+[-1,0]);
    dataOut = {imcrop3(raw,windowRAW),imcrop(rgb,windowRGB)};
end
function dataOut = augmentPatchesForLowLightRecovery(dataIn)
% The augmentPatchesForLowLightRecovery function randomly applies vertical
% and horizontal reflections with 50% probability each, and performs
% rotation by random multiples of 90 degrees.
%
% Copyright 2021 The MathWorks, Inc.

patchesPerImage = size(dataIn,1);
dataOut = cell(patchesPerImage,2);

for idx = 1:patchesPerImage
    raw = dataIn{idx,1};
    rgb = dataIn{idx,2};
    
    if rand > 0.5
        raw = fliplr(raw);
        rgb = fliplr(rgb);
    end
    
    if rand > 0.5
        raw = flipud(raw);
        rgb = flipud(rgb);    
    end
    
    randRot = randi(4)-1;
    dataOut(idx,1) = {rot90(raw,randRot)};
    dataOut(idx,2) = {rot90(rgb,randRot)};
    
end 
end

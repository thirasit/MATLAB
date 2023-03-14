function [patchData,patchLabel] = createImagePatchesFromHypercube(hcube, ...
    groundTruthLabel,winSize)

padding = floor((winSize-1)/2);
zeroPaddingPatch = padarray(hcube,[padding,padding],0,'both');

[rows,cols,ch] = size(hcube);
patchData = zeros(rows*cols,winSize,winSize,ch);
patchLabel = zeros(rows*cols,1);
zeroPaddedInput = size(zeroPaddingPatch);
patchIdx = 1;
for i= (padding+1):(zeroPaddedInput(1)-padding)
    for j= (padding+1):(zeroPaddedInput(2)-padding)
        patch = zeroPaddingPatch(i-padding:i+padding,j-padding:j+padding,:);
        patchData(patchIdx,:,:,:) = patch;
        patchLabel(patchIdx,1) = groundTruthLabel(i-padding,j-padding);
        patchIdx = patchIdx+1;
    end
end

end
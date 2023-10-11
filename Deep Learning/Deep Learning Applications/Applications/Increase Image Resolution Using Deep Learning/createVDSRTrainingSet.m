% Copyright 2018 The MathWorks, Inc.

function createVDSRTrainingSet(imds,scaleFactors,upsampledDirName,residualDirName)

if ~isfolder(residualDirName)
    mkdir(residualDirName);
end
    
if ~isfolder(upsampledDirName)
    mkdir(upsampledDirName);
end

while hasdata(imds)
    % Use only the luminance component for training
    [I,info] = read(imds);
    [~,fileName,~] = fileparts(info.Filename);
    
    I = rgb2ycbcr(I);
    Y = I(:,:,1);
    I = im2double(Y);
    
    % Randomly apply one value from scaleFactor
    if isvector(scaleFactors)
        scaleFactor = scaleFactors(randi([1 numel(scaleFactors)],1));
    else
        scaleFactor = scaleFactors;
    end
    
    upsampledImage = imresize(imresize(I,1/scaleFactor,"bicubic"),[size(I,1) size(I,2)],"bicubic");
    
    residualImage = I-upsampledImage;
    
    save(residualDirName+filesep+fileName+".mat","residualImage");
    save(upsampledDirName+filesep+fileName+".mat","upsampledImage");
    
end

end
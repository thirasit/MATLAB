% Copyright 2018 The MathWorks, Inc.

function bilateralFilterDataset(imds,preprocessDataDir)

if ~isfolder(preprocessDataDir)
    mkdir(preprocessDataDir);
end

reset(imds)
while hasdata(imds)
   
    [I,info] = read(imds);
    [~,fileName,fileExtn] = fileparts(info.Filename);
    
    degreeOfSmoothing = var(double(I(:)));
    Ifiltered = imbilatfilt(I,degreeOfSmoothing);
    
    imwrite(Ifiltered,preprocessDataDir+filesep+fileName+fileExtn);
    
end

end
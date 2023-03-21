function downloadLandsat8Dataset(url,destination)
% downloadLandsat8Dataset(_) downloads the LC08_L1TP_113082_20211206_20211206_01_RT
% Landsat 8 dataset
%
% This is a helper function for example purposes and may be removed or modified in the future.
%
% Copyright 2021 The MathWorks, Inc.

fileName = "LC08_L1TP_113082_20211206_20211206_01_RT.zip";
datasetDirFullPath = destination;
datasetFileFullPath = fullfile(destination,fileName);

if ~exist(datasetFileFullPath,"file")
    fprintf("Downloading the Landsat 8 OLI dataset.\n");
    fprintf("This can take several minutes to download...\n");
    if ~exist(datasetDirFullPath,"dir")
        mkdir(datasetDirFullPath);
    end
    websave(datasetFileFullPath,url);
    unzip(fileName,pwd)
    fprintf("Done.\n\n");
else
    fprintf("Landsat 8 OLI dataset already exists.\n\n");
end

end
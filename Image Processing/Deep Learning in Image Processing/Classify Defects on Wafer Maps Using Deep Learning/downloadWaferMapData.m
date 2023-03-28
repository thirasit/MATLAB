function downloadWaferMapData(dataDir)
% downloadWaferMapData downloads the MIR Wafer Map data set.
%
% References 
% ---------- 
% [1] Wu, Ming-Ju, Jyh-Shing R. Jang, and Jui-Long Chen. “Wafer Map Failure
% Pattern Recognition and Similarity Ranking for Large-Scale Data Sets.” 
% IEEE Transactions on Semiconductor Manufacturing 28, no. 1 (February 
% 2015): 1–12. https://doi.org/10.1109/TSM.2014.2364237. 
% [2] Jang, Roger. "MIR Corpora." http://mirlab.org/dataset/public/.

% Copyright 2021 The MathWorks, Inc.

if ~exist(dataDir,"dir")   
    mkdir(dataDir)
end

dataURL = "http://mirlab.org/dataSet/public/MIR-WM811K.zip";
dataMatFile = fullfile(dataDir,"MIR-WM811K","MATLAB","WM811K.mat");

% If the MAT file already exists, there is no need to download it again
if exist(dataMatFile,"file") ~= 2
    disp("Downloading MIR Wafer Map data set.");
    disp("This can take several minutes to download and unzip...");
    unzip(dataURL,dataDir);
    disp("Done.");
end

end
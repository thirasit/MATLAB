function downloadPillQCData(dataDir)
% downloadPillQCData downloads the Pill QC data set.

% Copyright 2021 The MathWorks, Inc.

if ~exist(dataDir,"dir")   
    mkdir(dataDir);
end

imageDir = fullfile(dataDir,"/pillQC-main");

if ~exist(imageDir,"dir")
disp("Downloading Pill QC data set.");
disp("This can take several minutes to download and unzip...");
unzip("https://github.com/matlab-deep-learning/pillQC/archive/refs/heads/main.zip",dataDir);
delete(fullfile(imageDir,"*.m"),fullfile(imageDir,"*.mlx"),fullfile(imageDir,"*.mat"),fullfile(imageDir,"*.md")); 
disp("Done.");
end

end

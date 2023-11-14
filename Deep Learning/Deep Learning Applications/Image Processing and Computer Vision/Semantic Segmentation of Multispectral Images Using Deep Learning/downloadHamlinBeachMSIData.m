function downloadHamlinBeachMSIData(destination)
% DOWNLOADHAMLINBEACHMSIDATA Helper function to download the labeled Hamlin 
% beach multispectral dataset
%
%  "https://home.cis.rit.edu/~cnspci/other/data/rit18_data.mat"
%
% References 
% ---------- 
%
% Ronald Kemker, Carl Salvaggio & Christopher Kanan (2017). High-Resolution 
% Multispectral Dataset for Semantic Segmentation. CoRR, abs/1703.01918.

%   Copyright 2017-2023 The MathWorks, Inc.

url = "https://home.cis.rit.edu/~cnspci/other/data/rit18_data.mat";
filename = "rit18_data.mat";
imageFileFullPath = fullfile(destination,filename);

if ~exist(imageFileFullPath,"file")
    fprintf("Downloading Hamlin Beach data set...\n");
    fprintf("This will take several minutes to download...\n");
    mkdir(destination);
    websave(imageFileFullPath,url);
    fprintf("Done.\n\n");
end
end
function downloadCamVidImageData(dataDir)
% The downloadCamVidImageData function downloads the CamVid image data set
% and saves it into the directory specified by dataDir.
%
% Copyright 2020 The MathWorks, Inc.

imageURL = "http://web4.cs.ucl.ac.uk/staff/g.brostow/MotionSegRecData/files/701_StillsRaw_full.zip";

if ~exist(dataDir,"dir")   
    mkdir(dataDir)
    imagesZip = fullfile(dataDir,"images.zip");   
    
    disp("Downloading 557 MB CamVid data set images...");  
    websave(imagesZip,imageURL);       
    unzip(imagesZip,fullfile(dataDir,"images")); 
    fprintf("Done.\n\n");
end
end
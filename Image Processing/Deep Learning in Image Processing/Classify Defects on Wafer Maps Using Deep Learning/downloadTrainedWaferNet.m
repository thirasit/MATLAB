function downloadTrainedWaferNet(destination)
% The downloadTrainedWaferNet function downloads the pretrained 
% wafer defect classification network.
%
% Copyright 2021 The MathWorks, Inc.

    url = "https://ssd.mathworks.com/supportfiles/image/data/trainedWM811KCNN.zip";
    [~,name,~] = fileparts(url);
    
    netDirFullPath = destination;
    netZipFileFullPath = fullfile(destination,name+".zip");
    netMATFileFullPath = fullfile(destination,"CNN-WM811K.mat");    

    if ~exist(netMATFileFullPath,"file")
        if ~exist(netZipFileFullPath,"file")
            disp("Downloading pretrained wafer defect classification network.");
            disp("This can take several minutes to download...");
            if ~exist(netDirFullPath,"dir")
                mkdir(netDirFullPath);
            end
            websave(netZipFileFullPath,url);
            disp("Done.");
        end
        unzip(netZipFileFullPath,netDirFullPath)
    end

end
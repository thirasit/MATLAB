function preprocessBraTSDataset(destination,source)
% Crop the data set to a region containing primarily the brain and tumor.
% Then, normalize each modality of the 4-D volumetric series independently
% by subtracting the mean and dividing by the standard deviation of the
% cropped brain region. Finally, split the data set into training, 
% validation and test sets.
%
% Copyright 2019 The MathWorks, Inc.

%% Load data
volLoc = source+filesep+"imagesTr";
lblLoc = source+filesep+"labelsTr";
if ~exist(volLoc,'dir') || ~exist(lblLoc,'dir')
    error("Please unzip Task01_BrainTumour.tar file to "+source)
end
moveHiddenFiles(source,volLoc,lblLoc);

% If the directories for preprocessed data does not exist, create the
% directories
if ~exist(destination,'dir')
    mkdir(fullfile(destination,'imagesTr'));
    mkdir(fullfile(destination,'labelsTr'));
    
    mkdir(fullfile(destination,'imagesVal'));
    mkdir(fullfile(destination,'labelsVal'));
    
    mkdir(fullfile(destination,'imagesTest'));
    mkdir(fullfile(destination,'labelsTest'));   
end 

classNames = ["background","tumor"];
pixelLabelID = [0 1];

% If none or only a partial set of the data files have been processed,
% process the data.
if proceedWithPreprocessing(destination)
    labelReader = @(x) (niftiread(x) > 0);
    volReader = @(x) niftiread(x);
    volds = imageDatastore(volLoc, ...
        'FileExtensions','.gz','ReadFcn',volReader);
    pxds = pixelLabelDatastore(lblLoc,classNames, pixelLabelID, ...
        'FileExtensions','.gz','ReadFcn',labelReader);
    reset(volds);
    reset(pxds);
    
    %% Crop relevant region
    NumFiles = length(pxds.Files);
    id = 1;
    while hasdata(pxds)
        outL = readNumeric(pxds);
        outV = read(volds);
        temp = outL>0;
        sz = size(outL);
        reg = regionprops3(temp,'BoundingBox');
        tol = 132;
        ROI = ceil(reg.BoundingBox(1,:));
        ROIst = ROI(1:3) - tol;
        ROIend = ROI(1:3) + ROI(4:6) + tol;
        
        ROIst(ROIst<1)=1;
        ROIend(ROIend>sz)=sz(ROIend>sz);          
        
        tumorRows = ROIst(2):ROIend(2);
        tumorCols = ROIst(1):ROIend(1);
        tumorPlanes = ROIst(3):ROIend(3);
        
        tcropVol = outV(tumorRows,tumorCols, tumorPlanes,:);
        tcropLabel = outL(tumorRows,tumorCols, tumorPlanes);

        % Data set with a valid size for 3-D U-Net (multiple of 8).
        ind = floor(size(tcropVol)/8)*8;
        incropVol = tcropVol(1:ind(1),1:ind(2),1:ind(3),:);
        mask = incropVol == 0;
        cropVol = channelWisePreProcess(incropVol);
        
        % Set the nonbrain region to 0.
        cropVol(mask) = 0;
        cropLabel = tcropLabel(1:ind(1),1:ind(2),1:ind(3));
        
        % Split data into training, validation and test sets. Roughly 82%
        % are training, 6% are validation, and 12% are test.
        if (id < floor(0.83*NumFiles))
            imDir    = fullfile(destination,'imagesTr','BraTS');
            labelDir = fullfile(destination,'labelsTr','BraTS');
        elseif (id < floor(0.89*NumFiles))
            imDir    = fullfile(destination,'imagesVal','BraTS');
            labelDir = fullfile(destination,'labelsVal','BraTS');
        else
            imDir    = fullfile(destination,'imagesTest','BraTS');
            labelDir = fullfile(destination,'labelsTest','BraTS');
        end
        save(imDir+num2str(id,'%.3d')+".mat","cropVol");
        save(labelDir+num2str(id,'%.3d')+".mat","cropLabel");
        id=id+1;       
   end
end

end

function out = channelWisePreProcess(in)
% As input has 4 channels (modalities), remove the mean and divide by the
% standard deviation of each modality independently.
chn_Mean = mean(in,[1 2 3]);
chn_Std = std(in,0,[1 2 3]);
out = (in - chn_Mean)./chn_Std;

rangeMin = -5;
rangeMax = 5;

out(out > rangeMax) = rangeMax;
out(out < rangeMin) = rangeMin;

% Rescale the data to the range [0, 1].
out = (out - rangeMin) / (rangeMax - rangeMin);
end

function moveHiddenFiles(source,volLoc,lblLoc)
% The original data set includes hidden files whose filenames begin with
% "._". Move these files out of the training, test, and validation data
% directories.
myLoc = pwd;
hiddenDir = fullfile(source,'HiddenFiles');
if ~exist(hiddenDir,'dir')
    mkdir(hiddenDir);
    if ispc
        cd(volLoc);
        !move ._* ..\HiddenFiles\
        cd(lblLoc)
        !move ._* ..\HiddenFiles\
    else
        cd(volLoc);
        !mv ._* ../HiddenFiles/
        cd(lblLoc)
        !mv ._* ../HiddenFiles/
    end
end
cd(myLoc)
end

function out = proceedWithPreprocessing(destination)
totalNumFiles = 484;
numFiles = 0;
if exist(fullfile(destination,'imagesTr'),'dir')
    tmp1 = dir(fullfile(destination,'imagesTr'));
    numFiles = numFiles + sum(~vertcat(tmp1.isdir));
end

if exist(fullfile(destination,'imagesVal'),'dir')
    tmp1 = dir(fullfile(destination,'imagesVal'));
    numFiles = numFiles + sum(~vertcat(tmp1.isdir));
end

if exist(fullfile(destination,'imagesTest'),'dir')
    tmp1 = dir(fullfile(destination,'imagesTest'));
    numFiles = numFiles + sum(~vertcat(tmp1.isdir));
end

% If total number of preprocessed files is not equal to the number of
% files in the dataset, perform preprocessing. Otherwise, preprocessing has
% already been completed and can be skipped.
out = (numFiles ~= totalNumFiles);
end
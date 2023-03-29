function [dirListTrainLowDoseImages, dirListTrainFullDoseImages, ...
    dirListTestLowDoseImages, dirListTestFullDoseImages,...
    dirListValidationLowDoseImages, dirListValidationFullDoseImages] ...
    = createLDCTFolderList(ldctDir, maxDirsForABodyPart)
% createLDCTFolderList - Create a list of training, validation and test
% folders with low-dose and full-dose image pairs. Use only images from
% Chest (C) scans. Note: The images pairs are NOT from the
% same patient to ensure unsupervised training.

%   Copyright 2021 The MathWorks, Inc.

% Get a list of files and folders in any subfolder
filelist = dir(fullfile(ldctDir, '*',filesep,'*',filesep,'*'));

dirListFullDoseImages = {};
dirListLowDoseImages = {};
for idx = 1:numel(filelist)
    if contains(filelist(idx).name,'full dose images',IgnoreCase=true)
        dirListFullDoseImages = [dirListFullDoseImages; [filelist(idx).folder filesep filelist(idx).name]];
    elseif contains(filelist(idx).name,'low dose images',IgnoreCase=true)
        dirListLowDoseImages = [dirListLowDoseImages; [filelist(idx).folder filesep filelist(idx).name]];
    end
end

% Initialize the list of files for low-dose and high-dose training,
% validation, and testing
dirListTrainLowDoseImages = {};
dirListTrainFullDoseImages = {};

dirListTestLowDoseImages = {};
dirListTestFullDoseImages = {};

dirListValidationLowDoseImages = {};
dirListValidationFullDoseImages = {};

% Use only folders with C prefixes.
bodyPartPrefix = ["C"];

% Find the indices of Chest (C) scans
for idx = 1:numel(bodyPartPrefix)
    
    dirListFullDoseForABodyPart = dirListFullDoseImages(contains(dirListFullDoseImages,filesep+bodyPartPrefix(idx)+digitsPattern(3)+filesep));
    dirListLowDoseForABodyPart = dirListLowDoseImages(contains(dirListLowDoseImages,filesep+bodyPartPrefix(idx)+digitsPattern(3)+filesep));
    
    if ~isempty(dirListFullDoseForABodyPart)
        % Split the data into 80% for training, 15% for testing and 5% for validation.
        
        numDirsForABodyPart = numel(dirListFullDoseForABodyPart);
        numelValidationDirs = floor(numDirsForABodyPart*0.1);
        numelTrainDirs = floor(numDirsForABodyPart*0.80);
        numelTestDirs = numDirsForABodyPart-numelTrainDirs-numelValidationDirs;
        trainDirIndices = 1:numelTrainDirs;
        testDirIndices = trainDirIndices(end)+1:numDirsForABodyPart-numelValidationDirs;
        validationDirIndices = testDirIndices(end)+1:numDirsForABodyPart;
        
        % To ensure unsupervised learning, make sure that the training set
        % chooses full-dose and low-dose CT images from different patients.
        % Split the training data randomly into 2 parts and use the first
        % half to get full-dose images and the rest for low-dose images.
        trainDirIndices = randperm(numel(trainDirIndices));
        trainDirsLowDoseForABodyPart = dirListLowDoseForABodyPart(trainDirIndices(1:floor(numelTrainDirs/2)));
        trainDirsFullDoseForABodyPart = dirListFullDoseForABodyPart(trainDirIndices(floor(numelTrainDirs/2)+1:numelTrainDirs));
        
        % Restrict the number of training folders used based on maxDirsForABodyPart
        if numel(trainDirsLowDoseForABodyPart) > maxDirsForABodyPart
            trainDirsLowDoseForABodyPart = trainDirsLowDoseForABodyPart(1:maxDirsForABodyPart);
        end
        if numel(trainDirsFullDoseForABodyPart) > maxDirsForABodyPart
            trainDirsFullDoseForABodyPart = trainDirsFullDoseForABodyPart(1:maxDirsForABodyPart);
        end
        
        dirListTrainLowDoseImages = [dirListTrainLowDoseImages; trainDirsLowDoseForABodyPart];
        dirListTrainFullDoseImages = [dirListTrainFullDoseImages; trainDirsFullDoseForABodyPart];
        
        % Do the same for validation set
        dirListValidationLowDoseImages = [dirListValidationLowDoseImages; dirListLowDoseForABodyPart(validationDirIndices(1:floor(numelValidationDirs/2)))];
        dirListValidationFullDoseImages = [dirListValidationFullDoseImages; dirListFullDoseForABodyPart(validationDirIndices(floor(numelValidationDirs/2)+1:numelValidationDirs))];
        
        dirListTestLowDoseImages = [dirListTestLowDoseImages; dirListLowDoseForABodyPart(testDirIndices)];
        dirListTestFullDoseImages = [dirListTestFullDoseImages; dirListFullDoseForABodyPart(testDirIndices)];
    end
        
end

end

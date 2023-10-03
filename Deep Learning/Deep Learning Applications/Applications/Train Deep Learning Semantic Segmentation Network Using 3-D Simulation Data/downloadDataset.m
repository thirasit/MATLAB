% The helper function downloadDataset downloads both the simulation and real data sets from the specified URLs to the specified folder locations if they do not exist.
% The function returns the paths of the simulation, real training data, and real testing data.
% The function downloads the entire CamVid data set and partition the data into training and test sets using the subsetCamVidDatasetFileNames mat file, attached to the example as a supporting file.
function [simulationImagesFolder, simulationLabelsFolder, realImagesFolder, realLabelsFolder,...
    realTestImagesFolder, realTestLabelsFolder] = ...
    downloadDataset(simulationDataLocation, simulationDataURL, realDataLocation, realImageDataURL, realLabelDataURL)
    
% Build the training image and label folder location for simulation data.
simulationDataZip = fullfile(simulationDataLocation,'SimulationDrivingDataset.zip');

% Get the simulation data if it does not exist.
if ~exist(simulationDataZip,'file')
    mkdir(simulationDataLocation)
    
    disp('Downloading the simulation data');
    websave(simulationDataZip,simulationDataURL);
    unzip(simulationDataZip,simulationDataLocation);
end
  
simulationImagesFolder = fullfile(simulationDataLocation,'SimulationDrivingDataset','images');
simulationLabelsFolder = fullfile(simulationDataLocation,'SimulationDrivingDataset','labels');

camVidLabelsZip = fullfile(realDataLocation,'CamVidLabels.zip');
camVidImagesZip = fullfile(realDataLocation,'CamVidImages.zip');

if ~exist(camVidLabelsZip,'file') || ~exist(camVidImagesZip,'file')   
    mkdir(realDataLocation)
       
    disp('Downloading 16 MB CamVid dataset labels...'); 
    websave(camVidLabelsZip, realLabelDataURL);
    unzip(camVidLabelsZip, fullfile(realDataLocation,'CamVidLabels'));
    
    disp('Downloading 587 MB CamVid dataset images...');  
    websave(camVidImagesZip, realImageDataURL);       
    unzip(camVidImagesZip, fullfile(realDataLocation,'CamVidImages'));    
end

% Build the training image and label folder location for real data.
realImagesFolder = fullfile(realDataLocation,'train','images');
realLabelsFolder = fullfile(realDataLocation,'train','labels');

% Build the testing image and label folder location for real data.
realTestImagesFolder = fullfile(realDataLocation,'test','images');
realTestLabelsFolder = fullfile(realDataLocation,'test','labels');

% Partition the data into training and test sets if they do not exist.
if ~exist(realImagesFolder,'file') || ~exist(realLabelsFolder,'file') || ...
        ~exist(realTestImagesFolder,'file') || ~exist(realTestLabelsFolder,'file')

    
    mkdir(realImagesFolder);
    mkdir(realLabelsFolder);
    mkdir(realTestImagesFolder);
    mkdir(realTestLabelsFolder);
    
    % Load the mat file that has the names for testing and training.
    partitionNames = load('subsetCamVidDatasetFileNames.mat');
    
    % Extract the test images names.
    imageTestNames = partitionNames.imageTestNames;
    
    % Remove the empty cells. 
    imageTestNames = imageTestNames(~cellfun('isempty',imageTestNames));
    
    % Extract the test labels names.
    labelTestNames = partitionNames.labelTestNames;
    
    % Remove the empty cells.
    labelTestNames = labelTestNames(~cellfun('isempty',labelTestNames));
    
    % Copy the test images to the respective folder.
    for i = 1:size(imageTestNames,1)
        labelSource = fullfile(realDataLocation,'CamVidLabels',labelTestNames(i));
        imageSource = fullfile(realDataLocation,'CamVidImages','701_StillsRaw_full',imageTestNames(i));
        copyfile(imageSource{1}, realTestImagesFolder);
        copyfile(labelSource{1}, realTestLabelsFolder);
    end
    
    % Extract the train images names.
    imageTrainNames = partitionNames.imageTrainNames;
    
    % Remove the empty cells.
    imageTrainNames = imageTrainNames(~cellfun('isempty',imageTrainNames));
    
    % Extract the train labels names.
    labelTrainNames = partitionNames.labelTrainNames;
    
    % Remove the empty cells.
    labelTrainNames = labelTrainNames(~cellfun('isempty',labelTrainNames));
    
    % Copy the train images to the respective folder.
    for i = 1:size(imageTrainNames,1)
        labelSource = fullfile(realDataLocation,'CamVidLabels',labelTrainNames(i));
        imageSource = fullfile(realDataLocation,'CamVidImages','701_StillsRaw_full',imageTrainNames(i));
        copyfile(imageSource{1},realImagesFolder);
        copyfile(labelSource{1},realLabelsFolder);
    end
end
end

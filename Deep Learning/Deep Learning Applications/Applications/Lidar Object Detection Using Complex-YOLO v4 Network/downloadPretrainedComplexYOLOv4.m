function mdl = downloadPretrainedComplexYOLOv4(modelName)
% The downloadPretrainedYOLOv4 function downloads a Complex YOLO v4 network 
% pretrained on Pandaset dataset.
%
% Copyright 2021 The MathWorks, Inc.

supportedNetworks = ["complex-yolov4-pandaset", "tiny-complex-yolov4-pandaset"];
validatestring(modelName, supportedNetworks);

% Download the pretrained model.
dataPath = 'models';
filename = matlab.internal.examples.downloadSupportFile('lidar','data/complex-yolov4-models-master.zip');
unzip(filename,dataPath);

% Extract the model.
netFileFullPath = fullfile(dataPath,'complex-yolov4-models-master','models',modelName,[modelName '.mat']);
if ~exist(netFileFullPath,'file')
    netFileZipPath = fullfile(dataPath,'complex-yolov4-models-master','models',[modelName '.zip']);
    unzip(netFileZipPath,fullfile(dataPath,'complex-yolov4-models-master','models'));
    model = load(netFileFullPath);
else
    model = load(netFileFullPath);
end

anchors = model.anchorBoxes;
anchorBoxMasks = model.anchorBoxMasks;
anchorBoxes = cell(size(anchorBoxMasks));
for i = 1:size(anchorBoxMasks,1)
    anchorBoxes{i} = anchors(anchorBoxMasks{i},:);
end

mdl.net = model.net;
mdl.anchorBoxes = anchorBoxes;

end

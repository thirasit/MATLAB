function downloadBraTSSampleTestData(destination)
% Download the pretrained 3-D U-Net network and sample test volume and
% label data.
%
% Copyright 2019 The MathWorks, Inc.

sampledata_url = "https://www.mathworks.com/supportfiles/vision/data/sampleBraTSTestSetValid.tar.gz";
imageDataLocation = fullfile(destination,'sampleBraTSTestSetValid');
if ~exist(imageDataLocation, 'dir')
    fprintf('Downloading sample BraTS test data set.\n');
    fprintf('This will take several minutes to download and unzip...\n');
    untar(sampledata_url,destination);
    fprintf('Done.\n\n');
end
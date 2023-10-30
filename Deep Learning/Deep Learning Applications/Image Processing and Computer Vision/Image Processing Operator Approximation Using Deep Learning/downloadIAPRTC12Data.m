function downloadIAPRTC12Data(destination)
% DOWNLOADIAPRTC12DATA Helper function to download the IAPR TC-12 Benchmark
% dataset. The dataset is downloaded from:
%
%  http://www-i6.informatik.rwth-aachen.de/imageclef/resources/iaprtc12.tgz
%
% References 
% ---------- 
%
% Grubinger, Michael, Paul Clough, Henning Müller, and Thomas Deselaers.
% "The IAPR TC-12 Benchmark: A new evaluation resource for visual
% information systems." In International workshop ontoImage, vol. 5, p. 10.
% 2006.

%   Copyright 2017 The MathWorks, Inc.

url = "http://www-i6.informatik.rwth-aachen.de/imageclef/resources/iaprtc12.tgz";

imageDataLocation = fullfile(destination,"iaprtc12");
if ~exist(imageDataLocation,"dir")
    fprintf("Downloading IAPR TC-12 dataset...\n");
    fprintf("This will take several minutes to download and unzip...\n");
    try
        untar(url,destination);
    catch 
        % On some windows machines, the untar command errors for .tgz
        % files. Rename to .tg and try again.
        fileName = fullfile(tempdir,"iaprtc12.tg");
        websave(fileName,url);
        untar(fileName,destination);
    end
    fprintf("Done.\n\n");
end
end

function browseBlockedImages(bims, level)
%browserBlockedImages Browser an array of blockedImages
%
% browserBlockedImages(bims, level) launches the imageBrowser app with
% thumbnails created from the specified level.

% Copyright 2021 The MathWorks, Inc.

narginchk(2,2)
source = [bims.Source];
if isfolder(bims(1).Source)
    % Pick a file name instead to enable packing into an imageDatastore.
    source = source+filesep+"description.mat";
end

imds = imageDatastore(source, ...
    "FileExtensions",{'.tif','.mat'},...
    "ReadFcn", @gatherLevel);

imageBrowser(imds)

    function im = gatherLevel(source)
        if endsWith(source, '.mat')
            % Strip to source folder
            source = fileparts(source);
        end
        im = gather(blockedImage(source), "Level", level);
    end
end



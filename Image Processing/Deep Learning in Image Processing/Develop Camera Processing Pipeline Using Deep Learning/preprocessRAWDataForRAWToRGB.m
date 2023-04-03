function out = preprocessRAWDataForRAWToRGB(in)
% The preprocessRGBDataForRAWToRGB function converts RAW data from a Bayer pattern to
% a four-channel image. The function returns an array when the input data
% is an array, and the function returns a cell array when the input data is
% a cell array.

% Copyright 2021 The MathWorks, Inc.

    if ~iscell(in)
        out = packRAWImage(in);
    else
        out = cell(size(in));
        for idx = 1:size(in,1)
            out{idx} = packRAWImage(in{idx});
        end
    end
end

function out = packRAWImage(cfa)
% The packRAWImage function takes input CFA bayer pattern images and
% extracts blue, red, and two green channels from the bayer pattern and
% forms a H/2-by-W/2-by-4 image with each channel represented as a
% separate plane. The RAW counts are normalized to [0,1] according to
% the range of the 10-bit sensor.

% RGGB order
blue = cfa(2:2:end,2:2:end);
green1 = cfa(1:2:end,2:2:end);
red = cfa(1:2:end,1:2:end);
green2 = cfa(2:2:end,1:2:end);

rawCombined = cat(3,blue,green1,red,green2);
out = single(rawCombined) / (4*255); % 10-bit sensor
end

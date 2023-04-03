function out = preprocessRGBDataForRAWToRGB(in)
% The preprocessRGBDataForRAWToRGB function converts data to data type
% single and rescales data to the range [0, 1].

% Copyright 2021 The MathWorks, Inc.

if iscell(in)
    out = cell(size(in));
    for idx = 1:size(in,1)
        out{idx} = single(in{idx})./255;
    end
else
    out = single(in)./255;
end

end
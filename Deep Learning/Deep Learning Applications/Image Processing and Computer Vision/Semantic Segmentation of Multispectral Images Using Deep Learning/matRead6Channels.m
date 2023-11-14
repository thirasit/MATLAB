% matRead6Channels reads a custom MAT files containing 6 channel
% multispectral image data.
%
%  IMAGE = matRead6Channels(FILENAME) returns the first 6 channels of the
%  multispectral image saved in FILENAME.

% Copyright 2017 The MathWorks, Inc.
function data = matRead6Channels(filename)

    d = load(filename);
    f = fields(d);
    data = d.(f{1})(:,:,1:6);
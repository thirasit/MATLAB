function writeBearingData(filename,data)
% Write data into the fileEnsembleDatastore
%
% Inputs:
% filename - a string of the file name to write
% data     - a data structure to write to the file

% Copyright 2017-2018 The MathWorks, Inc.

save(filename, '-append', '-struct', 'data');
end

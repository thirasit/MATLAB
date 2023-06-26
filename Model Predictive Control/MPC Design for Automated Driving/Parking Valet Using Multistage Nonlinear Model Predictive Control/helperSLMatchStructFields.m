function toObj = helperSLMatchStructFields(toObj, fromObj)
% This file is the same as in the "AutomatedParkingValetSimulinkExample".

%helperSLMatchStructFields assign field values for structs/objects.

% Copyright 2017-2019 The MathWorks, Inc.

fieldNames = fields(fromObj);
for n = 1 : numel(fieldNames)
    toObj.(fieldNames{n}) = fromObj.(fieldNames{n});
end
end

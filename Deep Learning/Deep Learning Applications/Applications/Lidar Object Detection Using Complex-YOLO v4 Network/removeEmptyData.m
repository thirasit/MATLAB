function [imdsProcessed,bdsProcessed] = removeEmptyData(imds,bds)
% Return non-empty indices from the saved data

% Copyright 2021 The MathWorks, Inc.

% Read labels from the box label datastore.
processedLabels = readall(bds);

% Get the non-empty indices.
indices = ~cellfun('isempty',processedLabels(:,1));

imdsProcessed = subset(imds,indices);
bdsProcessed = subset(bds,indices);

end
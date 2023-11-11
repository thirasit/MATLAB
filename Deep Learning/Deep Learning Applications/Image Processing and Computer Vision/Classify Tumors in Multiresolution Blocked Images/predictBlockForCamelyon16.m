function out = predictBlockForCamelyon16(blockStruct,trainedNet)
% The predictBlockForCamelyon16 function calls predict on the trained
% network to compute probability of each block block being "Tumor".

% Copyright 2021 The MathWorks, Inc.

probScores = predict(trainedNet,blockStruct.Data);
out = probScores(:,2);
out = out';

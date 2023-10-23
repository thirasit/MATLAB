function outputCell = resizeData(inputCell)
%RESIZEDATA Break input ECG signal and label mask into segments of length
%5000.
%
%   inputCell is a two-element cell array containing an ECG signal and a
%   label mask.
%
%   outputCell is a two-column cell array containing as many 5000-long
%   signal segments and label masks that were possible to generate from the
%   input data.

% Copyright 2019 The MathWorks, Inc.

    targetLength = 5000;
    sig = inputCell{1};
    mask = inputCell{2};
    
    % Get number of chunks
    numChunks = floor(size(sig,1)/targetLength);
    
    % Truncate signal and mask to integer number of chunks
    sig = sig(1:numChunks*targetLength);
    mask = mask(1:numChunks*targetLength);
    
    % Create a cell array containing signal chunks
    sigOut = reshape(sig,targetLength,numChunks)';
    sigOut = num2cell(sigOut,2);
    
    % Create a cell array containing mask chunks
    lblOut = reshape(mask,targetLength,numChunks)';
    lblOut = num2cell(lblOut,2);
    
    % Output a two-column cell array with all chunks
    outputCell = [sigOut, lblOut];

end
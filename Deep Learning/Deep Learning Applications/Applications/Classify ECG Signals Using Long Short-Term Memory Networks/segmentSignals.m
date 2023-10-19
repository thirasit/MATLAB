function [signalsOut, labelsOut] = segmentSignals(signalsIn,labelsIn)
%SEGMENTSIGNALS makes all signals in the input array 9000 samples long

% Copyright 2017 The MathWorks, Inc.

targetLength = 9000;
signalsOut = {};
labelsOut = {};

for idx = 1:numel(signalsIn)
    
    x = signalsIn{idx};
    y = labelsIn(idx);
    
    % Ensure column vector
    x = x(:);
    
    % Compute the number of targetLength-sample chunks in the signal
    numSigs = floor(length(x)/targetLength);
    
    if numSigs == 0
        continue;
    end
    
    % Truncate to a multiple of targetLength
    x = x(1:numSigs*targetLength);
        
    % Create a matrix with as many columns as targetLength signals
    M = reshape(x,targetLength,numSigs); 
    
    % Repeat the label numSigs times
    y = repmat(y,[numSigs,1]);
    
    % Vertically concatenate into cell arrays
    signalsOut = [signalsOut; mat2cell(M.',ones(numSigs,1))]; %#ok<AGROW>
    labelsOut = [labelsOut; cellstr(y)]; %#ok<AGROW>
end

labelsOut = categorical(labelsOut);

end
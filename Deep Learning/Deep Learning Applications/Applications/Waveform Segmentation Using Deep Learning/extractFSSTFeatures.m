function out = extractFSSTFeatures(inputCell,Fs)
%EXTRACTFSSTFEATURES Compute Fourier synchrosqueezed transform of input
%signals and normalize. 
%
%   inputCell is a two-column cell array containing ECG segments and label
%   masks for each segment.
%
%   outputCell is a two-column cell array containing FFST transform of each
%   ECG segment and the corresponding label masks. 

% Copyright 2019 The MathWorks, Inc.

sigs = inputCell(:,1);

%Initialize variables
signalsFsst = cell(size(sigs));
meanValue = cell(1,length(sigs));
stdValue = cell(1,length(sigs));

% Compute time-frequency maps
for idx = 1:length(sigs)
   [s,f,~] = fsst(sigs{idx},Fs,kaiser(128));
   
   f_indices = (f > 0.5) & (f < 40);
   signalsFsst{idx} = [real(s(f_indices,:)); imag(s(f_indices,:))];
   
   meanValue{idx} = mean(signalsFsst{idx},2);
   stdValue{idx} = std(signalsFsst{idx},[],2);
end

% Normalize time-frequency maps
standardizeFun = @(x) (x - mean(cell2mat(meanValue),2))./mean(cell2mat(stdValue),2);
signalsFsst = cellfun(standardizeFun,signalsFsst,'UniformOutput',false);

out = [signalsFsst inputCell(:,2)];
end
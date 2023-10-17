%%% Mini-Batch Preprocessing Function
% The preprocessMiniBatch function, described in the Train Model section of the example, preprocesses the data for training. The function preprocesses the data using the following steps:
% 1. Determine the lengths of all source and target sequences in the mini-batch
% 2. Pad the sequences to the same length as the longest sequence in the mini-batch using the padsequences function.
% 3. Permute the last two dimensions of the sequences
function [X,T,sequenceLengthsSource,maskTarget] = preprocessMiniBatch(sequencesSource,sequencesTarget,inputSize,outputSize)

sequenceLengthsSource = cellfun(@(x) size(x,2),sequencesSource);

X = padsequences(sequencesSource,2,PaddingValue=inputSize);
X = permute(X,[1 3 2]);

[T,maskTarget] = padsequences(sequencesTarget,2,PaddingValue=outputSize);
T = permute(T,[1 3 2]);
maskTarget = permute(maskTarget,[1 3 2]);

end

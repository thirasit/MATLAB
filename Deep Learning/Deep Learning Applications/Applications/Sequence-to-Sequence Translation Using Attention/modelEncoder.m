%%% Encoder Model Function
% The function modelEncoder takes the input data, the model parameters, the optional mask that is used to determine the correct outputs for training and returns the model output and the LSTM hidden state.

% If sequenceLengths is empty, then the function does not mask the output.
% Specify and empty value for sequenceLengths when using the modelEncoder function for prediction.
function [Z,hiddenState] = modelEncoder(parameters,X,sequenceLengths)

% Embedding.
weights = parameters.emb.Weights;
Z = embed(X,weights,DataFormat="CBT");

% LSTM.
inputWeights = parameters.lstm.InputWeights;
recurrentWeights = parameters.lstm.RecurrentWeights;
bias = parameters.lstm.Bias;

numHiddenUnits = size(recurrentWeights, 2);
initialHiddenState = dlarray(zeros([numHiddenUnits 1]));
initialCellState = dlarray(zeros([numHiddenUnits 1]));

[Z,hiddenState] = lstm(Z,initialHiddenState,initialCellState,inputWeights, ...
    recurrentWeights,bias,DataFormat="CBT");

% Masking for training.
if ~isempty(sequenceLengths)
    miniBatchSize = size(Z,2);
    for n = 1:miniBatchSize
        hiddenState(:,n) = Z(:,n,sequenceLengths(n));
    end
end

end

%%% Decoder Model Predictions Function
% The decoderModelPredictions function returns the predicted sequence Y given the input sequence, target sequence, hidden state, dropout probability, flag to enable teacher forcing, and the sequence length.
function Y = decoderPredictions(parameters,Z,T,hiddenState,dropout, ...
    doTeacherForcing,sequenceLength)

% Convert to dlarray.
T = dlarray(T);

% Initialize context.
miniBatchSize = size(T,2);
numHiddenUnits = size(Z,1);
context = zeros([numHiddenUnits miniBatchSize],"like",Z);

if doTeacherForcing
    % Forward through decoder.
    Y = modelDecoder(parameters,T,context,hiddenState,Z,dropout);
else
    % Get first time step for decoder.
    decoderInput = T(:,:,1);

    % Initialize output.
    numClasses = numel(parameters.fc.Bias);
    Y = zeros([numClasses miniBatchSize sequenceLength],"like",decoderInput);

    % Loop over time steps.
    for t = 1:sequenceLength
        % Forward through decoder.
        [Y(:,:,t), context, hiddenState] = modelDecoder(parameters,decoderInput,context, ...
            hiddenState,Z,dropout);

        % Update decoder input.
        [~, decoderInput] = max(Y(:,:,t),[],1);
    end
end

end

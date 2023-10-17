%% Sequence-to-Sequence Translation Using Attention
% This example shows how to convert decimal strings to Roman numerals using a recurrent sequence-to-sequence encoder-decoder model with attention.

% Recurrent encoder-decoder models have proven successful at tasks like abstractive text summarization and neural machine translation.
% The model consists of an encoder which typically processes input data with a recurrent layer such as LSTM, and a decoder which maps the encoded input into the desired output, typically with a second recurrent layer.
% Models that incorporate attention mechanisms into the models allows the decoder to focus on parts of the encoded input while generating the translation.
figure
imshow("SequencetoSequenceTranslationUsingAttentionExample_01.png")
axis off;

% For the encoder model, this example uses a simple network consisting of an embedding followed by an LSTM operation.
% Embedding is a method of converting categorical tokens into numeric vectors.
figure
imshow("SequencetoSequenceTranslationUsingAttentionExample_02.png")
axis off;

% For the decoder model, this example uses a network that contains an LSTM operation and an attention mechanism.
% The attention mechanism allows the decoder to attend to specific parts of the encoder output.
figure
imshow("SequencetoSequenceTranslationUsingAttentionExample_03.png")
axis off;

%%% Load Training Data
% Download the decimal-Roman numeral pairs from "romanNumerals.csv".
filename = fullfile("romanNumerals.csv");

options = detectImportOptions(filename, ...
    TextType="string", ...
    ReadVariableNames=false);
options.VariableNames = ["Source" "Target"];
options.VariableTypes = ["string" "string"];

data = readtable(filename,options);

% Split the data into training and test partitions containing 50% of the data each.
idx = randperm(size(data,1),500);
dataTrain = data(idx,:);
dataTest = data;
dataTest(idx,:) = [];

% View some of the decimal-Roman numeral pairs.
head(dataTrain)

%%% Preprocess Data
% Preprocess the text data using the transformText function, listed at the end of the example.
% The transformText function preprocesses and tokenizes the input text for translation by splitting the text into characters and adding start and stop tokens.
% To translate text by splitting the text into words instead of characters, skip the first step.
startToken = "<start>";
stopToken = "<stop>";

strSource = dataTrain.Source;
documentsSource = transformText(strSource,startToken,stopToken);

% Create a wordEncoding object that maps tokens to a numeric index and vice-versa using a vocabulary.
encSource = wordEncoding(documentsSource);

% Using the word encoding, convert the source text data to numeric sequences.
sequencesSource = doc2sequence(encSource,documentsSource,PaddingDirection="none");

% Convert the target data to sequences using the same steps.
strTarget = dataTrain.Target;
documentsTarget = transformText(strTarget,startToken,stopToken);
encTarget = wordEncoding(documentsTarget);
sequencesTarget = doc2sequence(encTarget,documentsTarget,PaddingDirection="none");

% Sort the sequences by length.
% Training with the sequences sorted by increasing sequence length results in batches with sequences of approximately the same sequence length and ensures smaller sequence batches are used to update the model before longer sequence batches.
sequenceLengths = cellfun(@(sequence) size(sequence,2),sequencesSource);
[~,idx] = sort(sequenceLengths);
sequencesSource = sequencesSource(idx);
sequencesTarget = sequencesTarget(idx);

% Create arrayDatastore objects containing the source and target data and combine them using the combine function.
sequencesSourceDs = arrayDatastore(sequencesSource,OutputType="same");
sequencesTargetDs = arrayDatastore(sequencesTarget,OutputType="same");

sequencesDs = combine(sequencesSourceDs,sequencesTargetDs);

%%% Initialize Model Parameters
% Initialize the model parameters.
% For both the encoder and decoder, specify an embedding dimension of 128, an LSTM layer with 100 hidden units, and dropout layers with random dropout with probability 0.05.
embeddingDimension = 128;
numHiddenUnits = 100;
dropout = 0.05;

%%% Initialize Encoder Model Parameters
% Initialize the weights of the encoding embedding using the Gaussian using the initializeGaussian function which is attached to this example as a supporting file.
% Specify a mean of 0 and a standard deviation of 0.01.
% To learn more, see Gaussian Initialization.
inputSize = encSource.NumWords + 1;
sz = [embeddingDimension inputSize];
mu = 0;
sigma = 0.01;
parameters.encoder.emb.Weights = initializeGaussian(sz,mu,sigma);

% Initialize the learnable parameters for the encoder LSTM operation:
% - Initialize the input weights with the Glorot initializer using the initializeGlorot function which is attached to this example as a supporting file. To learn more, see Glorot Initialization.
% - Initialize the recurrent weights with the orthogonal initializer using the initializeOrthogonal function which is attached to this example as a supporting file. To learn more, see Orthogonal Initialization.
% - Initialize the bias with the unit forget gate initializer using the initializeUnitForgetGate function which is attached to this example as a supporting file. To learn more, see Unit Forget Gate Initialization.

% Initialize the learnable parameters for the encoder LSTM operation.
sz = [4*numHiddenUnits embeddingDimension];
numOut = 4*numHiddenUnits;
numIn = embeddingDimension;

parameters.encoder.lstm.InputWeights = initializeGlorot(sz,numOut,numIn);
parameters.encoder.lstm.RecurrentWeights = initializeOrthogonal([4*numHiddenUnits numHiddenUnits]);
parameters.encoder.lstm.Bias = initializeUnitForgetGate(numHiddenUnits);

%%% Initialize Decoder Model Parameters
% Initialize the weights of the encoding embedding using the Gaussian using the initializeGaussian function.
% Specify a mean of 0 and a standard deviation of 0.01.
outputSize = encTarget.NumWords + 1;
sz = [embeddingDimension outputSize];
mu = 0;
sigma = 0.01;
parameters.decoder.emb.Weights = initializeGaussian(sz,mu,sigma);

% Initialize the weights of the attention mechanism using the Glorot initializer using the initializeGlorot function.
sz = [numHiddenUnits numHiddenUnits];
numOut = numHiddenUnits;
numIn = numHiddenUnits;
parameters.decoder.attention.Weights = initializeGlorot(sz,numOut,numIn);

% Initialize the learnable parameters for the decoder LSTM operation:
% - Initialize the input weights with the Glorot initializer using the initializeGlorot function.
% - Initialize the recurrent weights with the orthogonal initializer using the initializeOrthogonal function.
% - Initialize the bias with the unit forget gate initializer using the initializeUnitForgetGate function.

% Initialize the learnable parameters for the decoder LSTM operation.
sz = [4*numHiddenUnits embeddingDimension+numHiddenUnits];
numOut = 4*numHiddenUnits;
numIn = embeddingDimension + numHiddenUnits;

parameters.decoder.lstm.InputWeights = initializeGlorot(sz,numOut,numIn);
parameters.decoder.lstm.RecurrentWeights = initializeOrthogonal([4*numHiddenUnits numHiddenUnits]);
parameters.decoder.lstm.Bias = initializeUnitForgetGate(numHiddenUnits);

% Initialize the learnable parameters for the decoder fully connected operation:
% - Initialize the weights with the Glorot initializer.
% - Initialize the bias with zeros using the initializeZeros function which is attached to this example as a supporting file. To learn more, see Zeros Initialization.
sz = [outputSize 2*numHiddenUnits];
numOut = outputSize;
numIn = 2*numHiddenUnits;

parameters.decoder.fc.Weights = initializeGlorot(sz,numOut,numIn);
parameters.decoder.fc.Bias = initializeZeros([outputSize 1]);

%%% Define Model Functions
% Create the functions modelEncoder and modelDecoder, listed at the end of the example, that compute the outputs of the encoder and decoder models, respectively.
% The modelEncoder function, listed in the Encoder Model Function section of the example, takes the input data, the model parameters, the optional mask that is used to determine the correct outputs for training and returns the model outputs and the LSTM hidden state.
% The modelDecoder function, listed in the Decoder Model Function section of the example, takes the input data, the model parameters, the context vector, the LSTM initial hidden state, the outputs of the encoder, and the dropout probability and outputs the decoder output, the updated context vector, the updated LSTM state, and the attention scores.

%%% Define Model Loss Function
% Create the function modelLoss, listed in the Model Loss Function section of the example, that takes the encoder and decoder model parameters, a mini-batch of input data and the padding masks corresponding to the input data, and the dropout probability and returns the loss and the gradients of the loss with respect to the learnable parameters in the models.

%%% Specify Training Options
% Train with a mini-batch size of 32 for 100 epochs with a learning rate of 0.001.
miniBatchSize = 32;
numEpochs = 100;
learnRate = 0.001;

% Initialize the options from Adam.
gradientDecayFactor = 0.9;
squaredGradientDecayFactor = 0.999;

%%% Train Model
% Train the model using a custom training loop.
% Use minibatchqueue to process and manage mini-batches of images during training.
% For each mini-batch:
% - Use the custom mini-batch preprocessing function preprocessMiniBatch (defined at the end of this example) to find the lengths of all sequence in the mini-batch and pad the sequences to the same length as the longest sequence, for the source and target sequences, respectively.
% - Permute the second and third dimensions of the padded sequences.
% - Return the mini-batch variables unformatted dlarray objects with underlying data type single. All other outputs are arrays of data type single.
% - Train on a GPU if one is available. Return all mini-batch variables on the GPU if one is available. Using a GPU requires Parallel Computing Toolbox™ and a supported GPU device. For information on supported devices, see GPU Computing Requirements (Parallel Computing Toolbox).

% The minibatchqueue object returns four output arguments for each mini-batch: the source sequences, the target sequences, the lengths of all source sequences in the mini-batch, and the sequence mask of the target sequences.
numMiniBatchOutputs = 4;

mbq = minibatchqueue(sequencesDs,numMiniBatchOutputs,...
    MiniBatchSize=miniBatchSize,...
    MiniBatchFcn=@(x,t) preprocessMiniBatch(x,t,inputSize,outputSize));

% Initialize the values for the adamupdate function.
trailingAvg = [];
trailingAvgSq = [];

% Calculate the total number of iterations for the training progress monitor
numObservationsTrain = numel(sequencesSource);
numIterationsPerEpoch = ceil(numObservationsTrain / miniBatchSize);
numIterations = numEpochs * numIterationsPerEpoch;

% Initialize the training progress monitor.
% Because the timer starts when you create the monitor object, make sure that you create the object close to the training loop.
monitor = trainingProgressMonitor( ...
    Metrics="Loss", ...
    Info="Epoch", ...
    XLabel="Iteration");

% Train the model. For each mini-batch:
% - Read a mini-batch of padded sequences.
% - Compute loss and gradients.
% - Update the encoder and decoder model parameters using the adamupdate function.
% - Update the training progress monitor.
% - Stop training when the Stop property of the training progress monitor is true. The Stop property of the training monitor changes to 1 when you click the stop button.
epoch = 0;
iteration = 0;

% Loop over epochs.
while epoch < numEpochs && ~monitor.Stop
    epoch = epoch + 1;

    reset(mbq);

    % Loop over mini-batches.
    while hasdata(mbq) && ~monitor.Stop
        iteration = iteration + 1;

        [X,T,sequenceLengthsSource,maskSequenceTarget] = next(mbq);

        % Compute loss and gradients.
        [loss,gradients] = dlfeval(@modelLoss,parameters,X,T,sequenceLengthsSource,...
            maskSequenceTarget,dropout);

        % Update parameters using adamupdate.
        [parameters,trailingAvg,trailingAvgSq] = adamupdate(parameters,gradients,trailingAvg,trailingAvgSq,...
            iteration,learnRate,gradientDecayFactor,squaredGradientDecayFactor);

        % Normalize loss by sequence length.
        loss = loss ./ size(T,3);

        % Update the training progress monitor. 
        recordMetrics(monitor,iteration,Loss=loss);
        updateInfo(monitor,Epoch=epoch + " of " + numEpochs);
        monitor.Progress = 100*iteration/numIterations;
    end
end

figure
imshow("SequencetoSequenceTranslationUsingAttentionExample_04.png")
axis off;

%%% Generate Translations
% To generate translations for new data using the trained model, convert the text data to numeric sequences using the same steps as when training and input the sequences into the encoder-decoder model and convert the resulting sequences back into text using the token indices.

% Preprocess the text data using the same steps as when training.
% Use the transformText function, listed at the end of the example, to split the text into characters and add the start and stop tokens.
strSource = dataTest.Source;
strTarget = dataTest.Target;

% Translate the text using the modelPredictions function.
maxSequenceLength = 10;
delimiter = "";

strTranslated = translateText(parameters,strSource,maxSequenceLength,miniBatchSize, ...
    encSource,encTarget,startToken,stopToken,delimiter);

% Create a table containing the test source text, target text, and translations.
tbl = table;
tbl.Source = strSource;
tbl.Target = strTarget;
tbl.Translated = strTranslated;

% View a random selection of the translations.
idx = randperm(size(dataTest,1),miniBatchSize);
tbl(idx,:)

%%% Bibliography
% [1] Luong, Minh-Thang, Hieu Pham, and Christopher D. Manning. "Effective approaches to attention-based neural machine translation." arXiv preprint arXiv:1508.04025 (2015).

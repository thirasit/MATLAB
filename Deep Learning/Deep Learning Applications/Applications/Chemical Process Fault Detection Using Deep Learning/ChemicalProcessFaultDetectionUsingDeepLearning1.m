%% Chemical Process Fault Detection Using Deep Learning
% This example shows how to use simulation data to train a neural network that can detect faults in a chemical process.
% The network detects the faults in the simulated process with high accuracy.
% The typical workflow is as follows:
% 1. Preprocess the data
% 2. Design the layer architecture
% 3. Train the network
% 4. Perform validation
% 5. Test the network

%%% Download Data Set
% This example uses MATLAB-formatted files converted by MathWorks® from the Tennessee Eastman Process (TEP) simulation data [1].
% These files are available at the MathWorks support files site.
% See the disclaimer.

% The data set consists of four components — fault-free training, fault-free testing, faulty training, and faulty testing.
% Download each file separately.
url = 'https://www.mathworks.com/supportfiles/predmaint/chemical-process-fault-detection-data/faultytesting.mat';
websave('faultytesting.mat',url);
url = 'https://www.mathworks.com/supportfiles/predmaint/chemical-process-fault-detection-data/faultytraining.mat';
websave('faultytraining.mat',url);
url = 'https://www.mathworks.com/supportfiles/predmaint/chemical-process-fault-detection-data/faultfreetesting.mat';
websave('faultfreetesting.mat',url);
url = 'https://www.mathworks.com/supportfiles/predmaint/chemical-process-fault-detection-data/faultfreetraining.mat';
websave('faultfreetraining.mat',url);

% Load the downloaded files into the MATLAB® workspace.
load('faultfreetesting.mat');
load('faultfreetraining.mat');
load('faultytesting.mat');
load('faultytraining.mat');

% Each component contains data from simulations that were run for every permutation of two parameters:
% - Fault Number — For faulty data sets, an integer value from 1 to 20 that represents a different simulated fault. For fault-free data sets, a value of 0.
% - Simulation run — For all data sets, integer values from 1 to 500, where each value represents a unique random generator state for the simulation.

% The length of each simulation was dependent on the data set. All simulations were sampled every three minutes.
% - Training data sets contain 500 time samples from 25 hours of simulation.
% - Testing data sets contain 960 time samples from 48 hours of simulation.

% Each data frame has the following variables in its columns:
% - Column 1 (faultNumber) indicates the fault type, which varies from 0 through 20. A fault number 0 means fault-free while fault numbers 1 to 20 represent different fault types in the TEP.
% - Column 2 (simulationRun) indicates the number of times the TEP simulation ran to obtain complete data. In the training and test data sets, the number of runs varies from 1 to 500 for all fault numbers. Every simulationRun value represents a different random generator state for the simulation.
% - Column 3 (sample) indicates the number of times TEP variables were recorded per simulation. The number varies from 1 to 500 for the training data sets and from 1 to 960 for the testing data sets. The TEP variables (columns 4 to 55) were sampled every 3 minutes for a duration of 25 hours and 48 hours for the training and testing data sets respectively.
% - Columns 4–44 (xmeas_1 through xmeas_41) contain the measured variables of the TEP.
% - Columns 45–55 (xmv_1 through xmv_11) contain the manipulated variables of the TEP.

% Examine subsections of two of the files.
head(faultfreetraining,4)

head(faultytraining,4) 

%%% Clean Data
% Remove data entries with the fault numbers 3, 9, and 15 in both the training and testing data sets.
% These fault numbers are not recognizable, and the associated simulation results are erroneous.
faultytesting(faultytesting.faultNumber == 3,:) = [];
faultytesting(faultytesting.faultNumber == 9,:) = [];
faultytesting(faultytesting.faultNumber == 15,:) = [];
faultytraining(faultytraining.faultNumber == 3,:) = [];
faultytraining(faultytraining.faultNumber == 9,:) = [];
faultytraining(faultytraining.faultNumber == 15,:) = [];

%%% Divide Data
% Divide the training data into training and validation data by reserving 20 percent of the training data for validation.
% Using a validation data set enables you to evaluate the model fit on the training data set while you tune the model hyperparameters.
% Data splitting is commonly used to prevent the network from overfitting and underfitting.

% Get the total number of rows in both faulty and fault-free training data sets.
H1 = height(faultfreetraining); 
H2 = height(faultytraining); 

% The simulation run is the number of times the TEP process was repeated with a particular fault type.
% Get the maximum simulation run from the training data set as well as from the testing data set.
msTrain = max(faultfreetraining.simulationRun); 
msTest = max(faultytesting.simulationRun);   

% Calculate the maximum simulation run for the validation data.
rTrain = 0.80; 
msVal = ceil(msTrain*(1 - rTrain));    
msTrain = msTrain*rTrain;   

% Get the maximum number of samples or time steps (that is, the maximum number of times that data was recorded during a TEP simulation).
sampleTrain = max(faultfreetraining.sample);
sampleTest = max(faultfreetesting.sample);

% Get the division point (row number) in the fault-free and faulty training data sets to create validation data sets from the training data sets.
rowLim1 = ceil(rTrain*H1);
rowLim2 = ceil(rTrain*H2);

trainingData = [faultfreetraining{1:rowLim1,:}; faultytraining{1:rowLim2,:}];
validationData = [faultfreetraining{rowLim1 + 1:end,:}; faultytraining{rowLim2 + 1:end,:}];
testingData = [faultfreetesting{:,:}; faultytesting{:,:}];

%%% Network Design and Preprocessing
% The final data set (consisting of training, validation, and testing data) contains 52 signals with 500 uniform time steps.
% Hence, the signal, or sequence, needs to be classified to its correct fault number which makes it a problem of sequence classification.
% - Long short-term memory (LSTM) networks are suited to the classification of sequence data.
% - LSTM networks are good for time-series data as they tend to remember the uniqueness of past signals in order to classify new signals
% - An LSTM network enables you to input sequence data into a network and make predictions based on the individual time steps of the sequence data. For more information on LSTM networks, see Long Short-Term Memory Neural Networks.
% - To train the network to classify sequences using the trainNetwork function, you must first preprocess the data. The data must be in cell arrays, where each element of the cell array is a matrix representing a set of 52 signals in a single simulation. Each matrix in the cell array is the set of signals for a particular simulation of TEP and can either be faulty or fault-free. Each set of signals points to a specific fault class ranging from 0 through 20.

% As was described previously in the Data Set section, the data contains 52 variables whose values are recorded over a certain amount of time in a simulation.
% The sample variable represents the number of times these 52 variables are recorded in one simulation run.
% The maximum value of the sample variable is 500 in the training data set and 960 in the testing data set.
% Thus, for each simulation, there is a set of 52 signals of length 500 or 960.
% Each set of signals belongs to a particular simulation run of the TEP and points to a particular fault type in the range 0 – 20.

% The training and test datasets both contain 500 simulations for each fault type.
% Twenty percent (from training) is kept for validation which leaves the training data set with 400 simulations per fault type and validation data with 100 simulations per fault type.
% Use the helper function helperPreprocess to create sets of signals, where each set is a double matrix in a single element of the cell array that represents a single TEP simulation.
% Hence, the sizes of the final training, validation, and testing data sets are as follows:
% - Size of Xtrain: (Total number of simulations) X (Total number of fault types) = 400 X 18 = 7200
% - Size of XVal: (Total number of simulations) X (Total number of fault types) = 100 X 18 = 1800
% - Size of Xtest: (Total number of simulations) X (Total number of fault types) = 500 X 18 = 9000

% In the data set, the first 500 simulations are of 0 fault type (fault-free) and the order of the subsequent faulty simulations is known.
% This knowledge enables the creation of true responses for the training, validation, and testing data sets.
Xtrain = helperPreprocess(trainingData,sampleTrain);
Ytrain = categorical([zeros(msTrain,1);repmat([1,2,4:8,10:14,16:20],1,msTrain)']);
 
XVal = helperPreprocess(validationData,sampleTrain);
YVal = categorical([zeros(msVal,1);repmat([1,2,4:8,10:14,16:20],1,msVal)']);
 
Xtest = helperPreprocess(testingData,sampleTest);
Ytest = categorical([zeros(msTest,1);repmat([1,2,4:8,10:14,16:20],1,msTest)']);

%%% Normalize Data Sets
% Normalization is a technique that scales the numeric values in a data set to a common scale without distorting differences in the range of values.
% This technique ensures that a variable with a larger value does not dominate other variables in the training.
% It also converts the numeric values in a higher range to a smaller range (usually –1 to 1) without losing any important information required for training.

% Compute the mean and the standard deviation for 52 signals using data from all simulations in the training data set.
tMean = mean(trainingData(:,4:end))';
tSigma = std(trainingData(:,4:end))';

% Use the helper function helperNormalize to apply normalization to each cell in the three data sets based on the mean and standard deviation of the training data.
Xtrain = helperNormalize(Xtrain, tMean, tSigma);
XVal = helperNormalize(XVal, tMean, tSigma);
Xtest = helperNormalize(Xtest, tMean, tSigma);

%%% Visualize Data
% The Xtrain data set contains 400 fault-free simulations followed by 6800 faulty simulations.Visualize the fault-free and faulty data.
% First, create a plot of the fault-free data.
% For the purposes of this example, plot and label only 10 signals in the Xtrain data set to create an easy-to-read figure.
figure;
splot = 10;    
plot(Xtrain{1}(1:10,:)');   
xlabel("Time Step");
title("Training Observation for Non-Faulty Data");
legend("Signal " + string(1:splot),'Location','northeastoutside');

% Now, compare the fault-free plot to a faulty plot by plotting any of the cell array elements after 400.
figure;
plot(Xtrain{1000}(1:10,:)');   
xlabel("Time Step");
title("Training Observation for Faulty Data");
legend("Signal " + string(1:splot),'Location','northeastoutside');

%%% Layer Architecture and Training Options
% LSTM layers are a good choice for sequence classification as LSTM layers tend to remember only the important aspects of the input sequence.
% - Specify the input layer sequenceInputLayer to be of the same size as the number of input signals (52).
% - Specify 3 LSTM hidden layers with 52, 40, and 25 units. This specification is inspired by the experiment performed in [2]. For more information on using LSTM networks for sequence classification, see Sequence Classification Using Deep Learning.
% - Add 3 dropout layers in between the LSTM layers to prevent over-fitting. A dropout layer randomly sets input elements of the next layer to zero with a given probability so that the network does not become sensitive to a small set of neurons in the layer
% - Finally, for classification, include a fully connected layer of the same size as the number of output classes (18). After the fully connected layer, include a softmax layer that assigns decimal probabilities (prediction possibility) to each class in a multi-class problem and a classification layer to output the final fault type based on output from the softmax layer.
numSignals = 52;
numHiddenUnits2 = 52;
numHiddenUnits3 = 40;
numHiddenUnits4 = 25;
numClasses = 18;
     
layers = [ ...
    sequenceInputLayer(numSignals)
    lstmLayer(numHiddenUnits2,'OutputMode','sequence')
    dropoutLayer(0.2)
    lstmLayer(numHiddenUnits3,'OutputMode','sequence')
    dropoutLayer(0.2)
    lstmLayer(numHiddenUnits4,'OutputMode','last')
    dropoutLayer(0.2)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

% Set the training options that trainNetwork uses.

% Maintain the default value of name-value pair 'ExecutionEnvironment' as 'auto'.
% With this setting, the software chooses the execution environment automatically.
% By default, trainNetwork uses a GPU if one is available, otherwise, it uses a CPU.
% Training on a GPU requires Parallel Computing Toolbox™ and a supported GPU device.
% For information on supported devices, see GPU Computing Requirements (Parallel Computing Toolbox).
% Because this example uses a large amount of data, using GPU speeds up training time considerably.

% Setting the name-value argument pair 'Shuffle' to 'every-epoch' avoids discarding the same data every epoch.

% For more information on training options for deep learning, see trainingOptions.
maxEpochs = 30;
miniBatchSize = 50;  
 
options = trainingOptions('adam', ...
    'ExecutionEnvironment','auto', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize', miniBatchSize,...
    'Shuffle','every-epoch', ...
    'Verbose',0, ...
    'Plots','training-progress',...
    'ValidationData',{XVal,YVal});

%%% Train Network
% Train the LSTM network using trainNetwork.
net = trainNetwork(Xtrain,Ytrain,layers,options);

figure
imshow("ChemicalProcessFaultDetectionUsingDeepLearningExample_03.png")
axis off;

% The training progress figure displays a plot of the network accuracy.
% To the right of the figure, view information on the training time and settings.

%%% Testing Network
% Run the trained network on the test set and predict the fault type in the signals.
Ypred = classify(net,Xtest,...
    'MiniBatchSize', miniBatchSize,...
    'ExecutionEnvironment','auto');

% Calculate the accuracy.
% The accuracy is the number of true labels in the test data that match the classifications from classify divided by the number of images in the test data.
acc = sum(Ypred == Ytest)./numel(Ypred)

% High accuracy indicates that the neural network is successfully able to identify the fault type of unseen signals with minimal errors.
% Hence, the higher the accuracy, the better the network.
% Plot a confusion matrix using true class labels of the test signals to determine how well the network identifies each fault.
confusionchart(Ytest,Ypred);

% Using a confusion matrix, you can assess the effectiveness of a classification network.
% The confusion matrix has numerical values in the main diagonal and zeros elsewhere.
% The trained network in this example is effective and classifies more than 99% of signals correctly.

%%% References
% [1] Rieth, C. A., B. D. Amsel, R. Tran., and B. Maia. "Additional Tennessee Eastman Process Simulation Data for Anomaly Detection Evaluation." Harvard Dataverse, Version 1, 2017. https://doi.org/10.7910/DVN/6C3JR1.
% [2] Heo, S., and J. H. Lee. "Fault Detection and Classification Using Artificial Neural Networks." Department of Chemical and Biomolecular Engineering, Korea Advanced Institute of Science and Technology.

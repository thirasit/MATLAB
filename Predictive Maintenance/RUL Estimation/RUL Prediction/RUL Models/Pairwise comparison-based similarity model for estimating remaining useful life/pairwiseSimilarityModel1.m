%%% Pairwise comparison-based similarity model for estimating remaining useful life

%% Train Pairwise Similarity Model
% Load training data.
load('pairwiseTrainVectors.mat')

% The training data is a cell array of column vectors. Each column vector is a degradation feature profile for a component.
% Create a pairwise similarity model with default settings.
mdl = pairwiseSimilarityModel;

% Train the similarity model using the training data.
fit(mdl,pairwiseTrainVectors)

%% Train Pairwise Similarity Model Using Tabular Data
% Load training data.
load('pairwiseTrainTables.mat')

% The training data is a cell array of tables. Each table is a degradation feature profile for a component. Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.
% Create a pairwise similarity model that computes distance using dynamic time warping with an absolute distance metric.
mdl = pairwiseSimilarityModel('Method',"dtw",'Distance',"absolute");

% Train the similarity model using the training data. Specify the names of the life time and data variables.
fit(mdl,pairwiseTrainTables,"Time","Condition")

%% Predict RUL Using Pairwise Similarity Model
% Load training data.
load('pairwiseTrainTables.mat')

% The training data is a cell array of tables. Each table is a degradation feature profile for a component. Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.
% Create a pairwise similarity model that computes distance using dynamic time warping with an absolute distance metric and uses hours as a life time unit.
mdl = pairwiseSimilarityModel('Method',"dtw",'Distance',"absolute",'LifeTimeUnit',"hours");

% Train the similarity model using the training data. Specify the names of the life time and data variables.
fit(mdl,pairwiseTrainTables,"Time","Condition")

% Load testing data. The test data contains the degradation feature measurements for a test component up to the current life time.
load('pairwiseTestData.mat')

% Predict the RUL of the test component using the trained similarity model.
estRUL = predictRUL(mdl,pairwiseTestData)

% The estimated RUL for the component is around 94 hours.

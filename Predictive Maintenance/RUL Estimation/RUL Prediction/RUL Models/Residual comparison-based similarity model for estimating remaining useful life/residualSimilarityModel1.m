%%% Residual comparison-based similarity model for estimating remaining useful life

%% Train Residual Similarity Model
% Load training data.
load('residualTrainVectors.mat')

% The training data is a cell array of column vectors. Each column vector is a degradation feature profile for a component.
% Create a residual similarity model with default settings.
mdl = residualSimilarityModel;

% Train the similarity model using the training data.
fit(mdl,residualTrainVectors)

%% Train Residual Similarity Model Using Tabular Data
% Load training data.
load('residualTrainTables.mat')

% The training data is a cell array of tables. Each table is a degradation feature profile for a component. Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.
% Create a residual similarity model that fits the data with a third-order ARMA model and uses an absolute distance metric.
mdl = residualSimilarityModel('Method',"arma3",'Distance',"absolute");

% Train the similarity model using the training data. Specify the names of the life time and data variables.
fit(mdl,residualTrainTables,"Time","Condition")

%% Predict RUL Using Residual Similarity Model
% Load training data.
load('residualTrainTables.mat')

% The training data is a cell array of tables. Each table is a degradation feature profile for a component. Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.
% Create a residual similarity model that fits the data with a third-order ARMA model and uses hours as the life time unit.
mdl = residualSimilarityModel('Method',"arma3",'LifeTimeUnit',"hours");

% Train the similarity model using the training data. Specify the names of the life time and data variables.
fit(mdl,residualTrainTables,"Time","Condition")

% Load testing data. The test data contains the degradation feature measurements for a test component up to the current life time.
load('residualTestData.mat')

% Predict the RUL of the test component using the trained similarity model.
estRUL = predictRUL(mdl,residualTestData)

% The estimated RUL for the component is around 86 hours.

%%% Hashed-feature similarity model for estimating remaining useful life

%% Train Hash Similarity Model
% Load training data.
load('hashTrainVectors.mat')

% The training data is a cell array of column vectors. 
% Each column vector is a degradation feature profile for a component.

% Create a hash similarity model with default settings. 
% By default, the hashed features used by the model are the signal maximum, minimum, and standard deviation values.
mdl = hashSimilarityModel;

% Train the similarity model using the training data.
fit(mdl,hashTrainVectors)

%% Train Hash Similarity Model Using Tabular Data
% Load training data.
load('hashTrainTables.mat')

% The training data is a cell array of tables. 
% Each table is a degradation feature profile for a component. 
% Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.

% Create a hash similarity model that uses the following values as hashed features:
mdl = hashSimilarityModel('Method',@(x) [mean(x),std(x),kurtosis(x),median(x)]);

% Train the similarity model using the training data. Specify the names of the life time and data variables.
fit(mdl,hashTrainTables,"Time","Condition")

%% Predict RUL Using Hash Similarity Model
% Load training data.
load('hashTrainTables.mat')

% The training data is a cell array of tables. 
% Each table is a degradation feature profile for a component. 
% Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.

% Create a hash similarity model that uses hours as a life time unit and the following values as hashed features:
% - Mean
% - Standard deviation
% - Kurtosis
% - Median
mdl = hashSimilarityModel('Method',@(x) [mean(x),std(x),kurtosis(x),median(x)],...
                          'LifeTimeUnit',"hours");

% Train the similarity model using the training data. Specify the names of the life time and data variables.
fit(mdl,hashTrainTables,"Time","Condition")

% Load testing data. The test data contains the degradation feature measurements for a test component up to the current life time.
load('hashTestData.mat')

% Predict the RUL of the test component using the trained similarity model.
estRUL = predictRUL(mdl,hashTestData)

% The estimated RUL for the component is around 176 hours.

%% Specify Custom Distance Function for Hash Similarity Model
% Load the training and test data.
load('hashTrainTables.mat')
load('hashTestData.mat')

% Create a coordinate-weighted distance function distanceFunction that contains the following code.
type distanceFunction.m

% Create a hash similarity model that uses hours as the life time unit and the function handle for distanceFunction as the distance measurement.
mdl = hashSimilarityModel('LifeTimeUnit',"hours", 'Distance', @distanceFunction);

% Train the similarity model using the training data. Specify the names of the life time and data variables.
fit(mdl,hashTrainTables,"Time","Condition")

% Predict the RUL of the test component using the trained similarity model.
estRUL = predictRUL(mdl,hashTestData)

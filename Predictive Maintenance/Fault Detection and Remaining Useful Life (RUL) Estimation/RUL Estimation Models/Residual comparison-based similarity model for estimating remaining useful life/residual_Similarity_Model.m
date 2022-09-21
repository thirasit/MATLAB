%% Residual comparison-based similarity model for estimating remaining useful life

%%% Description
% Use residualSimilarityModel to estimate the remaining useful life (RUL) of a component using a residual comparison-based similarity model. 
% This model is useful when you have degradation profiles for an ensemble of similar components, such as multiple machines manufactured to the same specifications, and you know the dynamics of the degradation process. 
% The historical data for each member of the data ensemble is fitted with a model of identical structure. 
% The degradation data of the test component is used to compute 1-step prediction errors, or residuals, for each ensemble model. 
% The magnitudes of these errors indicate how similar the test component is to the corresponding ensemble members.

% To configure a residualSimilarityModel object, use fit, which trains and stores the degradation model for each data ensemble member. 
% Once you configure the parameters of your similarity model, you can then predict the remaining useful life of similar components using predictRUL. 
% For similarity models, the RUL of the test component is estimated as the median statistic of the lifetime span of the most similar components minus the current lifetime value of the test component. 
% For a basic example illustrating RUL prediction, see Update RUL Prediction as Data Arrives.

% For general information on predicting remaining useful life, see Models for Predicting Remaining Useful Life.

%%% Object Functions
% predictRUL	- Estimate remaining useful life for a test component
% fit	        - Estimate parameters of remaining useful life model using historical data
% compare	    - Compare test data to historical data ensemble for similarity models

%%% Examples
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

%%% The estimated RUL for the component is around 86 hours.

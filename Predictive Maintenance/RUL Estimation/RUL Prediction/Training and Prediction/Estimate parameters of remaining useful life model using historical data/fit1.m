%%% Estimate parameters of remaining useful life model using historical data

%% Train Linear Degradation Model
% Load training data.
load('linTrainVectors.mat')

% The training data is a cell array of column vectors. Each column vector is a degradation feature profile for a component.
% Create a linear degradation model with default settings.
mdl = linearDegradationModel;

% Train the degradation model using the training data.
fit(mdl,linTrainVectors)

%% Train Reliability Survival Model
% Load training data.
load('reliabilityData.mat')

% This data is a column vector of duration objects representing battery discharge times.
% Create a reliability survival model with default settings.
mdl = reliabilitySurvivalModel;

% Train the survival model using the training data.
fit(mdl,reliabilityData,"hours")

%% Train Hash Similarity Model Using Tabular Data
% Load training data.
load('hashTrainTables.mat')

% The training data is a cell array of tables. Each table is a degradation feature profile for a component. Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.
% Create a hash similarity model that uses the following values as hashed features:
mdl = hashSimilarityModel('Method',@(x) [mean(x),std(x),kurtosis(x),median(x)]);

% Train the similarity model using the training data. Specify the names of the life time and data variables.
fit(mdl,hashTrainTables,"Time","Condition")

%% Predict RUL Using Covariate Survival Model
% Load training data.
load('covariateData.mat')

% This data contains battery discharge times and related covariate information. The covariate variables are:
% - Temperature
% - Load
% - Manufacturer

% The manufacturer information is a categorical variable that must be encoded.
% Create a covariate survival model, and train it using the training data.
mdl = covariateSurvivalModel('LifeTimeVariable',"DischargeTime",'LifeTimeUnit',"hours",...
   'DataVariables',["Temperature","Load","Manufacturer"],'EncodedVariables',"Manufacturer");
fit(mdl,covariateData)

% Suppose you have a battery pack manufactured by maker B that has run for 30 hours. Create a test data table that contains the usage time, DischargeTime, and the measured ambient temperature, TestAmbientTemperature, and current drawn, TestBatteryLoad.
TestBatteryLoad = 25;
TestAmbientTemperature = 60; 
DischargeTime = hours(30);
TestData = timetable(TestAmbientTemperature,TestBatteryLoad,"B",'RowTimes',hours(30));
TestData.Properties.VariableNames = {'Temperature','Load','Manufacturer'};
TestData.Properties.DimensionNames{1} = 'DischargeTime';

% Predict the RUL for the battery.
estRUL = predictRUL(mdl,TestData)

% Plot the survival function for the covariate data of the battery.
plot(mdl,TestData)

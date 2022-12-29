%%% Plot survival function for covariate survival remaining useful life model

%% Train Covariate Survival Model
% Load training data.
load('covariateData.mat')

% This data contains battery discharge times and related covariate information. 
% The covariate variables are:
% - Temperature
% - Load
%  - Manufacturer

% The manufacturer information is a categorical variable that must be encoded.
% Create a covariate survival model.
mdl = covariateSurvivalModel;

% Train the survival model using the training data, specifying the life time variable, data variables, and encoded variable. 
% There is no censor variable for this training data.
fit(mdl,covariateData,"DischargeTime",["Temperature","Load","Manufacturer"],[],"Manufacturer")

% Plot the baseline survival function for the model.
figure
plot(mdl)

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

% Suppose you have a battery pack manufactured by maker B that has run for 30 hours. 
% Create a test data table that contains the usage time, DischargeTime, and the measured ambient temperature, TestAmbientTemperature, and current drawn, TestBatteryLoad.
TestBatteryLoad = 25;
TestAmbientTemperature = 60; 
DischargeTime = hours(30);
TestData = timetable(TestAmbientTemperature,TestBatteryLoad,"B",'RowTimes',hours(30));
TestData.Properties.VariableNames = {'Temperature','Load','Manufacturer'};
TestData.Properties.DimensionNames{1} = 'DischargeTime';

% Predict the RUL for the battery.
estRUL = predictRUL(mdl,TestData)

% Plot the survival function for the covariate data of the battery.
figure
plot(mdl,TestData)

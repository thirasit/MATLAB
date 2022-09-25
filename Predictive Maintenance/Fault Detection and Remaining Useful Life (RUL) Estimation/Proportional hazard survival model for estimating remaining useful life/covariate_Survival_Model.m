%% Proportional hazard survival model for estimating remaining useful life

%%% Description
% Use covariateSurvivalModel to estimate the remaining useful life (RUL) of a component using a proportional hazard survival model. 
% This model describes the survival probability of a test component using historical information about the life span of components and associated covariates. 
% Covariates are environmental or explanatory variables, such as the component manufacturer or operating conditions. Covariate survival models are useful when the only data you have is the failure times and associated covariates for an ensemble of similar components, such as multiple machines manufactured to the same specifications. 
% For more information on the survival model, see Proportional Hazard Survival Model.

% To configure a covariateSurvivalModel object for a specific type of component, use fit, which estimates model coefficients using a collection of failure-time data and associated covariates. 
% After you configure the parameters of your covariate survival model, you can then predict the remaining useful life of similar components using predictRUL. 
% For a basic example illustrating RUL prediction, see Update RUL Prediction as Data Arrives.

% If you have only life span measurements and do not have covariate information, use a reliabilitySurvivalModel.

% For general information on predicting remaining useful life, see Models for Predicting Remaining Useful Life.

%%% Object Functions
% predictRUL	Estimate remaining useful life for a test component
% fit	        Estimate parameters of remaining useful life model using historical data
% plot	        Plot survival function for covariate survival remaining useful life model

%%% Examples
%% Train Covariate Survival Model
% Load training data.

load('covariateData.mat')

% This data contains battery discharge times and related covariate information. The covariate variables are:
% - Temperature
% - Load
% - Manufacturer
% The manufacturer information is a categorical variable that must be encoded.

% Create a covariate survival model.
mdl = covariateSurvivalModel;

% Train the survival model using the training data, specifying the life time variable, data variables, and encoded variable. There is no censor variable for this training data.
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


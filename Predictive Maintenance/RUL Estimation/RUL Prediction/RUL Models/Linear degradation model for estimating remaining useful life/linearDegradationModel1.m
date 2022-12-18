%%% Linear degradation model for estimating remaining useful life

%% Train Linear Degradation Model
% Load training data.
load('linTrainVectors.mat')

% The training data is a cell array of column vectors. Each column vector is a degradation feature profile for a component.
% Create a linear degradation model with default settings.
mdl = linearDegradationModel;

% Train the degradation model using the training data.
fit(mdl,linTrainVectors)

%% Create Linear Degradation Model with Known Priors
% Create a linear degradation model and configure it with a known prior distribution.
mdl = linearDegradationModel('Theta',0.25,'ThetaVariance',0.002);

% The specified prior distribution parameters are stored in the Prior property of the model.
mdl.Prior

% The current posterior distribution of the model is also set to match the specified prior distribution. For example, check the posterior value of the slope variance.
mdl.ThetaVariance

%% Train Linear Degradation Model Using Tabular Data
% Load training data.
load('linTrainTables.mat')

% The training data is a cell array of tables. 
% Each table is a degradation feature profile for a component. 
% Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.

% Create a linear degradation model with default settings.
mdl = linearDegradationModel;

% Train the degradation model using the training data. Specify the names of the life time and data variables.
fit(mdl,linTrainTables,"Time","Condition")

%% Predict RUL Using Linear Degradation Model
% Load training data.
load('linTrainTables.mat')

% The training data is a cell array of tables. 
% Each table is a degradation feature profile for a component. 
% Each profile consists of life time measurements in the "Time" variable and corresponding degradation feature measurements in the "Condition" variable.

% Create a linear degradation model, specifying the life time variable units.
mdl = linearDegradationModel('LifeTimeUnit',"hours");

% Train the degradation model using the training data. Specify the names of the life time and data variables.
fit(mdl,linTrainTables,"Time","Condition")

% Load testing data, which is a run-to-failure degradation profile for a test component. The test data is a table with the same life time and data variables as the training data.
load('linTestData.mat','linTestData1')

% Based on knowledge of the degradation feature limits, define a threshold condition indicator value that indicates the end-of-life of a component.
threshold = 60;

% Assume that you measure the component condition indicator after 48 hours. 
% Predict the remaining useful life of the component at this time using the trained linear degradation model. 
% The RUL is the forecasted time at which the degradation feature will pass the specified threshold.
estRUL = predictRUL(mdl,linTestData1(48,:),threshold)

% The estimated RUL is around 113 hours, which indicates a total predicted life span of around 161 hours.

%% Update Linear Degradation Model and Predict RUL
% Load observation data.
load('linTestData.mat','linTestData1')

% For this example, assume that the training data is not historical data, but rather real-time observations of the component condition.
% Based on knowledge of the degradation feature limits, define a threshold condition indicator value that indicates the end-of-life of a component.
threshold = 60;

% Create a linear degradation model arbitrary prior distribution data and a specified noise variance. Also, specify the life time and data variable names for the observation data.
mdl = linearDegradationModel('Theta',1,'ThetaVariance',1e6,'NoiseVariance',0.003,...
                             'LifeTimeVariable',"Time",'DataVariables',"Condition",...
                             'LifeTimeUnit',"hours");

% Observe the component condition for 50 hours, updating the degradation model after each observation.
for i=1:50
    update(mdl,linTestData1(i,:));
end

% After 50 hours, predict the RUL of the component using the current life time value stored in the model.
estRUL = predictRUL(mdl,threshold)

% The estimated RUL is about 50 hours, which indicates a total predicted life span of about 100 hours.

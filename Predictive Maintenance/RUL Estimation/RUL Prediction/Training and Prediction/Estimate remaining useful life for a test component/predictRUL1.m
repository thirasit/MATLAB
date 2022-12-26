%%% Estimate remaining useful life for a test component

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

%% Predict RUL Using Exponential Degradation Model
% Load training data.
load('expTrainTables.mat')

% The training data is a cell array of tables. Each table is a degradation feature profile for a component. Each profile consists of life time measurements in the "Hours" variable and corresponding degradation feature measurements in the "Condition" variable.
% Create an exponential degradation model, specifying the life time variable units.
mdl = exponentialDegradationModel('LifeTimeUnit',"hours");

% Train the degradation model using the training data. Specify the names of the life time and data variables.
fit(mdl,expTrainTables,"Time","Condition")

% Load testing data, which is a run-to-failure degradation profile for a test component. The test data is a table with the same life time and data variables as the training data.
load('expTestData.mat')

% Based on knowledge of the degradation feature limits, define a threshold condition indicator value that indicates the end-of-life of a component.
threshold = 500;

% Assume that you measure the component condition indicator every hour for 150 hours. 
% Update the trained degradation model with each measurement. 
% Then, predict the remaining useful life of the component at 150 hours. 
% The RUL is the forecasted time at which the degradation feature will pass the specified threshold.
for t = 1:150 
 update(mdl,expTestData(t,:)) 
end 
estRUL = predictRUL(mdl,threshold) 

% The estimated RUL is around 137 hours, which indicates a total predicted life span of 287 hours.

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

%% Predict RUL Using Reliability Survival Model and View PDF
% Load training data.
load('reliabilityData.mat')

% This data is a column vector of duration objects representing battery discharge times.
% Create a reliability survival model, specifying the life time variable and life time units.
mdl = reliabilitySurvivalModel('LifeTimeVariable',"DischargeTime",'LifeTimeUnit',"hours");

% Train the survival model using the training data.
fit(mdl,reliabilityData)

% Predict the life span of a new component, and obtain the probability distribution function for the estimate.
[estRUL,ciRUL,pdfRUL] = predictRUL(mdl);

% Plot the probability distribution.
figure
bar(pdfRUL.RUL,pdfRUL.ProbabilityDensity)
xlabel('Remaining useful life (hours)')
xlim(hours([40 90]))

% Improve the distribution view by providing the number of bins and bin size for the prediction.
[estRUL,ciRUL,pdfRUL] = predictRUL(mdl,'BinSize',0.5,'NumBins',500);
figure
bar(pdfRUL.RUL,pdfRUL.ProbabilityDensity)
xlabel('Remaining useful life (hours)')
xlim(hours([40 90]))

% Predict the RUL for a component that has been operating for 50 hours.
[estRUL,ciRUL,pdfRUL] = predictRUL(mdl,hours(50),'BinSize',0.5,'NumBins',500);
figure
bar(pdfRUL.RUL,pdfRUL.ProbabilityDensity)
xlabel('Remaining useful life (hours)')
xlim(hours([0 40]))

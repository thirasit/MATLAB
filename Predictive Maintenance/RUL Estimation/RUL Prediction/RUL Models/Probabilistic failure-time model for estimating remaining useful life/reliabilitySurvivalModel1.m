%% Probabilistic failure-time model for estimating remaining useful life

%% Train Reliability Survival Model
% Load training data.
load('reliabilityData.mat')

% This data is a column vector of duration objects representing battery discharge times.
% Create a reliability survival model with default settings.
mdl = reliabilitySurvivalModel;

% Train the survival model using the training data.
fit(mdl,reliabilityData,"hours")

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
figure
[estRUL,ciRUL,pdfRUL] = predictRUL(mdl,'BinSize',0.5,'NumBins',500);
bar(pdfRUL.RUL,pdfRUL.ProbabilityDensity)
xlabel('Remaining useful life (hours)')
xlim(hours([40 90]))

% Predict the RUL for a component that has been operating for 50 hours.
figure
[estRUL,ciRUL,pdfRUL] = predictRUL(mdl,hours(50),'BinSize',0.5,'NumBins',500);
bar(pdfRUL.RUL,pdfRUL.ProbabilityDensity)
xlabel('Remaining useful life (hours)')
xlim(hours([0 40]))

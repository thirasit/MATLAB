%% Code Generation for Binary GLM Logistic Regression Model Trained in Classification Learner
% This example shows how to train a binary GLM logistic regression model using Classification Learner, and then generate C code that predicts labels using the exported classification model.

%%% Load Sample Data
% Load sample data and import the data into the Classification Learner app.
% Load the patients data set.
% Specify the predictor data X, consisting of p predictors, and the response variable Y.
load patients
X = [Age Diastolic Height Systolic Weight];
p = size(X,2);
Y = Gender;

% On the Apps tab, click the Show more arrow at the right of the Apps section to display the gallery, and select Classification Learner.
% On the Classification Learner tab, in the File section, select New Session > From Workspace.

% In the New Session from Workspace dialog box, under Data Set Variable, select X from the list of workspace variables.
% Under Response, click the From workspace option button and then select Y from the list.
% To accept the default validation scheme and continue, click Start Session.
% The default validation option is 5-fold cross-validation, to protect against overfitting.

% By default, Classification Learner creates a scatter plot of the data.

%%% Train Binary GLM Logistic Regression Model
% Train a binary GLM logistic regression model using the Classification Learner app.

% On the Classification Learner tab, in the Models section, click the Show more arrow to display the gallery of classifiers.
% Under Logistic Regression Classifiers, click Binary GLM Logistic Regression.
% In the Train section, click Train All and select Train Selected.
% The app trains the model and displays its cross-validation accuracy Accuracy (Validation) in the Models pane.

%%% Export Model to Workspace
% Export the model to the MATLAB® Workspace and save it using saveLearnerForCoder.

% On the Classification Learner tab, click Export, click Export Model, and select Export Model.
% In the dialog box, specify trainedLogisticRegressionModel as the model name and click OK.

% The structure trainedLogisticRegressionModel appears in the MATLAB Workspace.
% The field GeneralizedLinearModel of trainedLogisticRegressionModel contains the required model.

% Note: If you run this example with all supporting files, you can load the trainedLogisticRegressionModel.mat file at the command line rather than exporting the model.
% The trainedLogisticRegressionModel structure was created using the previous steps.
load('trainedLogisticRegressionModel.mat')

% At the command line, save the model to a file named myModel.mat in your current folder.
saveLearnerForCoder(trainedLogisticRegressionModel.GeneralizedLinearModel,'myModel')

% Additionally, save the names of the success, failure, and missing classes of the trained model.
classNames = {trainedLogisticRegressionModel.SuccessClass, ...
    trainedLogisticRegressionModel.FailureClass,trainedLogisticRegressionModel.MissingClass};
save('ModelParameters.mat','classNames');

%%% Generate C Code for Prediction
% Define the entry-point function for prediction, and generate code for the function by using codegen.
% In your current folder, define a function named classifyX.m that does the following:
% - Accepts a numeric matrix (X) of observations containing the same predictor variables as the ones used to train the logistic regression model
% - Loads the classification model in myModel.mat
% - Computes predicted probabilities using the model
% - Converts the predicted probabilities to indices, where 1 indicates a success, 2 indicates a failure, and 3 indicates a missing value
% - Loads the class names in ModelParameters.mat
% - Returns predicted labels by indexing into the class names

%function label = classifyX (X) %#codegen 
%CLASSIFYX Classify using Logistic Regression Model 
%  CLASSIFYX classifies the measurements in X 
%  using the logistic regression model in the file myModel.mat, 
%  and then returns class labels in label.

%n = size(X,1);
%label = coder.nullcopy(cell(n,1));

%Mdl = loadLearnerForCoder('myModel');
%probability = predict(Mdl,X);

%index = ~isnan(probability).*((probability<0.5)+1) + isnan(probability)*3;

%classInfo = coder.load('ModelParameters');
%classNames = classInfo.classNames;

%for i = 1:n    
%    label{i} = classNames{index(i)};
%end
%end

% Note: If you create a logistic regression model in Classification Learner after using feature selection or principal component analysis (PCA), you must include additional lines of code in your entry-point function.
% For an example that shows these additional steps, see Code Generation and Classification Learner App.

% Generate a MEX function from classifyX.m.
% Create a matrix data for code generation using coder.typeof.
% Specify that the number of rows in data is arbitrary, but that data must have p columns, where p is the number of predictors used to train the logistic regression model.
% Use the -args option to specify data as an argument.
data = coder.typeof(X,[Inf p],[1 0]);
codegen classifyX.m -args data    

% codegen generates the MEX file classifyX_mex.mex64 in your current folder.
% The file extension depends on your platform.
% Verify that the MEX function returns the expected labels.
% Randomly draw 15 observations from X.
rng('default') % For reproducibility
testX = datasample(X,15);

% Classify the observations by using the predictFcn function in the classification model trained in Classification Learner.
testLabels = trainedLogisticRegressionModel.predictFcn(testX);

% Classify the observations by using the generated MEX function classifyX_mex.
testLabelsMEX = classifyX_mex(testX);

% Compare the sets of predictions.
% isequal returns logical 1 (true) if testLabels and testLabelsMEX are equal.
isequal(testLabels,testLabelsMEX)

% predictFcn and the MEX function classifyX_mex return the same values.

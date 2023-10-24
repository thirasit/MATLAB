%% Linear Regression Workflow
% This example shows how to fit a linear regression model.
% A typical workflow involves the following: import data, fit a regression, test its quality, modify it to improve the quality, and share it.

%%% Step 1. Import the data into a table.
% hospital.xls is an Excel® spreadsheet containing patient names, sex, age, weight, blood pressure, and dates of treatment in an experimental protocol.
% First read the data into a table.
patients = readtable('hospital.xls','ReadRowNames',true);

% Examine the five rows of data.
patients(1:5,:)

% The sex and smoke fields seem to have two choices each.
% So change these fields to categorical.
patients.smoke = categorical(patients.smoke,0:1,{'No','Yes'});
patients.sex = categorical(patients.sex);

%%% Step 2. Create a fitted model.
% Your goal is to model the systolic pressure as a function of a patient's age, weight, sex, and smoking status.
% Create a linear formula for 'sys' as a function of 'age', 'wgt', 'sex', and 'smoke' .
modelspec = 'sys ~ age + wgt + sex + smoke';
mdl = fitlm(patients,modelspec)

% The sex, age, and weight predictors have rather high p-values, indicating that some of these predictors might be unnecessary.

%%% Step 3. Locate and remove outliers.
% See if there are outliers in the data that should be excluded from the fit.
% Plot the residuals.
figure
plotResiduals(mdl)

% There is one possible outlier, with a value greater than 12.
% This is probably not truly an outlier.
% For demonstration, here is how to find and remove it.
% Find the outlier.
outlier = mdl.Residuals.Raw > 12;
find(outlier)

% Remove the outlier.
mdl = fitlm(patients,modelspec,...
    'Exclude',84);

mdl.ObservationInfo(84,:)

% Observation 84 is no longer in the model.

%%% Step 4. Simplify the model.
% Try to obtain a simpler model, one with fewer predictors but the same predictive accuracy.
% step looks for a better model by adding or removing one term at a time.
% Allow step take up to 10 steps.
mdl1 = step(mdl,'NSteps',10)

% Plot the effectiveness of the simpler model on the training data.
figure
plotResiduals(mdl1)

% The residuals look about as small as those of the original model.

%%% Step 5. Predict responses to new data.
% Suppose you have four new people, aged 25, 30, 40, and 65, and the first and third smoke.
% Predict their systolic pressure using mdl1.
ages = [25;30;40;65];
smoker = {'Yes';'No';'Yes';'No'};
systolicnew = feval(mdl1,ages,smoker)

% To make predictions, you need only the variables that mdl1 uses.

%%% Step 6. Share the model.
% You might want others to be able to use your model for prediction.
% Access the terms in the linear model.
coefnames = mdl1.CoefficientNames

% View the model formula.
mdl1.Formula

% Access the coefficients of the terms.
coefvals = mdl1.Coefficients(:,1).Estimate

% The model is sys = 115.1066 + 0.1078*age + 10.0540*smoke, where smoke is 1 for a smoker, and 0 otherwise.

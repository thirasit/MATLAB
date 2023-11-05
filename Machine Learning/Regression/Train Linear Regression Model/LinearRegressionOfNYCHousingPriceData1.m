%% Train Linear Regression Model
% Statistics and Machine Learning Toolbox™ provides several features for training a linear regression model.
% - For greater accuracy on low-dimensional through medium-dimensional data sets, use fitlm. After fitting the model, you can use the object functions to improve, evaluate, and visualize the fitted model. To regularize a regression, use lasso or ridge.
% - For reduced computation time on high-dimensional data sets, use fitrlinear. This function offers useful options for cross-validation, regularization, and hyperparameter optimization.

% This example shows the typical workflow for linear regression analysis using fitlm.
% The workflow includes preparing a data set, fitting a linear regression model, evaluating and improving the fitted model, and predicting response values for new predictor data.
% The example also describes how to fit and evaluate a linear regression model for tall arrays.

%%% Prepare Data
% Load the sample data set NYCHousing2015.
load NYCHousing2015

% The data set includes 10 variables with information on the sales of properties in New York City in 2015.
% This example uses some of these variables to analyze the sale prices.

% Instead of loading the sample data set NYCHousing2015, you can download the data from the NYC Open Data website and import the data as follows.
%folder = 'Annualized_Rolling_Sales_Update';
%ds = spreadsheetDatastore(folder,"TextType","string","NumHeaderLines",4);
%ds.Files = ds.Files(contains(ds.Files,"2015"));
%ds.SelectedVariableNames = ["BOROUGH","NEIGHBORHOOD","BUILDINGCLASSCATEGORY","RESIDENTIALUNITS", ...
%    "COMMERCIALUNITS","LANDSQUAREFEET","GROSSSQUAREFEET","YEARBUILT","SALEPRICE","SALEDATE"];
%NYCHousing2015 = readall(ds);

% Preprocess the data set to choose the predictor variables of interest.
% First, change the variable names to lowercase for readability.
NYCHousing2015.Properties.VariableNames = lower(NYCHousing2015.Properties.VariableNames);

% Next, convert the saledate variable, specified as a datetime array, into two numeric columns MM (month) and DD (day), and remove the saledate variable.
% Ignore the year values because all samples are for the year 2015.
[~,NYCHousing2015.MM,NYCHousing2015.DD] = ymd(NYCHousing2015.saledate);
NYCHousing2015.saledate = [];

% The numeric values in the borough variable indicate the names of the boroughs.
% Change the variable to a categorical variable using the names.
NYCHousing2015.borough = categorical(NYCHousing2015.borough,1:5, ...
    ["Manhattan","Bronx","Brooklyn","Queens","Staten Island"]);

% The neighborhood variable has 254 categories.
% Remove this variable for simplicity.
NYCHousing2015.neighborhood = [];

% Convert the buildingclasscategory variable to a categorical variable, and explore the variable by using the wordcloud function.
NYCHousing2015.buildingclasscategory = categorical(NYCHousing2015.buildingclasscategory);
wordcloud(NYCHousing2015.buildingclasscategory);

% Assume that you are interested only in one-, two-, and three-family dwellings.
% Find the sample indices for these dwellings and delete the other samples.
% Then, change the data type of the buildingclasscategory variable to double.
idx = ismember(string(NYCHousing2015.buildingclasscategory), ...
    ["01  ONE FAMILY DWELLINGS","02  TWO FAMILY DWELLINGS","03  THREE FAMILY DWELLINGS"]);
NYCHousing2015 = NYCHousing2015(idx,:);
NYCHousing2015.buildingclasscategory = renamecats(NYCHousing2015.buildingclasscategory, ...
    ["01  ONE FAMILY DWELLINGS","02  TWO FAMILY DWELLINGS","03  THREE FAMILY DWELLINGS"], ...
    ["1","2","3"]);
NYCHousing2015.buildingclasscategory = double(NYCHousing2015.buildingclasscategory);

% The buildingclasscategory variable now indicates the number of families in one dwelling.

% Explore the response variable saleprice using the summary function.
s = summary(NYCHousing2015);
s.saleprice

% Assume that a saleprice less than or equal to $1000 indicates ownership transfer without a cash consideration.
% Remove the samples that have this saleprice.
idx0 = NYCHousing2015.saleprice <= 1000;
NYCHousing2015(idx0,:) = [];

% Create a histogram of the saleprice variable.
histogram(NYCHousing2015.saleprice)

% The maximum value of saleprice is 3.7×10^7, but most values are smaller than 0.5×10^7.
% You can identify the outliers of saleprice by using the isoutlier function.
idx = isoutlier(NYCHousing2015.saleprice);

% Remove the identified outliers and create the histogram again.
NYCHousing2015(idx,:) = [];
histogram(NYCHousing2015.saleprice)

% Partition the data set into a training set and test set by using cvpartition.
rng('default') % For reproducibility
c = cvpartition(height(NYCHousing2015),"holdout",0.3);
trainData = NYCHousing2015(training(c),:);
testData = NYCHousing2015(test(c),:);

%%% Train Model
% Fit a linear regression model by using the fitlm function.
mdl = fitlm(trainData,"PredictorVars",["borough","grosssquarefeet", ...
    "landsquarefeet","buildingclasscategory","yearbuilt","MM","DD"], ...
    "ResponseVar","saleprice")

% mdl is a LinearModel object. The model display includes the model formula, estimated coefficients, and summary statistics.

% borough is a categorical variable that has five categories: Manhattan, Bronx, Brooklyn, Queens, and Staten Island.
% The fitted model mdl has four indicator variables.
% The fitlm function uses the first category Manhattan as a reference level, so the model does not include the indicator variable for the reference level.
% fitlm fixes the coefficient of the indicator variable for the reference level as zero.
% The coefficient values of the four indicator variables are relative to Manhattan.
% For more details on how the function treats a categorical predictor, see Algorithms of fitlm.

% To learn how to interpret the values in the model display, see Interpret Linear Regression Results.

% You can use the properties of a LinearModel object to investigate a fitted linear regression model.
% The object properties include information about coefficient estimates, summary statistics, fitting method, and input data.
% For example, you can find the R-squared and adjusted R-squared values in the Rsquared property.
% You can access the property values through the Workspace browser or using dot notation.
mdl.Rsquared

% The model display also shows these values.
% The R-squared value indicates that the model explains approximately 24% of the variability in the response variable.
% See Properties of a LinearModel object for details about other properties.

%%% Evaluate Model
% The model display shows the p-value of each coefficient.
% The p-values indicate which variables are significant to the model.
% For the categorical predictor borough, the model uses four indicator variables and displays four p-values.
% To examine the categorical variable as a group of indicator variables, use the object function anova.
% This function returns analysis of variance (ANOVA) statistics of the model.
anova(mdl)

% The p-values for the indicator variables borough_Brooklyn and borough_Queens are large, but the p-value of the borough variable as a group of four indicator variables is almost zero, which indicates that the borough variable is statistically significant.

% The p-values of buildingclasscategory and DD are larger than 0.05, which indicates that these variables are not significant at the 5% significance level.
% Therefore, you can consider removing these variables.
% You can also use coeffCI, coeefTest, and dwTest to further evaluate the fitted model.
% - coefCI returns confidence intervals of the coefficient estimates.
% - coefTest performs a linear hypothesis test on the model coefficients.
% - dwtest performs the Durbin-Watson test. (This test is used for time series data, so dwtest is not appropriate for the housing data in this example.)

%%% Visualize Model and Summary Statistics
% A LinearModel object provides multiple plotting functions.
% - When creating a model, use plotAdded to understand the effect of adding or removing a predictor variable.
% - When verifying a model, use plotDiagnostics to find questionable data and to understand the effect of each observation. Also, use plotResiduals to analyze the residuals of the model.
% - After fitting a model, use plotAdjustedResponse, plotPartialDependence, and plotEffects to understand the effect of a particular predictor. Use plotInteraction to examine the interaction effect between two predictors. Also, use plotSlice to plot slices through the prediction surface.

% In addition, plot creates an added variable plot for the whole model, except the intercept term, if mdl includes multiple predictor variables.
figure
plot(mdl)

% This plot is equivalent to plotAdded(mdl).
% The fitted line represents how the model, as a group of variables, can explain the response variable.
% The slope of the fitted line is not close to zero, and the confidence bound does not include a horizontal line, indicating that the model fits better than a degenerate model consisting of only a constant term.
% The test statistic value shown in the model display (F-statistic vs. constant model) also indicates that the model fits better than the degenerate model.

% Create an added variable plot for the insignificant variables buildingclasscategory and DD.
% The p-values of these variables are larger than 0.05.
% First, find the indices of these coefficients in mdl.CoefficientNames.
mdl.CoefficientNames

% buildingclasscategory and DD are the 6th and 11th coefficients, respectively.
% Create an added plot for these two variables.
figure
plotAdded(mdl,[6,11])

% The slope of the fitted line is close to zero, indicating that the information from the two variables does not explain the part of the response values not explained by the other predictors.
% For more details about an added variable plot, see Added Variable Plot.

% Create a histogram of the model residuals.
% plotResiduals plots a histogram of the raw residuals using probability density function scaling.
figure
plotResiduals(mdl)

% The histogram shows that a few residuals are smaller than −1×10^6.
% Identify these outliers.
find(mdl.Residuals.Raw < -1*10^6)

% Alternatively, you can find the outliers by using isoutlier.
% Specify the 'grubbs' option to apply Grubbs' test.
% This option is suitable for a normally distributed data set.
find(isoutlier(mdl.Residuals.Raw,'grubbs'))

% The isoutlier function does not identify residual 13894 as an outlier.
% This residual is close to –1×10^6.
% Display the residual value.
mdl.Residuals.Raw(13894)

% You can exclude outliers when fitting a linear regression model by using the Exclude name-value pair argument.
% In this case, the example adjusts the fitted model and checks whether the improved model can also explain the outliers.

%%% Adjust Model
% Remove the DD and buildingclasscategory variables using removeTerms.
newMdl1 = removeTerms(mdl,"DD + buildingclasscategory")

% Because the two variables are not significant in explaining the response variable, the R-squared and adjusted R-squared values of newMdl1 are close to the values of mdl.

% Improve the model by adding or removing variables using step.
% The default upper bound of the model is a model containing an intercept term, the linear term for each predictor, and all products of pairs of distinct predictors (no squared terms), and the default lower bound is a model containing an intercept term.
% Specify the maximum number of steps to take as 30.
% The function stops when no single step improves the model.
newMdl2 = step(newMdl1,'NSteps',30)

% The R-squared and adjusted R-squared values of newMdl2 are larger than the values of newMdl1.
% Create a histogram of the model residuals by using plotResiduals.
figure
plotResiduals(newMdl2)

% The residual histogram of newMdl2 is symmetric, without outliers.
% You can also use addTerms to add specific terms.
% Alternatively, you can use stepwiselm to specify terms in a starting model and continue improving the model by using stepwise regression.

%%% Predict Responses to New Data
% Predict responses to the test data set testData by using the fitted model newMdl2 and the object function predict to
ypred = predict(newMdl2,testData);

% Plot the residual histogram of the test data set.
figure
errs = ypred - testData.saleprice;
histogram(errs)
title("Histogram of residuals - test data")

% The residual values have a few outliers.
errs(isoutlier(errs,'grubbs'))

%%% Analyze Using Tall Arrays
% The fitlm function supports tall arrays for out-of-memory data, with some limitations.
% For tall data, fitlm returns a CompactLinearModel object that contains most of the same properties as a LinearModel object.
% The main difference is that the compact object is sensitive to memory requirements.
% The compact object does not have properties that include the data, or that include an array of the same size as the data.
% Therefore, some LinearModel object functions that require data do not work with a compact model.
% See Object Functions for the list of supported object functions.
% Also, see Tall Arrays for the usage notes and limitations of fitlm for tall arrays.

% When you perform calculations on tall arrays, MATLAB® uses either a parallel pool (default if you have Parallel Computing Toolbox™) or the local MATLAB session.
% If you want to run the example using the local MATLAB session when you have Parallel Computing Toolbox, you can change the global execution environment by using the mapreducer function.

% Assume that all the data in the datastore ds does not fit in memory.
% You can use tall instead of readall to read ds.
%NYCHousing2015 = tall(ds);

% For this example, convert the in-memory table NYCHousing2015 to a tall table by using the tall function.
NYCHousing2015_t = tall(NYCHousing2015);

% Partition the data set into a training set and test set.
% When you use cvpartition with tall arrays, the function partitions the data set based on the variable supplied as the first input argument.
% For classification problems, you typically use the response variable (a grouping variable) and create a random stratified partition to get even distribution between training and test sets for all groups.
% For regression problems, this stratification is not adequate, and you can use the 'Stratify' name-value pair argument to turn off the option.

% In this example, specify the predictor variable NYCHousing2015_t.borough as the first input argument to make the distribution of boroughs roughly the same across the training and tests sets.
% For reproducibility, set the seed of the random number generator using tallrng.
% The results can vary depending on the number of workers and the execution environment for the tall arrays.
% For details, see Control Where Your Code Runs.
tallrng('default') % For reproducibility
c = cvpartition(NYCHousing2015_t.borough,"holdout",0.3);
trainData_t = NYCHousing2015_t(training(c),:);
testData_t = NYCHousing2015_t(test(c),:);

% Because fitlm returns a compact model object for tall arrays, you cannot improve the model using the step function.
% Instead, you can explore the model parameters by using the object functions and then adjust the model as needed.
% You can also gather a subset of the data into the workspace, use stepwiselm to iteratively develop the model in memory, and then scale up to use tall arrays.
% For details, see Model Development of Statistics and Machine Learning with Big Data Using Tall Arrays.

% In this example, fit a linear regression model using the model formula of newMdl2.
mdl_t = fitlm(trainData_t,newMdl2.Formula)

% mdl_t is a CompactLinearModel object. mdl_t is not exactly the same as newMdl2 because the partitioned training data set obtained from the tall table is not the same as the one from the in-memory data set.

% You cannot use the plotResiduals function to create a histogram of the model residuals because mdl_t is a compact object.
% Instead, compute the residuals directly from the compact object and create the histogram using histogram.
figure
mdl_t_Residual = trainData_t.saleprice - predict(mdl_t,trainData_t);
histogram(mdl_t_Residual)
title("Histogram of residuals - train data")

% Predict responses to the test data set testData_t by using predict.
ypred_t = predict(mdl_t,testData_t);

% Plot the residual histogram of the test data set.
figure
errs_t = ypred_t - testData_t.saleprice;
histogram(errs_t)
title("Histogram of residuals - test data")

% You can further assess the fitted model using the CompactLinearModel object functions.
% For an example, see Assess and Adjust Model of Statistics and Machine Learning with Big Data Using Tall Arrays.

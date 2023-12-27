%% Assess Regression Neural Network Performance
% Create a feedforward regression neural network model with fully connected layers using fitrnet.
% Use validation data for early stopping of the training process to prevent overfitting the model.
% Then, use the object functions of the model to assess its performance on test data.

%%% Load Sample Data
% Load the carbig data set, which contains measurements of cars made in the 1970s and early 1980s.
load carbig

% Convert the Origin variable to a categorical variable.
% Then create a table containing the predictor variables Acceleration, Displacement, and so on, as well as the response variable MPG.
% Each row contains the measurements for a single car.
% Delete the rows of the table in which the table has missing values.
Origin = categorical(cellstr(Origin));
Tbl = table(Acceleration,Displacement,Horsepower, ...
    Model_Year,Origin,Weight,MPG);
Tbl = rmmissing(Tbl);

%%% Partition Data
% Split the data into training, validation, and test sets.
% First, reserve approximately one third of the observations for the test set.
% Then, split the remaining data in half to create the training and validation sets.
rng("default") % For reproducibility of the data partitions
cvp1 = cvpartition(size(Tbl,1),"Holdout",1/3);
testTbl = Tbl(test(cvp1),:);
remainingTbl = Tbl(training(cvp1),:);

cvp2 = cvpartition(size(remainingTbl,1),"Holdout",1/2);
validationTbl = remainingTbl(test(cvp2),:);
trainTbl = remainingTbl(training(cvp2),:);

%%% Train Neural Network
% Train a regression neural network model by using the training set.
% Specify the MPG column of tblTrain as the response variable, and standardize the numeric predictors.
% Evaluate the model at each iteration by using the validation set.
% Specify to display the training information at each iteration by using the Verbose name-value argument.
% By default, the training process ends early if the validation loss is greater than or equal to the minimum validation loss computed so far, six times in a row.
% To change the number of times the validation loss is allowed to be greater than or equal to the minimum, specify the ValidationPatience name-value argument.
Mdl = fitrnet(trainTbl,"MPG","Standardize",true, ...
    "ValidationData",validationTbl, ...
    "Verbose",1);

% Use the information inside the TrainingHistory property of the object Mdl to check the iteration that corresponds to the minimum validation mean squared error (MSE).
% The final returned model Mdl is the model trained at this iteration.
iteration = Mdl.TrainingHistory.Iteration;
valLosses = Mdl.TrainingHistory.ValidationLoss;
[~,minIdx] = min(valLosses);
iteration(minIdx)

%%% Evaluate Test Set Performance
% Evaluate the performance of the trained model Mdl on the test set testTbl by using the loss and predict object functions.
% Compute the test set mean squared error (MSE).
% Smaller MSE values indicate better performance.
mse = loss(Mdl,testTbl,"MPG")

% Compare the predicted test set response values to the true response values.
% Plot the predicted miles per gallon (MPG) along the vertical axis and the true MPG along the horizontal axis.
% Points on the reference line indicate correct predictions.
% A good model produces predictions that are scattered near the line.
predictedY = predict(Mdl,testTbl);

figure
plot(testTbl.MPG,predictedY,".")
hold on
plot(testTbl.MPG,testTbl.MPG)
hold off
xlabel("True Miles Per Gallon (MPG)")
ylabel("Predicted Miles Per Gallon (MPG)")

% Use box plots to compare the distribution of predicted and true MPG values by country of origin.
% Create the box plots by using the boxchart function.
% Each box plot displays the median, the lower and upper quartiles, any outliers (computed using the interquartile range), and the minimum and maximum values that are not outliers.
% In particular, the line inside each box is the sample median, and the circular markers indicate outliers.

% For each country of origin, compare the red box plot (showing the distribution of predicted MPG values) to the blue box plot (showing the distribution of true MPG values).
% Similar distributions for the predicted and true MPG values indicate good predictions.
figure
boxchart(testTbl.Origin,testTbl.MPG)
hold on
boxchart(testTbl.Origin,predictedY)
hold off
legend(["True MPG","Predicted MPG"])
xlabel("Country of Origin")
ylabel("Miles Per Gallon (MPG)")

% For most countries, the predicted and true MPG values have similar distributions.
% Some discrepancies are possibly due to the small number of cars in the training and test sets.

% Compare the range of MPG values for cars in the training and test sets.
trainSummary = grpstats(trainTbl(:,["MPG","Origin"]),"Origin", ...
    "range")

testSummary = grpstats(testTbl(:,["MPG","Origin"]),"Origin", ...
    "range")

% For countries like France, Italy, and Sweden, which have few cars in the training and test sets, the range of the MPG values varies significantly in both sets.

% Plot the test set residuals.
% A good model usually has residuals scattered roughly symmetrically around 0.
% Clear patterns in the residuals are a sign that you can improve your model.
figure
residuals = testTbl.MPG - predictedY;
plot(testTbl.MPG,residuals,".")
hold on
yline(0)
hold off
xlabel("True Miles Per Gallon (MPG)")
ylabel("MPG Residuals")

% The plot suggests that the residuals are well distributed.

% You can obtain more information about the observations with the greatest residuals, in terms of absolute value.
[~,residualIdx] = sort(residuals,"descend", ...
    "ComparisonMethod","abs");
residuals(residualIdx)

% Display the three observations with the greatest residuals, that is, with magnitudes greater than 8.
testTbl(residualIdx(1:3),:)

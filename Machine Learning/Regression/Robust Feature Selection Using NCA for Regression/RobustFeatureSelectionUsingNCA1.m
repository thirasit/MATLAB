%% Robust Feature Selection Using NCA for Regression
% Perform feature selection that is robust to outliers using a custom robust loss function in NCA.

%%% Generate data with outliers
% Generate sample data for regression where the response depends on three of the predictors, namely predictors 4, 7, and 13.
rng(123,'twister') % For reproducibility
n = 200;
X = randn(n,20);
y = cos(X(:,7)) + sin(X(:,4).*X(:,13)) + 0.1*randn(n,1);

% Add outliers to data.
numoutliers = 25;
outlieridx = floor(linspace(10,90,numoutliers));
y(outlieridx) = 5*randn(numoutliers,1);

% Plot the data.
figure
plot(y)

%%% Use non-robust loss function
% The performance of the feature selection algorithm highly depends on the value of the regularization parameter.
% A good practice is to tune the regularization parameter for the best value to use in feature selection.
% Tune the regularization parameter using five-fold cross validation.
% Use the mean squared error (MSE):
figure
imshow("Opera Snapshot_2024-01-02_081226_www.mathworks.com.png")
axis off;

% First, partition the data into five folds.
% In each fold, the software uses 4/5th of the data for training and 1/5th of the data for validation (testing).
cvp = cvpartition(length(y),'kfold',5);
numtestsets = cvp.NumTestSets;

% Compute the lambda values to test for and create an array to store the loss values.
lambdavals = linspace(0,3,50)*std(y)/length(y);
lossvals = zeros(length(lambdavals),numtestsets);

% Perform NCA and compute the loss for each λ value and each fold.
for i = 1:length(lambdavals)
    for k = 1:numtestsets        
        Xtrain = X(cvp.training(k),:);
        ytrain = y(cvp.training(k),:);
        Xtest = X(cvp.test(k),:);
        ytest = y(cvp.test(k),:);
        
        nca = fsrnca(Xtrain,ytrain,'FitMethod','exact', ...
            'Solver','lbfgs','Verbose',0,'Lambda',lambdavals(i), ...
            'LossFunction','mse');
        
        lossvals(i,k) = loss(nca,Xtest,ytest,'LossFunction','mse');
    end
end

% Plot the mean loss corresponding to each lambda value.
figure
meanloss = mean(lossvals,2);
plot(lambdavals,meanloss,'ro-')
xlabel('Lambda')
ylabel('Loss (MSE)')
grid on

% Find the λ value that produces the minimum average loss.
[~,idx] = min(mean(lossvals,2));
bestlambda = lambdavals(idx)

% Perform feature selection using the best λ value and MSE.
nca = fsrnca(X,y,'FitMethod','exact','Solver','lbfgs', ...
    'Verbose',1,'Lambda',bestlambda,'LossFunction','mse');

% Plot selected features.
figure
plot(nca.FeatureWeights,'ro')
grid on
xlabel('Feature index')
ylabel('Feature weight')

% Predict the response values using the nca model and plot the fitted (predicted) response values and the actual response values.
figure
fitted = predict(nca,X);
plot(y,'r.')
hold on
plot(fitted,'b-')
xlabel('index')
ylabel('Fitted values')

% fsrnca tries to fit every point in data including the outliers.
% As a result it assigns nonzero weights to many features besides predictors 4, 7, and 13.

%%% Use built-in robust loss function
figure
imshow("Opera Snapshot_2024-01-02_081538_www.mathworks.com.png")
axis off;

lambdavals = linspace(0,3,50)*std(y)/length(y);
cvp = cvpartition(length(y),'kfold',5);
numtestsets = cvp.NumTestSets;
lossvals = zeros(length(lambdavals),numtestsets);

for i = 1:length(lambdavals)
    for k = 1:numtestsets     
        Xtrain = X(cvp.training(k),:);
        ytrain = y(cvp.training(k),:);
        Xtest = X(cvp.test(k),:);
        ytest = y(cvp.test(k),:);
        
        nca = fsrnca(Xtrain,ytrain,'FitMethod','exact', ...
            'Solver','sgd','Verbose',0,'Lambda',lambdavals(i), ...
            'LossFunction','epsiloninsensitive','Epsilon',0.8);
        
        lossvals(i,k) = loss(nca,Xtest,ytest,'LossFunction','mse');
    end
end

% The ϵ value to use depends on the data and the best value can be determined using cross-validation as well.
% But choosing the ϵ value is out of scope of this example.
% The choice of ϵ in this example is mainly for illustrating the robustness of the method.

% Plot the mean loss corresponding to each lambda value.
figure
meanloss = mean(lossvals,2);
plot(lambdavals,meanloss,'ro-')
xlabel('Lambda')
ylabel('Loss (MSE)')
grid on

% Find the lambda value that produces the minimum average loss.
[~,idx] = min(mean(lossvals,2));
bestlambda = lambdavals(idx)

% Fit neighborhood component analysis model using ϵ-insensitive loss function and best lambda value.
nca = fsrnca(X,y,'FitMethod','exact','Solver','sgd', ...
    'Lambda',bestlambda,'LossFunction','epsiloninsensitive','Epsilon',0.8);

% Plot selected features.
figure
plot(nca.FeatureWeights,'ro')
grid on
xlabel('Feature index')
ylabel('Feature weight')

% Plot fitted values.
figure
fitted = predict(nca,X);
plot(y,'r.')
hold on
plot(fitted,'b-')
xlabel('index')
ylabel('Fitted values')

% ϵ-insensitive loss seems more robust to outliers.
% It identified fewer features than MSE as relevant.
% The fit shows that it is still impacted by some of the outliers.

%%% Use custom robust loss function
% Define a custom robust loss function that is robust to outliers to use in feature selection for regression:

figure
imshow("Opera Snapshot_2024-01-02_081909_www.mathworks.com.png")
axis off;

customlossFcn = @(yi,yj) 1 - exp(-abs(yi-yj'));

% Tune the regularization parameter using the custom-defined robust loss function.
lambdavals = linspace(0,3,50)*std(y)/length(y);
cvp = cvpartition(length(y),'kfold',5);
numtestsets = cvp.NumTestSets;
lossvals = zeros(length(lambdavals),numtestsets);

for i = 1:length(lambdavals)
    for k = 1:numtestsets
        Xtrain = X(cvp.training(k),:);
        ytrain = y(cvp.training(k),:);
        Xtest = X(cvp.test(k),:);
        ytest = y(cvp.test(k),:);
        
        nca = fsrnca(Xtrain,ytrain,'FitMethod','exact', ...
            'Solver','lbfgs','Verbose',0,'Lambda',lambdavals(i), ...
            'LossFunction',customlossFcn);
        
        lossvals(i,k) = loss(nca,Xtest,ytest,'LossFunction','mse');
    end
end

% Plot the mean loss corresponding to each lambda value.
figure
meanloss = mean(lossvals,2);
plot(lambdavals,meanloss,'ro-')
xlabel('Lambda')
ylabel('Loss (MSE)')
grid on

% Find the λ value that produces the minimum average loss.
[~,idx] = min(mean(lossvals,2));
bestlambda = lambdavals(idx)

% Perform feature selection using the custom robust loss function and best λ value.
nca = fsrnca(X,y,'FitMethod','exact','Solver','lbfgs', ...
    'Verbose',1,'Lambda',bestlambda,'LossFunction',customlossFcn);

% Plot selected features.
figure
plot(nca.FeatureWeights,'ro')
grid on
xlabel('Feature index')
ylabel('Feature weight')

% Plot fitted values.
figure
fitted = predict(nca,X);
plot(y,'r.')
hold on
plot(fitted,'b-')
xlabel('index')
ylabel('Fitted values')

% In this case, the loss is not affected by the outliers and results are based on most of the observation values.
% fsrnca detects the predictors 4, 7, and 13 as relevant features and does not select any other features.

%%% Why does the loss function choice affect the results?
% First, compute the loss functions for a series of values for the difference between two observations.
deltay = linspace(-10,10,1000)';

% Compute custom loss function values.
customlossvals = customlossFcn(deltay,0); 

% Compute epsilon insensitive loss function and values.
epsinsensitive = @(yi,yj,E) max(0,abs(yi-yj')-E); 
epsinsenvals = epsinsensitive(deltay,0,0.5);

% Compute MSE loss function and values.
mse = @(yi,yj) (yi-yj').^2;
msevals = mse(deltay,0);

% Now, plot the loss functions to see their difference and why they affect the results in the way they do.
figure
plot(deltay,customlossvals,'g-',deltay,epsinsenvals,'b-',deltay,msevals,'r-')
xlabel('(yi - yj)')
ylabel('loss(yi,yj)')
legend('customloss','epsiloninsensitive','mse')
ylim([0 20])

% As the difference between two response values increases, MSE increases quadratically, which makes it very sensitive to outliers.
% As fsrnca tries to minimize this loss, it ends up identifying more features as relevant.
% The epsilon insensitive loss is more resistant to outliers than MSE, but eventually it does start to increase linearly as the difference between two observations increase.
% As the difference between two observations increase, the robust loss function does approach 1 and stays at that value even though the difference between the observations keeps increasing.
% Out of three, it is the most robust to outliers.

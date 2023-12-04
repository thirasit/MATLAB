%% Nonlinear Logistic Regression
% This example shows two ways of fitting a nonlinear logistic regression model.
% The first method uses maximum likelihood (ML) and the second method uses generalized least squares (GLS) via the function fitnlm from Statistics and Machine Learning Toolbox™.

%%% Problem Description
% Logistic regression is a special type of regression in which the goal is to model the probability of something as a function of other variables.
% Consider a set of predictor vectors x_1,…,x_N where N is the number of observations and x_i is a column vector containing the values of the d predictors for the i th observation.
% The response variable for x_i is Z_i where Z_i represents a Binomial random variable with parameters n, the number of trials, and μ_i, the probability of success for trial i.
% The normalized response variable is Y_i=Z_i/n - the proportion of successes in n trials for observation i. Assume that responses Y_i are independent for i=1,…,N. For each i:

figure
imshow("Opera Snapshot_2023-12-02_060402_www.mathworks.com.png")
axis off;

%%% Direct Maximum Likelihood (ML)
% The ML approach maximizes the log likelihood of the observed data.
% The likelihood is easily computed using the Binomial probability (or density) function as computed by the binopdf function.

%%% Generalized Least Squares (GLS)
% You can estimate a nonlinear logistic regression model using the function fitnlm.
% This might seem surprising at first since fitnlm does not accommodate Binomial distribution or any link functions.
% However, fitnlm can use Generalized Least Squares (GLS) for model estimation if you specify the mean and variance of the response.
% If GLS converges, then it solves the same set of nonlinear equations for estimating β as solved by ML.
% You can also use GLS for quasi-likelihood estimation of generalized linear models.
% In other words, we should get the same or equivalent solutions from GLS and ML.
% To implement GLS estimation, provide the nonlinear function to fit, and the variance function for the Binomial distribution.

figure
imshow("Opera Snapshot_2023-12-02_060611_www.mathworks.com.png")
axis off;

%%% Generate Example Data
% To illustrate the differences between ML and GLS fitting, generate some example data.
% Assume that x_i is one dimensional and suppose the true function f in the nonlinear logistic regression model is the Michaelis-Menten model parameterized by a 2×1 vector β:

figure
imshow("Opera Snapshot_2023-12-02_060708_www.mathworks.com.png")
axis off;

myf = @(beta,x) beta(1)*x./(beta(2) + x);

% Create a model function that specifies the relationship between μ_i and β.
mymodelfun = @(beta,x) 1./(1 + exp(-myf(beta,x)));

% Create a vector of one dimensional predictors and the true coefficient vector β.
rng(300,'twister');
x    = linspace(-1,1,200)';
beta = [10;2];

% Compute a vector of μ_i values for each predictor.
mu = mymodelfun(beta,x);

% Generate responses z_i from a Binomial distribution with success probabilities μ_i and number of trials n.
n = 50;
z = binornd(n,mu);

% Normalize the responses.
y = z./n;

%%% ML Approach
% The ML approach defines the negative log likelihood as a function of the β vector, and then minimizes it with an optimization function such as fminsearch.
% Specify beta0 as the starting value for β.
mynegloglik = @(beta) -sum(log(binopdf(z,n,mymodelfun(beta,x))));
beta0 = [3;3];
opts = optimset('fminsearch');
opts.MaxFunEvals = Inf;
opts.MaxIter = 10000;
betaHatML = fminsearch(mynegloglik,beta0,opts)

% The estimated coefficients in betaHatML are close to the true values of [10;2].

%%% GLS Approach
% The GLS approach creates a weight function for fitnlm previously described.
wfun = @(xx) n./(xx.*(1-xx));

% Call fitnlm with custom mean and weight functions.
% Specify beta0 as the starting value for β.
nlm = fitnlm(x,y,mymodelfun,beta0,'Weights',wfun)

% Get an estimate of β from the fitted NonLinearModel object nlm.
betaHatGLS = nlm.Coefficients.Estimate

% As in the ML method, the estimated coefficients in betaHatGLS are close to the true values of [10;2].
% The small p-values for both β_1 and β_2 indicate that both coefficients are significantly different from 0.

%%% Compare ML and GLS Approaches
% Compare estimates of β.
max(abs(betaHatML - betaHatGLS))

% Compare fitted values using ML and GLS
yHatML  = mymodelfun(betaHatML ,x);
yHatGLS = mymodelfun(betaHatGLS,x);
max(abs(yHatML - yHatGLS))

% ML and GLS approaches produce similar solutions.

%%% Plot fitted values using ML and GLS
figure
plot(x,y,'g','LineWidth',1)
hold on
plot(x,yHatML ,'b'  ,'LineWidth',1)
plot(x,yHatGLS,'m--','LineWidth',1)
legend('Data','ML','GLS','Location','Best')
xlabel('x')
ylabel('y and fitted values')
title('Data y along with ML and GLS fits.')

% ML and GLS produce similar fitted values.

%%% Plot estimated nonlinear function using ML and GLS
% Plot true model for f(x_i,β).
% Add plot for the initial estimate of f(x_i,β) using β=β_0 and plots for ML and GLS based estimates of f(x_i,β).
figure
plot(x,myf(beta,x),'r','LineWidth',1)
hold on
plot(x,myf(beta0,x),'k','LineWidth',1)
plot(x,myf(betaHatML,x),'c--','LineWidth',1)
plot(x,myf(betaHatGLS,x),'b-.','LineWidth',1)
legend('True f','Initial f','Estimated f with ML', ...
    'Estimated f with GLS','Location','Best')
xlabel('x')
ylabel('True and estimated f')
title('Comparison of true f with estimated f using ML and GLS.')

% The estimated nonlinear function f using both ML and GLS methods is close to the true nonlinear function f.
% You can use a similar technique to fit other nonlinear generalized linear models like nonlinear Poisson regression.

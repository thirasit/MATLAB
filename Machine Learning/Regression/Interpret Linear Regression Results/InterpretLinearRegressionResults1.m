%% Interpret Linear Regression Results
% This example shows how to display and interpret linear regression output statistics.

%%% Fit Linear Regression Model
% Load the carsmall data set, a matrix input data set.
load carsmall
X = [Weight,Horsepower,Acceleration];

% Fit a linear regression model by using fitlm.
lm = fitlm(X,MPG)

% The model display includes the model formula, estimated coefficients, and model summary statistics.

% The model formula in the display, y ~ 1 + x1 + x2 + x3, corresponds to y=β_0+β_1X_1+β_2X_2+β_3X_3+ϵ.

% The model display shows the estimated coefficient information, which is stored in the Coefficients property.
% Display the Coefficients property.
lm.Coefficients

% The Coefficient property includes these columns:
% - Estimate — Coefficient estimates for each corresponding term in the model. For example, the estimate for the constant term (intercept) is 47.977.
% - SE — Standard error of the coefficients.
% - tStat — t-statistic for each coefficient to test the null hypothesis that the corresponding coefficient is zero against the alternative that it is different from zero, given the other predictors in the model. Note that tStat = Estimate/SE. For example, the t-statistic for the intercept is 47.977/3.8785 = 12.37.
% - pValue — p-value for the t-statistic of the two-sided hypothesis test. For example, the p-value of the t-statistic for x2 is greater than 0.05, so this term is not significant at the 5% significance level given the other terms in the model.

% The summary statistics of the model are:
% - Number of observations — Number of rows without any NaN values. For example, Number of observations is 93 because the MPG data vector has six NaN values and the Horsepower data vector has one NaN value for a different observation, where the number of rows in X and MPG is 100.
% - Error degrees of freedom — n – p, where n is the number of observations, and p is the number of coefficients in the model, including the intercept. For example, the model has four predictors, so the Error degrees of freedom is 93 – 4 = 89.
% - Root mean squared error — Square root of the mean squared error, which estimates the standard deviation of the error distribution.
% - R-squared and Adjusted R-squared — Coefficient of determination and adjusted coefficient of determination, respectively. For example, the R-squared value suggests that the model explains approximately 75% of the variability in the response variable MPG.
% - F-statistic vs. constant model — Test statistic for the F-test on the regression model, which tests whether the model fits significantly better than a degenerate model consisting of only a constant term.
% - p-value — p-value for the F-test on the model. For example, the model is significant with a p-value of 7.3816e-27.

%%% ANOVA
% Perform analysis of variance (ANOVA) for the model.
anova(lm,'summary')

% This anova display shows the following.
% - SumSq — Sum of squares for the regression model, Model, the error term, Residual, and the total, Total.
% - DF — Degrees of freedom for each term. Degrees of freedom is n−1 for the total, p−1 for the model, and n−p for the error term, where n is the number of observations, and p is the number of coefficients in the model, including the intercept. For example, MPG data vector has six NaN values and one of the data vectors, Horsepower, has one NaN value for a different observation, so the total degrees of freedom is 93 – 1 = 92. There are four coefficients in the model, so the model DF is 4 – 1 = 3, and the DF for error term is 93 – 4 = 89.
% - MeanSq — Mean squared error for each term. Note that MeanSq = SumSq/DF. For example, the mean squared error for the error term is 1488.8/89 = 16.728. The square root of this value is the root mean squared error in the linear regression display, or 4.09.
% - F — F-statistic value, which is the same as F-statistic vs. constant model in the linear regression display. In this example, it is 89.987, and in the linear regression display this F-statistic value is rounded up to 90.
% - pValue — p-value for the F-test on the model. In this example, it is 7.3816e-27.

% If there are higher-order terms in the regression model, anova partitions the model SumSq into the part explained by the higher-order terms and the rest.
% The corresponding F-statistics are for testing the significance of the linear terms and higher-order terms as separate groups.

% If the data includes replicates, or multiple measurements at the same predictor values, then the anova partitions the error SumSq into the part for the replicates and the rest.
% The corresponding F-statistic is for testing the lack-of-fit by comparing the model residuals with the model-free variance estimate computed on the replicates.

% Decompose ANOVA table for model terms.
anova(lm)

% This anova display shows the following:
% - First column — Terms included in the model.
% - SumSq — Sum of squared error for each term except for the constant.
% - DF — Degrees of freedom. In this example, DF is 1 for each term in the model and n−p for the error term, where n is the number of observations, and p is the number of coefficients in the model, including the intercept. For example, the DF for the error term in this model is 93 – 4 = 89. If any of the variables in the model is a categorical variable, the DF for that variable is the number of indicator variables created for its categories (number of categories – 1).
% - MeanSq — Mean squared error for each term. Note that MeanSq = SumSq/DF. For example, the mean squared error for the error term is 1488.8/89 = 16.728.
% - F — F-values for each coefficient. The F-value is the ratio of the mean squared of each term and mean squared error, that is, F = MeanSq(xi)/MeanSq(Error). Each F-statistic has an F distribution, with the numerator degrees of freedom, DF value for the corresponding term, and the denominator degrees of freedom, n−p. n is the number of observations, and p is the number of coefficients in the model. In this example, each F-statistic has an F_(1,89) distribution.
% - pValue — p-value for each hypothesis test on the coefficient of the corresponding term in the linear model. For example, the p-value for the F-statistic coefficient of x2 is 0.08078, and is not significant at the 5% significance level given the other terms in the model.

%%% Coefficient Confidence Intervals
% Display coefficient confidence intervals.
coefCI(lm)

% The values in each row are the lower and upper confidence limits, respectively, for the default 95% confidence intervals for the coefficients.
% For example, the first row shows the lower and upper limits, 40.2702 and 55.6833, for the intercept, β_0.
% Likewise, the second row shows the limits for β_1 and so on.
% Confidence intervals provide a measure of precision for linear regression coefficient estimates.
% A 100(1−α)% confidence interval gives the range the corresponding regression coefficient will be in with 100(1−α)% confidence.

% You can also change the confidence level.
% Find the 99% confidence intervals for the coefficients.
coefCI(lm,0.01)

%%% Hypothesis Test on Coefficients
% Test the null hypothesis that all predictor variable coefficients are equal to zero versus the alternate hypothesis that at least one of them is different from zero.
[p,F,d] = coefTest(lm)

% Here, coefTest performs an F-test for the hypothesis that all regression coefficients (except for the intercept) are zero versus at least one differs from zero, which essentially is the hypothesis on the model.
% It returns p, the p-value, F, the F-statistic, and d, the numerator degrees of freedom.
% The F-statistic and p-value are the same as the ones in the linear regression display and anova for the model.
% The degrees of freedom is 4 – 1 = 3 because there are four predictors (including the intercept) in the model.

% Now, perform a hypothesis test on the coefficients of the first and second predictor variables.
H = [0 1 0 0; 0 0 1 0];
[p,F,d] = coefTest(lm,H)

% The numerator degrees of freedom is the number of coefficients tested, which is 2 in this example.
% The results indicate that at least one of β_2 and β_3 differs from zero.

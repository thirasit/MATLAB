%% Linear Mixed-Effects Model Workflow
% This example shows how to fit and analyze a linear mixed-effects model (LME).
%%% Load the sample data.
load flu

% The flu dataset array has a Date variable, and 10 variables containing estimated influenza rates (in 9 different regions, estimated from Google® searches, plus a nationwide estimate from the CDC).

%%% Reorganize and plot the data.
% To fit a linear-mixed effects model, your data must be in a properly formatted dataset array.
% To fit a linear mixed-effects model with the influenza rates as the responses, combine the nine columns corresponding to the regions into an array.
% The new dataset array, flu2, must have the response variable FluRate, the nominal variable Region that shows which region each estimate is from, the nationwide estimate WtdILI, and the grouping variable Date.
flu2 = stack(flu,2:10,'NewDataVarName','FluRate',...
    'IndVarName','Region');
flu2.Date = nominal(flu2.Date);

% Define flu2 as a table.
flu2 = dataset2table(flu2);

% Plot flu rates versus the nationwide estimate.
figure
plot(flu2.WtdILI,flu2.FluRate,'ro')
xlabel('WtdILI')
ylabel('Flu Rate')

% You can see that the flu rates in regions have a direct relationship with the nationwide estimate.

%%% Fit an LME model and interpret the results.
% Fit a linear mixed-effects model with the nationwide estimate as the predictor variable and a random intercept that varies by Date.
lme = fitlme(flu2,'FluRate ~ 1 + WtdILI + (1|Date)')

% The small $p$-values of 0.0045885 and 3.0502e-76 indicate that both the intercept and nationwide estimate are significant.
% Also, the confidence limits for the standard deviation of the random-effects term, $\sigma_{b}$, do not include 0 (0.13227, 0.22226), which indicates that the random-effects term is significant.

% Plot the raw residuals versus the fitted values.
figure();
plotResiduals(lme,'fitted')

% The variance of residuals increases with increasing fitted response values, which is known as heteroscedasticity.
% Find the two observations on the top right that appear like outliers.
find(residuals(lme) > 1.5)

% Refit the model by removing these observations.
lme = fitlme(flu2,'FluRate ~ 1 + WtdILI + (1|Date)','Exclude',[98,107]);

%%% Improve the model.
% Determine if including an independent random term for the nationwide estimate grouped by Date improves the model.
altlme = fitlme(flu2,'FluRate ~ 1 + WtdILI + (1|Date) + (WtdILI-1|Date)',...
'Exclude',[98,107])

% The estimated standard deviation of WtdILI term is nearly 0 and its confidence interval cannot be computed.
% This is an indication that the model is overparameterized and the (WtdILI-1|Date) term is not significant.
% You can formally test this using the compare method as follows: compare(lme,altlme,'CheckNesting',true).

% Add a random effects-term for intercept grouped by Region to the initial model lme.
lme2 = fitlme(flu2,'FluRate ~ 1 + WtdILI + (1|Date) + (1|Region)',...
'Exclude',[98,107]);

% Compare the models lme and lme2.
compare(lme,lme2,'CheckNesting',true)

% The $p$-value of 0 indicates that lme2 is a better fit than lme.
% Now, check if adding a potentially correlated random-effects term for the intercept and national average improves the model lme2.
lme3 = fitlme(flu2,'FluRate ~ 1 + WtdILI + (1|Date) + (1 + WtdILI|Region)',...
'Exclude',[98,107])

% The estimate for the standard deviation of the random-effects term for intercept grouped by Region is 0.0077037, its confidence interval is very large and includes zero.
% This indicates that the random-effects for intercept grouped by Region is insignificant.
% The correlation between the random-effects for intercept and WtdILI is -0.059604.
% Its confidence interval is also very large and includes zero.
% This is an indication that the correlation is not significant.

% Refit the model by eliminating the intercept from the (1 + WtdILI | Region) random-effects term.
lme3 = fitlme(flu2,'FluRate ~ 1 + WtdILI + (1|Date) + (WtdILI - 1|Region)',...
'Exclude',[98,107])

% All terms in the new model lme3 are significant.
% Compare lme2 and lme3.
compare(lme2,lme3,'CheckNesting',true,'NSim',100)

% The $p$-value of 0.009901 indicates that lme3 is a better fit than lme2.
% Add a quadratic fixed-effects term to the model lme3.
lme4 = fitlme(flu2,'FluRate ~ 1 + WtdILI^2 + (1|Date) + (WtdILI - 1|Region)',...
'Exclude',[98,107])

% The $p$-value of 0.028463 indicates that the coefficient of the quadratic term WtdILI^2 is significant.

%%% Plot the fitted response versus the observed response and residuals.
F = fitted(lme4);
R = response(lme4);
figure();
plot(R,F,'rx')
xlabel('Response')
ylabel('Fitted')

% The fitted versus observed response values form almost 45-degree angle indicating a good fit.
% Plot the residuals versus the fitted values.
figure();
plotResiduals(lme4,'fitted')

% Although it has improved, you can still see some heteroscedasticity in the model.
% This might be due to another predictor that does not exist in the data set, hence not in the model.

%%% Find the fitted flu rate value for region ENCentral, date 11/6/2005.
F(flu2.Region == 'ENCentral' & flu2.Date == '11/6/2005')

%%% Randomly generate response values.
% Randomly generate response values for a national estimate of 1.625, region MidAtl, and date 4/23/2006.
% First, define the new table.
% Because Date and Region are nominal in the original table, you must define them similarly in the new table.
tblnew.Date = nominal('4/23/2006');
tblnew.WtdILI = 1.625;
tblnew.Region = nominal('MidAtl');
tblnew = struct2table(tblnew);

% Now, generate the response value.
random(lme4,tblnew)

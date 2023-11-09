%% Accelerate Linear Model Fitting on GPU
% This example shows how you can accelerate regression model fitting by running functions on a graphical processing unit (GPU).
% The example compares the time required to fit a model on a central processing unit (CPU) with the time required to fit the same model on a GPU.
% Using a GPU requires Parallel Computing Toolbox™ and a supported GPU device.
% For information about supported devices, see GPU Computing Requirements (Parallel Computing Toolbox).

% Create a table of airline sample data from the file airlinesmall.csv by using the readtable function.
% Remove table rows corresponding to cancelled flights, and convert UniqueCarrier to a categorical variable using the categorical function.
A = readtable("\toolbox\matlab\demos\airlinesmall.csv");
A = A(A.Cancelled~=1,:);
A.UniqueCarrier = categorical(A.UniqueCarrier)

% The table A contains data for 12,1171 flights.
% The table variables Year, Month, and DayofMonth contain data for the year, month, and day that each flight departed, respectively.
% ArrDelay contains the delay in minutes between each flight's scheduled and actual arrival time.
% UniqueCarrier contains data for the airline that operated each flight.

%%% Measure Time to Fit Linear Model on CPU
% Measure the time required to fit a linear regression model on a CPU to the predictor variables Year, Month, DayofMonth, and UniqueCarrier, and the response variable ArrDelay.
% This example uses an Intel(R) Xeon(R) CPU E5-2623 v4 @ 2.60GHz.
% Create a second table from the table A variables Year, Month, DayofMonth, UniqueCarrier, and ArrDelay.
tblCPU = table(A.Year,A.Month,A.DayofMonth,A.UniqueCarrier,A.ArrDelay,VariableNames=["Year" "Month" "DayofMonth" "UniqueCarrier" "ArrDelay"])

% Create an anonymous function that uses the fitlm function to fit a linear regression model to the variables in tblCPU.
% Measure the time required to run the anonymous function by using the timeit function.
cpufit = @() fitlm(tblCPU,CategoricalVars=4);
tcpu = timeit(cpufit)

% tcpu contains the time required to fit the linear regression model on the CPU.

%%% Measure Time to Fit Linear Model on GPU
% Verify that a GPU device is available by using the gpuDevice (Parallel Computing Toolbox) function.
gpuDevice

% The output shows that this example uses an NVIDIA GeForce RTX 2080 SUPER GPU.
% Create a third table from the table tblCPU variables.
% Copy the table's numeric and logical variables to GPU memory by using the gpuArray (Parallel Computing Toolbox) function.
tblGPU = tblCPU;
for ii = 1:width(tblCPU)
    if isnumeric(tblCPU.(ii)) || islogical(tblCPU.(ii))
        tblGPU.(ii) = gpuArray(tblCPU.(ii));
    end
end

tblGPU

% The tblGPU table contains gpuArray objects, each representing an array stored in GPU memory.

% When you pass gpuArray inputs to the fitlm function, it automatically runs on the GPU.
% Measure the time required to fit the regression model on the GPU by using the gputimeit (Parallel Computing Toolbox) function.
% This function is preferable to timeit, because it ensures that all operations on the GPU are complete before it records the time.
% The function also compensates for the overhead of working on a GPU.
gpufit = @() fitlm(tblGPU,CategoricalVars=4);
tgpu = gputimeit(gpufit)

% tgpu contains the time required to fit the linear regression model on the GPU, which is over three times faster than on the CPU.

%%% Determine Statistical Significance
% To investigate the statistical significance of the linear regression model terms, fit the regression model on the GPU.
mdl = fitlm(tblGPU,CategoricalVars=4)

% mdl contains the formula for the linear regression model and statistics about the estimated model coefficients.
% The table output contains a row for each continuous term and for each value in UniqueCarrier.
% You can determine if a term or value has a statistically significant effect on the arrival delay by comparing its p-value to the significance level of 0.05.

% To determine whether UniqueCarrier contains a value that has a statistically significant effect on the arrival delay, perform an ANOVA with a 95% confidence level by using the function anova.
% When you pass gpuArray inputs to the anova function, it automatically runs on the GPU.
aov = anova(mdl)

% aov contains the results of the ANOVA.
% The p-value in the row corresponding to UniqueCarrier is smaller than the significance level of 0.05, indicating that at least one value in UniqueCarrier has a statistically significant effect on the arrival delay.

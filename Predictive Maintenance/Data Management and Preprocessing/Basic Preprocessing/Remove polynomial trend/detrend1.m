%%% Remove polynomial trend

%% Continuous Linear Trend
% Create a vector of data, and remove the continuous linear trend. 
% Plot the original data, the detrended data, and the linear trend.
t = 0:20;
A = 3*sin(t) + t;
D = detrend(A);

figure
plot(t,A)
hold on
plot(t,D)
plot(t,A-D,":k")
legend("Input Data","Detrended Data","Trend","Location","northwest")

%% Continuous Quadratic Trend
% Create a table of data, and remove the continuous quadratic trend from a specified variable in the table. 
% Plot the original data, the detrended data, and the trend.
t = (-4:4)';
trend = (t.^2 + 4*t + 3);
sig = [0 1 -2 1 0 1 -2 1 0]';
x = sig + trend;
T = table(t,trend,sig,x);
T = detrend(T,2,"DataVariables","x","SamplePoints","t","ReplaceValues",false)

figure
plot(T,"t","x")
hold on
plot(T,"t","x_detrended")
plot(T.t,T.x-T.x_detrended,":k")
legend("Input Data","Detrended Data","Trend","Location","northwest")

%% Discontinuous Linear Trend
% Create a vector of data, and remove the piecewise linear trend using a breakpoint at 0. 
% Specify that the resulting output can be discontinuous. 
% Plot the original data, the detrended data, and the trend.
t = -10:10;
A = t.^3 + 6*t.^2 + 4*t + 3;
bp = 0;
D = detrend(A,1,bp,"SamplePoints",t,"Continuous",false);

figure
plot(t,A)
hold on
plot(t,D)
plot(t,A-D,":k")
legend("Input Data","Detrended Data","Trend","Location","northwest")

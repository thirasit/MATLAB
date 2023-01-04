%%% Smooth noisy data

%% Smooth Data with Moving Average
% Create a vector containing noisy data, and smooth the data with a moving average. Plot the original and smoothed data.
figure
x = 1:100;
A = cos(2*pi*0.05*x+2*pi*rand) + 0.5*randn(1,100);
B = smoothdata(A);
plot(x,A,'-o',x,B,'-x')
legend('Original Data','Smoothed Data')

%% Matrix of Noisy Data
% Create a matrix whose rows represent three noisy signals. Smooth the three signals using a moving average, and plot the smoothed data.
figure
x = 1:100;
s1 = cos(2*pi*0.03*x+2*pi*rand) + 0.5*randn(1,100);
s2 = cos(2*pi*0.04*x+2*pi*rand) + 0.4*randn(1,100) + 5;
s3 = cos(2*pi*0.05*x+2*pi*rand) + 0.3*randn(1,100) - 5;
A = [s1; s2; s3];
B = smoothdata(A,2);
plot(x,B(1,:),x,B(2,:),x,B(3,:))

%% Gaussian Filter
% Smooth a vector of noisy data with a Gaussian-weighted moving average filter. Display the window length used by the filter.
x = 1:100;
A = cos(2*pi*0.05*x+2*pi*rand) + 0.5*randn(1,100);
[B,window] = smoothdata(A,'gaussian');
window

% Smooth the original data with a larger window of length 20. Plot the smoothed data for both window lengths.
figure
C = smoothdata(A,'gaussian',20);
plot(x,B,'-o',x,C,'-x')
legend('Small Window','Large Window')

%% Vector with NaN
% Create a noisy vector containing NaN values, and smooth the data ignoring NaN, which is the default.
A = [NaN randn(1,48) NaN randn(1,49) NaN];
B = smoothdata(A);

% Smooth the data including NaN values. The average in a window containing NaN is NaN.
C = smoothdata(A,'includenan');

% Plot the smoothed data in B and C.
figure
plot(1:100,B,'-o',1:100,C,'-x')
legend('Ignore NaN','Include NaN')

%% Smooth Data with Sample Points
% Create a vector of noisy data that corresponds to a time vector t. Smooth the data relative to the times in t, and plot the original data and the smoothed data.
figure
x = 1:100;
A = cos(2*pi*0.05*x+2*pi*rand) + 0.5*randn(1,100);
t = datetime(2017,1,1,0,0,0) + hours(0:99);
B = smoothdata(A,'SamplePoints',t);
plot(t,A,'-o',t,B,'-x')
legend('Original Data','Smoothed Data')

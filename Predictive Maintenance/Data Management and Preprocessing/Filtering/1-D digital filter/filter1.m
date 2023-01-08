%%% 1-D digital filter

%% Moving-Average Filter
% A moving-average filter is a common method used for smoothing noisy data. This example uses the filter function to compute averages along a vector of data.
% Create a 1-by-100 row vector of sinusoidal data that is corrupted by random noise.
t = linspace(-pi,pi,100);
rng default  %initialize random number generator
x = sin(t) + 0.25*rand(size(t));

% A moving-average filter slides a window of length windowSize along the data, computing averages of the data contained in each window. The following difference equation defines a moving-average filter of a vector x:
% y(n)= (1/windowSize)(x(n)+x(n−1)+...+x(n−(windowSize−1))).
% For a window size of 5, compute the numerator and denominator coefficients for the rational transfer function.
windowSize = 5; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;

% Find the moving average of the data and plot it against the original data.
y = filter(b,a,x);
figure
plot(t,x)
hold on
plot(t,y)
legend('Input Data','Filtered Data')

%% Filter Matrix Rows
% This example filters a matrix of data with the following rational transfer functio

figure
imshow("Opera Snapshot_2023-01-08_065551_www.mathworks.com.png")

% Create a 2-by-15 matrix of random input data.
rng default  %initialize random number generator
x = rand(2,15);

% Define the numerator and denominator coefficients for the rational transfer function.
b = 1;
a = [1 -0.2];

% Apply the transfer function along the second dimension of x and return the 1-D digital filter of each row. Plot the first row of original data against the filtered data.
y = filter(b,a,x,[],2);
t = 0:length(x)-1;  %index vector
figure
plot(t,x(1,:))
hold on
plot(t,y(1,:))
legend('Input Data','Filtered Data')
title('First Row')

% Plot the second row of input data against the filtered data.
figure
plot(t,x(2,:))
hold on
plot(t,y(2,:))
legend('Input Data','Filtered Data')
title('Second Row')

%% Filter Data in Sections
% Use initial and final conditions for filter delays to filter data in sections, especially if memory limitations are a consideration.
% Generate a large random data sequence and split it into two segments, x1 and x2.
x = randn(10000,1);
x1 = x(1:5000);
x2 = x(5001:end);

% The whole sequence, x, is the vertical concatenation of x1 and x2.
% Define the numerator and denominator coefficients for the rational transfer function,

figure
imshow("Opera Snapshot_2023-01-08_065843_www.mathworks.com.png")

b = [2,3];
a = [1,0.2];

% Filter the subsequences x1 and x2 one at a time. Output the final conditions from filtering x1 to store the internal status of the filter at the end of the first segment.
[y1,zf] = filter(b,a,x1);

% Use the final conditions from filtering x1 as initial conditions to filter the second segment, x2.
y2 = filter(b,a,x2,zf);

% y1 is the filtered data from x1, and y2 is the filtered data from x2. The entire filtered sequence is the vertical concatenation of y1 and y2.
% Filter the entire sequence simultaneously for comparison.
y = filter(b,a,x);
isequal(y,[y1;y2])

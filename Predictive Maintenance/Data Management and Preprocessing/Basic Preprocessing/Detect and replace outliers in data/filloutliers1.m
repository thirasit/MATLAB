%%% Detect and replace outliers in data

%% Interpolate Outliers in Vector
% Fill outliers in a vector of data using the "linear" method, and visualize the filled data.
% Create a vector of data containing two outliers.
A = [57 59 60 100 59 58 57 58 300 61 62 60 62 58 57];

% Replace the outliers using linear interpolation.
B = filloutliers(A,"linear");

% Plot the original data and the data with the outliers filled.
figure
plot(A)
hold on
plot(B,"o-")
legend("Original Data","Filled Data")

%% Use Mean Detection and Nearest Fill Methods
% Identify potential outliers in a table of data, fill any outliers using the "nearest" fill method, and visualize the cleaned data.
% Create a timetable of data, and visualize the data to detect potential outliers.
T = hours(1:15);
V = [57 59 60 100 59 58 57 58 300 61 62 60 62 58 57];
A = timetable(T',V');
figure
plot(A.Time,A.Var1)

% Fill outliers in the data, where an outlier is defined as a point more than three standard deviations from the mean. Replace the outlier with the nearest element that is not an outlier.
B = filloutliers(A,"nearest","mean")

% In the same graph, plot the original data and the data with the outlier filled.
hold on
plot(B.Time,B.Var1,"o-")
legend("Original Data","Filled Data")

%% Use Moving Detection Method
% Use a moving median to detect and fill local outliers within a sine wave that corresponds to a time vector.
% Create a vector of data containing a local outlier.
x = -2*pi:0.1:2*pi;
A = sin(x);
A(47) = 0;

% Create a time vector that corresponds to the data in A.
t = datetime(2017,1,1,0,0,0) + hours(0:length(x)-1);

% Define outliers as points more than three local scaled MAD from the local median within a sliding window. Find the location of the outlier in A relative to the points in t with a window size of 5 hours. Fill the outlier with the computed threshold value using the method "clip".
[B,TF,L,U,C] = filloutliers(A,"clip","movmedian",hours(5),"SamplePoints",t);

% Plot the original data and the data with the outlier filled.
figure
plot(t,A)
hold on
plot(t,B,"o-")
legend("Original Data","Filled Data")

%% Fill Outliers in Matrix Rows
% Create a matrix of data containing outliers along the diagonal.
A = randn(5,5) + diag(1000*ones(1,5))

% Fill outliers with zeros based on the data in each row, and display the new values.
[B,TF] = filloutliers(A,0,2);
B

% You can access the detected outlier values and their filled values using TF as an index vector.
[A(TF) B(TF)]

%% Specify Outlier Locations
% Create a vector containing two outliers and detect their locations.
A = [57 59 60 100 59 58 57 58 300 61 62 60 62 58 57];
detect = isoutlier(A)

% Fill the outliers using the "nearest" method. Instead of using a detection method, provide the outlier locations detected by isoutlier.
B = filloutliers(A,"nearest","OutlierLocations",detect)

%% Return Outlier Thresholds
% Replace the outlier in a vector of data using the "clip" fill method.
% Create a vector of data with an outlier.
A = [60 59 49 49 58 100 61 57 48 58];

% Detect outliers with the default method "median", and replace the outlier with the upper threshold value by using the "clip" fill method.
[B,TF,L,U,C] = filloutliers(A,"clip");

% Plot the original data, the data with the outlier filled, and the thresholds and center value determined by the outlier detection method. 
% The center value is the median of the data, and the upper and lower thresholds are three scaled MAD above and below the median.
figure
plot(A)
hold on
plot(B,"o-")
yline([L U C],":",["Lower Threshold","Upper Threshold","Center Value"])
legend("Original Data","Filled Data")

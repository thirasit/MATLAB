%%% Fill missing values

%% Vector with NaN Values
% Create a vector that contains NaN values, and replace each NaN with the previous nonmissing value.
A = [1 3 NaN 4 NaN NaN 5];
F = fillmissing(A,'previous')

%% Matrix with NaN Values
% Create a 2-by-2 matrix with a NaN value in each column. Fill NaN with 100 in the first column and 1000 in the second column.
A = [1 NaN; NaN 2]

F = fillmissing(A,'constant',[100 1000])

%% Interpolate Missing Data
% Use interpolation to replace NaN values in nonuniformly sampled data.
% Define a vector of nonuniform sample points and evaluate the sine function over the points.
x = [-4*pi:0.1:0, 0.1:0.2:4*pi];
A = sin(x);

% Inject NaN values into A.
A(A < 0.75 & A > 0.5) = NaN;

% Fill the missing data using linear interpolation, and return the filled vector F and the logical vector TF. The value 1 (true) in entries of TF corresponds to the values of F that were filled.
[F,TF] = fillmissing(A,'linear','SamplePoints',x);

% Plot the original data and filled data.
figure
scatter(x,A)
hold on
scatter(x(TF),F(TF))
legend('Original Data','Filled Data')

%% Use Moving Median Method
% Use a moving median to fill missing numeric data.

% Create a vector of sample points x and a vector of data A that contains missing values.
x = linspace(0,10,200); 
A = sin(x) + 0.5*(rand(size(x))-0.5); 
A([1:10 randi([1 length(x)],1,50)]) = NaN; 

% Replace NaN values in A using a moving median with a window of length 10, and plot the original data and the filled data.
figure
F = fillmissing(A,'movmedian',10);  
plot(x,F,'.-') 
hold on
plot(x,A,'.-')
legend('Original Data','Filled Data')

%% Use Custom Fill Method
% Define a custom function to fill NaN values with the previous nonmissing value.
% Define a vector of sample points t and a vector of corresponding data A containing NaN values. Plot the data.
figure
t = 10:10:100;
A = [0.1 0.2 0.3 NaN NaN 0.6 0.7 NaN 0.9 1];
scatter(t,A)

% Use the local function forwardfill (defined at the end of the example) to fill missing gaps with the previous nonmissing value. The function handle inputs include:
% - xs — data values used for filling
% - ts — locations of the values used for filling relative to the sample points
% - tq — locations of the missing values relative to the sample points
% - n — number of values in the gap to fill
n = 2;
gapwindow = [10 0];

[F,TF] = fillmissing(A,@(xs,ts,tq) forwardfill(xs,ts,tq,n),gapwindow,'SamplePoints',t);

% The gap window value [10 0] tells fillmissing to consider one data point before a missing gap and no data points after a gap, since the previous nonmissing value is located 10 units prior to the gap. The function handle input values determined by fillmissing for the first gap are:
% - xs = 0.3
% - ts = 30
% - tq = [40 50]
% The function handle input values for the second gap are:
% - xs = 0.7
% - ts = 70
% - tq = 80

% Plot the original data and the filled data
figure
scatter(t,A)
hold on
scatter(t(TF),F(TF))

%% Matrix with Missing Endpoints
% Create a matrix with missing entries and fill across the columns (second dimension) one row at a time using linear interpolation. 
% For each row, fill leading and trailing missing values with the nearest nonmissing value in that row.
A = [NaN NaN 5 3 NaN 5 7 NaN 9 NaN;
     8 9 NaN 1 4 5 NaN 5 NaN 5;
     NaN 4 9 8 7 2 4 1 1 NaN]

F = fillmissing(A,'linear',2,'EndValues','nearest')

%% Table with Multiple Data Types
% Fill missing values for table variables with different data types.
% Create a table whose variables include categorical, double, and char data types.
A = table(categorical({'Sunny'; 'Cloudy'; ''}),[66; NaN; 54],{''; 'N'; 'Y'},[37; 39; NaN],...
    'VariableNames',{'Description' 'Temperature' 'Rain' 'Humidity'})

% Replace all missing entries with the value from the previous entry. Since there is no previous element in the Rain variable, the missing character vector is not replaced.
F = fillmissing(A,'previous')

% Replace the NaN values from the Temperature and Humidity variables in A with 0.
F = fillmissing(A,'constant',0,'DataVariables',{'Temperature','Humidity'})

% Alternatively, use the isnumeric function to identify the numeric variables to operate on.
F = fillmissing(A,'constant',0,'DataVariables',@isnumeric)

% Now fill the missing values in A with a specified constant for each table variable, which are contained in a cell array.
F = fillmissing(A,'constant',{categorical({'None'}),1000,'Unknown',1000})

%% Specify Maximum Gap
% Create a time vector t in seconds and a corresponding vector of data A that contains NaN values.
t = seconds([2 4 8 17 98 134 256 311 1001]);
A = [1 3 23 NaN NaN NaN 100 NaN 233];

% Fill only missing values in A that correspond to a maximum gap size of 250 seconds. Because the second gap is larger than 250 seconds, the NaN value is not filled.
F = fillmissing(A,'linear','SamplePoints',t,'MaxGap',seconds(250))

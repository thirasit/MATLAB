%%% Create tall array

%% Create Tall Array
% Convert a datastore into a tall array.
% First, create a datastore for the data set. 
% You can specify either a full or relative file location for the data set using datastore(location) to create the datastore. 
% The location argument can specify:
% - A single file, such as 'airlinesmall.csv'
% - Several files with the same extension, such as '*.csv'
% - An entire folder of files, such as 'C:\MyData'
% tabularTextDatastore also has several options to specify file and text format properties when you create the datastore.
% Create a datastore for the airlinesmall.csv data set. Treat 'NA' values as missing data so that they are replaced with NaN values. Select a small subset of the variables to work with.
varnames = {'ArrDelay', 'DepDelay', 'Origin', 'Dest'};
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA', ...
    'SelectedVariableNames', varnames);

% Use tall to create a tall array for the data in the datastore. 
% Since the data in ds is tabular, the result is a tall table. 
% If the data is not tabular, then tall creates a tall cell array instead.
T = tall(ds)

% You can use many common MATLAB® operators and functions to work with tall arrays. 
% To see if a function works with tall arrays, check the Extended Capabilities section at the bottom of the function reference page.

%% Calculate Size of Tall Array
% Convert a datastore into a tall table, calculate its size using a deferred calculation, and then perform the calculation and return the result in memory.
% First, create a datastore for the airlinesmall.csv data set. 
% Treat 'NA' values as missing data so that they are replaced with NaN values. 
% Set the text format of a few columns so that they are read as a cell array of character vectors. 
% Convert the datastore into a tall table.
ds = tabularTextDatastore('airlinesmall.csv', 'TreatAsMissing', 'NA');
ds.SelectedFormats{strcmp(ds.SelectedVariableNames, 'TailNum')} = '%s';
ds.SelectedFormats{strcmp(ds.SelectedVariableNames, 'CancellationCode')} = '%s';

T = tall(ds)

% The display of the tall table indicates that MATLAB® does not yet know how many rows of data are in the table.
% Calculate the size of the tall table. 
% Since calculating the size of a tall array requires a full pass through the data, MATLAB does not immediately calculate the value. 
% Instead, like most operations with tall arrays, the result is an unevaluated tall array whose values and size are currently unknown.
s = size(T)

% Use the gather function to perform the deferred calculation and return the result in memory. 
% The result returned by size is a trivially small 1-by-2 vector, which fits in memory.
sz = gather(s)

% If you use gather on an unreduced tall array, then the result might not fit in memory. 
% If you are unsure whether the result returned by gather can fit in memory, use gather(head(X)) or gather(tail(X)) to bring only a small portion of the calculation result into memory.

%% Convert In-Memory Arrays to Tall Arrays
% Create an in-memory array of random numbers, and then convert it into a tall array. 
% Creating tall arrays from in-memory arrays in this manner is useful for debugging or prototyping new programs. 
% The in-memory array is still bound by normal memory constraints, and even after it is converted into a tall array it cannot grow beyond the limits of memory.
A = rand(100,4);
tA = tall(A)

% In R2019b and later releases, when you convert in-memory arrays into tall arrays, you can perform calculations on the array without requiring extra memory for temporary copies of the data. 
% For example, this code normalizes the data in a large matrix and then calculates the sum of all the rows and columns. 
% An in-memory version of this calculation needs to not only store the array but also have enough memory available to create temporary copies of the array.
N = 5000;
tA = tall(rand(N));
tB = tA - mean(tA);
S = gather(sum(tB, [1,2]))

% If you adjust the value of N so that there is enough memory to store tA, but not enough memory for copies, the calculation still executes successfully.

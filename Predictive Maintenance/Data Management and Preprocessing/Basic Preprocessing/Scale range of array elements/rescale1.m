%%% Scale range of array elements

%% Scale to Unit Interval
% Scale the entries of a vector to the interval [0,1].
A = 1:5;
B = rescale(A)

%% Scale to Specified Range
% Scale the elements of a vector to the interval [-1,1].
A = 1:5;
B = rescale(A,-1,1)

%% Scale Matrix Columns and Rows
% Scale each column of a matrix to the interval [0,1] by specifying the minimum and maximum of each column. rescale scales along the dimension of the input array that corresponds with the shape of the 'InputMin' and 'InputMax' parameter values.
A = magic(3)
colmin = min(A)
colmax = max(A)
Bcol = rescale(A,'InputMin',colmin,'InputMax',colmax)

% Scale each row of A to the interval [0,1].
rowmin = min(A,[],2)
rowmax = max(A,[],2)
Brow = rescale(A,'InputMin',rowmin,'InputMax',rowmax)

%%% Moving mean

%% Centered Moving Average of Vector
% Compute the three-point centered moving average of a row vector. When there are fewer than three elements in the window at the endpoints, take the average over the elements that are available.
A = [4 8 6 -1 -2 -3 -1 3 4 5];
M = movmean(A,3)

%% Trailing Moving Average of Vector
% Compute the three-point trailing moving average of a row vector. When there are fewer than three elements in the window at the endpoints, take the average over the elements that are available.
A = [4 8 6 -1 -2 -3 -1 3 4 5];
M = movmean(A,[2 0])

%% Moving Average of Matrix
% Compute the three-point centered moving average for each row of a matrix. The window starts on the first row, slides horizontally to the end of the row, then moves to the second row, and so on. The dimension argument is two, which slides the window across the columns of A.
A = [4 8 6; -1 -2 -3; -1 3 4]
M = movmean(A,3,2)

%% Moving Average of Vector with NaN Elements
% Compute the three-point centered moving average of a row vector containing two NaN elements.
A = [4 8 NaN -1 -2 -3 NaN 3 4 5];
M = movmean(A,3)

% Recalculate the average, but omit the NaN values. When movmean discards NaN elements, it takes the average over the remaining elements in the window.
M = movmean(A,3,'omitnan')

%% Sample Points for Moving Average
% Compute a 3-hour centered moving average of the data in A according to the time vector t.
A = [4 8 6 -1 -2 -3];
k = hours(3);
t = datetime(2016,1,1,0,0,0) + hours(0:5)

M = movmean(A,k,'SamplePoints',t)

%% Return Only Full-Window Averages
% Compute the three-point centered moving average of a row vector, but discard any calculation that uses fewer than three points from the output. In other words, return only the averages computed from a full three-element window, discarding endpoint calculations.
A = [4 8 6 -1 -2 -3 -1 3 4 5];
M = movmean(A,3,'Endpoints','discard')

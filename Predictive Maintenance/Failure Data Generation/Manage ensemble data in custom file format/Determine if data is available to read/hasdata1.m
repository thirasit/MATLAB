%% Determine if data is available to read

% Create a datastore from the sample file, mapredout.mat, which is the output file of the mapreduce function.
ds = datastore('mapredout.mat');

% While there is data available in the datastore, read the data.
while hasdata(ds)
    T = read(ds);
end

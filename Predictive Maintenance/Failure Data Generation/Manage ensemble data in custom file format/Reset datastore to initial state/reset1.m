%% Reset datastore to initial state

% Create a datastore from the sample file, mapredout.mat, which is the output file of the mapreduce function.
ds = datastore('mapredout.mat');

% Read the first key-value pair.
T = read(ds);

% Reset the datastore to the state where no data has been read from it.
reset(ds)

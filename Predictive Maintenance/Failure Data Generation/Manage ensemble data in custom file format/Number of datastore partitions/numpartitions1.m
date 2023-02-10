%%% Number of datastore partitions

%% Number of Partitions
% Create a datastore from the sample file, mapredout.mat, which is the output file of the mapreduce function.
ds = datastore('mapredout.mat');

% Get the default number of partitions.
n = numpartitions(ds)

% By default, there is only one partition in ds because it contains only one small file.
% Partition the datastore and return the datastore corresponding to the first part.
subds = partition(ds,n,1);

% Read the data in subds.
while hasdata(subds)
    data = read(subds);
end

%% Number of Partitions for Parallel Datastore Access
% Get a number of partitions to parallelize datastore access over the current parallel pool. You must have Parallel Computing Toolbox installed.
% Create a datastore from the sample file, mapredout.mat, which is the output file of the mapreduce function.
ds = datastore('mapredout.mat');

% Get a number of partitions to parallelize datastore access over the current parallel pool.
n = numpartitions(ds, gcp);

% Partition the datastore and read the data in each part.
parfor ii=1:n
    subds = partition(ds,n,ii);
    while hasdata(subds)
        data = read(subds);
    end
end

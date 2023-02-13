%%% Partition a datastore

%% Partition Datastore into Specific Number of Parts
% Create a datastore for a large collection of files. 
% For this example, use ten copies of the sample file airlinesmall.csv. 
% To handle missing fields in the tabular data, specify the name-value pairs TreatAsMissing and MissingValue.
files = repmat({'airlinesmall.csv'},1,10);
ds = tabularTextDatastore(files,...
                 'TreatAsMissing','NA','MissingValue',0);

% Partition the datastore into three parts and return the first partition. 
% The partition function returns approximately the first third of the data from the datastore ds.
subds = partition(ds,3,1)

% The Files property of the datastore contains a list of files included in the datastore. 
% Check the number of files in the Files property of the datastore ds and the partitioned datastore subds. 
% The datastore ds contains ten files and the partition subds contains the first four files.
length(ds.Files)

length(subds.Files)

%% Partition Datastore into Default Number of Parts
% Create a datastore from the sample file, mapredout.mat, which is the output file of the mapreduce function.
ds = datastore('mapredout.mat');

% Get the default number of partitions for ds.
n = numpartitions(ds);

% Partition the datastore into the default number of partitions and return the datastore corresponding to the first partition.
subds = partition(ds,n,1);

% Read the data in subds.
while hasdata(subds)
	data = read(subds);
end

%% Partition Datastore by Files
% Create a datastore that contains three image files.
ds = imageDatastore({'street1.jpg','peppers.png','corn.tif'})

% Partition the datastore by files and return the part corresponding to the second file.
subds = partition(ds,'Files',2)

% subds contains one file.

%% Partition Data in Parallel
% Create a datastore from the sample file, mapredout.mat, which is the output file of the mapreduce function.
ds = datastore('mapredout.mat');

% Partition the datastore into three parts on three workers in a parallel pool.
numWorkers = 3;
p = parpool('local',numWorkers);
n = numpartitions(ds,p);

parfor ii=1:n
    subds = partition(ds,n,ii);
    while hasdata(subds)
        data = read(subds);
    end
end

%% Compare Data Granularities
% Compare a coarse-grained partition with a fine-grained subset.
% Read all the frames in the video file xylophone.mp4 and construct an ArrayDatastore object to iterate over it. 
% The resulting object has 141 frames.
v = VideoReader("xylophone.mp4");
allFrames = read(v);
arrds = arrayDatastore(allFrames,IterationDimension=4,OutputType="cell",ReadSize=4);

% To extract a specific set of adjacent frames, create four coarse-grained partitions of arrds. 
% Extract the second partition, which has 35 frames.
partds = partition(arrds,4,2);
figure
imshow(imtile(partds.readall()))

% Extract six nonadjacent frames from arrds at specified indices using a fine-grained subset.
subds = subset(arrds,[67 79 82 69 89 33]);
figure
imshow(imtile(subds.readall()))

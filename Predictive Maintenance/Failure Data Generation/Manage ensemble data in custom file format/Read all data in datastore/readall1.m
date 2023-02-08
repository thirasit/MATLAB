%%% Read all data in datastore

%% Read All Data in ImageDatastore
% Create an ImageDatastore object containing four images.
imds = imageDatastore({'street1.jpg','street2.jpg','peppers.png','corn.tif'});

% Read all the data in the datastore.
T = readall(imds);

% Examine the output.
figure
imout = imtile(T);
imshow(imout)

%% Read All Data in TabularTextDatastore in Parallel
% Create a datastore from the sample file airlinesmall.csv, which contains tabular data.
ds = tabularTextDatastore("airlinesmall.csv",TreatAsMissing="NA");

% Specify the variables of interest using the SelectedVariableNames property.
ds.SelectedVariableNames = ["DepTime","ArrTime","ActualElapsedTime"];

% Read all the data in the datastore in parallel.
T = readall(ds,UseParallel=true);

% View information about the table. Only the selected variables are included in the output.
T.Properties

%% Read All Data in CombinedDatastore
% Create a datastore that maintains parity between the pair of images of the underlying datastores. 
% For instance, create two separate image datastores, and then create a combined datastore representing the two underlying datastores.

% Create an image datastore imds1 representing a collection of three images.
imds1 = imageDatastore({'street1.jpg','street2.jpg','peppers.png'}); 

% Create a second datastore imds2 by transforming the images of imds1 to grayscale and then downsizing the images.
imds2 = transform(imds1,@(x) imresize(im2gray(x),0.5));

% Create a combined datastore from imds1 and imds2.
imdsCombined = combine(imds1,imds2);

% Read all of the data from the combined datastore. 
% The output is a 3-by-2 cell array. 
% The two columns represent all of the read data from the two underlying datastores imds1 and imds2, respectively.
dataOut = readall(imdsCombined)

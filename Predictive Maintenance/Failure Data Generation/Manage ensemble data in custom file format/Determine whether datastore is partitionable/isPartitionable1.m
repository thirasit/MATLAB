%%% Determine whether datastore is partitionable

%% Test Partitionability of Datastores
% Create a TabularTextDatastore, and then write an if/else statement that partitions the datastore only if it is partitionable.
ttds = tabularTextDatastore('outages.csv');
if isPartitionable(ttds)
    newds = partition(ttds,3,1);
    disp('Partitioning successful.')
else 
    disp('Datastore is not partitionable.')
end

% Now create a CombinedDatastore object comprised of two copies of ttds. 
% Use the same if/else test to partition the datastore.
cds = combine(ttds,ttds);
if isPartitionable(cds)
    newds = partition(cds,3,1);
    disp('Partitioning successful.')
else 
    disp('Datastore is not partitionable.')
end

% In this case, the combined datastore cds is not partitionable because the underlying TabularTextDatastore objects do not have subset methods.
% Create another CombinedDatastore object, but this time construct it out of ImageDatastore objects. 
% In this case the combined datastore is partitionable because the underlying ImageDatastore objects have subset methods.
imageFiles = {'street1.jpg','street2.jpg','peppers.png','corn.tif'};
imds = imageDatastore(imageFiles);
cds = combine(imds,imds);
if isPartitionable(cds)
    newds = partition(cds,3,1);
    disp('Partitioning successful.')
else 
    disp('Datastore is not partitionable.')
end

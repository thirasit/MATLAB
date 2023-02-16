%%% Determine whether datastore is shuffleable

%% Test Shuffleability of Datastores
% Create an ImageDatastore, and then write an if/else statement that shuffles the datastore only if it is shuffleable.
imageFiles = {'street1.jpg','street2.jpg','peppers.png','corn.tif'};
imds = imageDatastore(imageFiles);
if isShuffleable(imds)
    newds = shuffle(imds);
    disp('Shuffling successful.')
else
    disp('Datastore is not shuffleable.')
end

% Now create a CombinedDatastore object comprised of two copies of imds. 
% Use the same if/else test to shuffle the datastore.
cds = combine(imds,imds);
if isShuffleable(cds)
    newds = shuffle(cds);
    disp('Shuffling successful.')
else
    disp('Datastore is not shuffleable.')
end

% In this case, the combined datastore cds is shuffleable because the underlying ImageDatastore objects have subset methods.

% Create another CombinedDatastore object, but this time construct it out of TabularTextDatastore objects. 
% In this case the combined datastore is not shuffleable because the underlying TabularTextDatastore objects do not have subset methods.
ttds = tabularTextDatastore('outages.csv');
cds = combine(ttds,ttds);
if isShuffleable(cds)
    newds = shuffle(cds);
    disp('Shuffling successful.')
else
    disp('Datastore is not shuffleable.')
end

%%% Manage ensemble data in custom file format

%% Create and Configure File Ensemble Datastore
% Create a file ensemble datastore for data stored in MATLAB® files, and configure it with functions that tell the software how to read from and write to the datastore.
% For this example, you have two data files containing healthy operating data from a bearing system, baseline_01.mat and baseline_02.mat. 
% You also have three data files containing faulty data from the same system, FaultData_01.mat, FaultData_02.mat, and FaultData_03.mat.
unzip fileEnsData.zip  % extract compressed files
location = pwd;
extension = '.mat';
fensemble = fileEnsembleDatastore(location,extension);

% Before you can interact with data in the ensemble, you must create functions that tell the software how to process the data files to read variables into the MATLAB workspace and to write data back to the files. Save these functions to a location on the file path. For this example, use the following supplied functions:
% - readBearingData — Extract requested variables from a structure, bearing, and other variables stored in the file. This function also parses the filename for the fault status of the data. The function returns a table row containing one table variable for each requested variable.
% - writeBearingData — Take a structure and write its variables to a data file as individual stored variables.
fensemble.ReadFcn = @readBearingData;
fensemble.WriteToMemberFcn = @writeBearingData;

% Finally, set properties of the ensemble to identify data variables, condition variables, and selected variables for reading. For this example, the variables in the data file are gs, sr, load, and rate. Suppose that you only need to read the fault label, gs, and sr. Set these variables as the selected variables.
fensemble.DataVariables = ["gs";"sr";"load";"rate"];
fensemble.ConditionVariables = ["label"];
fensemble.SelectedVariables = ["label";"gs";"sr"];

% Examine the ensemble. The functions and the variable names are assigned to the appropriate properties.
fensemble

% These functions that you assigned tell the read and writeToLastMemberRead commands how to interact with the data files that make up the ensemble. For example, when you call the read command, it uses readBearingData to read all the variables in fensemble.SelectedVariables. For a more detailed example, see File Ensemble Datastore with Measured Data.

%% Read from and Write to a File Ensemble Datastore
% Create a file ensemble datastore for data stored in MATLAB files, and configure it with functions that tell the software how to read from and write to the datastore. (For more details about configuring file ensemble datastores, see File Ensemble Datastore with Measured Data.)
% Create ensemble datastore that points to datafiles in current folder
unzip fileEnsData.zip  % extract compressed files
location = pwd;
extension = '.mat';
fensemble = fileEnsembleDatastore(location,extension);

% Specify data and condition variables
fensemble.DataVariables = ["gs";"sr";"load";"rate"];
fensemble.ConditionVariables = "label";

% Configure with functions for reading and writing variable data
addpath(fullfile(matlabroot,'examples','predmaint','main')) % Make sure functions are on path
fensemble.ReadFcn = @readBearingData;
fensemble.WriteToMemberFcn = @writeBearingData; 

% The functions tell the read and writeToLastMemberRead commands how to interact with the data files that make up the ensemble. 
% Thus, when you call the read command, it uses readBearingData to read all the variables in fensemble.SelectedVariables. 
% For this example, readBearingData extracts requested variables from a structure, bearing, and other variables stored in the file. 
% It also parses the filename for the fault status of the data.
% Specify variables to read, and read them from the first member of the ensemble.
fensemble.SelectedVariables = ["gs";"load";"label"];
data = read(fensemble)

% You can now process the data from the member as needed. For this example, compute the average value of the signal stored in the variable gs. Extract the data from the table returned by read.
gsdata = data.gs{1};
gsmean = mean(gsdata);

% You can write the mean value gsmean back to the data file as a new variable. To do so, first expand the list of data variables in the ensemble to include a variable for the new value. Call the new variable gsMean.
fensemble.DataVariables = [fensemble.DataVariables;"gsMean"]

% Next, write the derived mean value to the file corresponding to the last-read ensemble member. (See Data Ensembles for Condition Monitoring and Predictive Maintenance.) When you call writeToLastMemberRead, it converts the data to a structure and calls fensemble.WriteToMemberFcn to write the data to the file.
writeToLastMemberRead(fensemble,'gsMean',gsmean);

% Calling read again advances the last-read-member indicator to the next file in the ensemble and reads the data from that file.
data = read(fensemble)

% You can confirm that this data is from a different member by examining the load variable in the table. 
% Here, its value is 50, while in the previously read member, it was 0.
% You can repeat the processing steps to compute and append the mean for this ensemble member. 
% In practice, it is more useful to automate the process of reading, processing, and writing data. 
% To do so, reset the ensemble to a state in which no data has been read. 
% Then loop through the ensemble and perform the read, process, and write steps for each member.
reset(fensemble)
while hasdata(fensemble)
    data = read(fensemble);
    gsdata = data.gs{1};
    gsmean = mean(gsdata);
    writeToLastMemberRead(fensemble,'gsMean',gsmean);
end

% The hasdata command returns false when every member of the ensemble has been read. 
% Now, each data file in the ensemble includes the gsMean variable derived from the data gs in that file. 
% You can use techniques like this loop to extract and process data from your ensemble files as you develop a predictive-maintenance algorithm. 
% For an example illustrating in more detail the use of a file ensemble datastore in the algorithm-development process, see Rolling Element Bearing Fault Diagnosis. 
% The example also shows how to use Parallel Computing Toolbox™ to speed up the processing of large data ensembles.

% To confirm that the derived variable is present in the file ensemble datastore, read it from the first and second ensemble members. 
% To do so, reset the ensemble again, and add the new variable to the selected variables. 
% In practice, after you have computed derived values, it can be useful to read only those values without rereading the unprocessed data, which can take significant space in memory. 
% For this example, read selected variables that include the new variable, gsMean, but do not include the unprocessed data, gs.
reset(fensemble)
fensemble.SelectedVariables = ["label";"load";"gsMean"];
data1 = read(fensemble)

data2 = read(fensemble)

rmpath(fullfile(matlabroot,'examples','predmaint','main')) % Reset path

function SonyTrainList = importSonyFileInfo(filename,dataLines)
% The importSonyFileInfo function imports the list of Sony files of the
% See-In-The-Dark data set used for training, validation, or testing.
%
% Copyright 2021 The MathWorks, Inc.

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [1, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = " ";

% Specify column names and types
opts.VariableNames = ["ShortExposureFilename", "LongExposureFilename", "ISO", "Aperture"];
opts.VariableTypes = ["string", "string", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.LeadingDelimitersRule = "ignore";

% Specify variable properties
opts = setvaropts(opts, "ShortExposureFilename", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["ShortExposureFilename", "LongExposureFilename"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["ISO", "Aperture"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["ISO", "Aperture"], "ThousandsSeparator", ",");

% Import the data
SonyTrainList = readtable(filename, opts);

end
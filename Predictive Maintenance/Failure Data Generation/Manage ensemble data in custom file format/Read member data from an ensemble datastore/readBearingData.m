function data = readBearingData(filename,variables)
% Read variables from a fileEnsembleDatastore
%
% Inputs:
% filename  - file to read, specified as a string
% variables - variable names to read, specified as a string array
%             Variables must be a subset of SelectedVariables specified in 
%             the fileEnsembleDatastore.
% Output:
% data      - a table with a single row

% Copyright 2017-2018 The MathWorks, Inc.

data = table();

mfile = matfile(filename); % Allows partial loading
bearing = mfile.bearing;

% The filename indicates whether the data is healthy or faulty. If "label" 
% or "file" is among the requested variables, parse the filename to generate
% values.
isLabel = any(strcmp(variables,'label'));
isFile = any(strcmp(variables,'file'));
if (isLabel || isFile)
    [~, fname] = fileparts(filename);

    if isLabel
        fname = char(fname);
        switch fname(1:3)
            case 'bas'
                label = "Healthy";
            case 'Fau'
                label = "Faulty";
            otherwise
                label = "Unknown";
        end
        % Add label to the output table
        data.label = label;
        % Remove "label" from the variables list
        variables(strcmp(variables,'label')) = [];
    end
    
     if isFile
        % Add file to the output table
        data.file = string(fname);
        % Remove "file" from the variables list
        variables(strcmp(variables,'file')) = [];
     end  
end 

% Read the rest of the requested variables from the file.
for ct = 1:numel(variables)
    % The data can be at the top level, or within a data structure, bearing.
    if isfield(bearing,variables{ct})
        val = bearing.(variables{ct});
    else
        val = mfile.(variables{ct});
    end
    
    % Handle unstructured data such as numeric data in a string, or missing 
    % data.
    if ischar(val)
        val = str2double(val);
    elseif isempty(val)
        val = NaN;
    end
    
    if numel(val) > 1
        val = {val};
    end
    
    % Add the data to the output table, using the variable name.
    data.(variables{ct}) = val;

end







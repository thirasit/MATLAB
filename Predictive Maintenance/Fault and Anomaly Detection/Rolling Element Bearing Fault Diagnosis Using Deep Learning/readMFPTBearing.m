function data = readMFPTBearing(filename, variables)
% Read variables from a file, used by the ReadFcn of a
% fileEnsembleDatastore object.
%
% Inputs:
%    filename  - a string of the file name to read from
%    variables - a string array containing variable names to read
%                
% Output:
%    data - return a table with a single row
%

% Note: This function uses dynamic field references to read data from
% files, see
% https://www.mathworks.com/help/matlab/matlab_prog/generate-field-names-from-variables.html
% for more information

% Copyright 2017-2018 The MathWorks, Inc.

data = table();

mfile = matfile(filename); % Allows partial loading
[~, fname] = fileparts(filename);
bearing = mfile.bearing;
for ct = 1:numel(variables)
    if strcmp(variables{ct},'FileName')
        %Return filename
        val = string(fname);
    elseif strcmp(variables{ct},'Label')
        %Set label based on filename
        cfname = char(fname);
        switch cfname(1:3)
            case 'bas'
                val = "Normal";
            case 'Inn'
                val = "Inner Race Fault";
            case 'Out'
                val = "Outer Race Fault";
            otherwise
                val = "Unknown";
        end
    else
        
        % The data could be either stored at top level or within bearing structure
        if isfield(bearing, variables{ct})
            val = bearing.(variables{ct});
        else
            val = mfile.(variables{ct});
        end
        
        % Handle unstructured data
        % e.g. numeric data in string type or missing data
        if ischar(val)
            val = str2double(val);
        elseif isempty(val)
            val = nan;
        end
        
        if numel(val) > 1
            val = {val};
        end
    end
    data.(variables{ct}) = val;
end
end

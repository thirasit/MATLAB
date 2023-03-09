function outStruct = helperReadHeaderRIRE(filename)
%helperReadHeaderRIRE Read header from RIRE dataset.
%  HEADER = helperReadHeaderRIRE(FILENAME) reads the ASCII header file from
%  the Retrospective Image Registration Evaluation (RIRE) dataset specfied
%  by FILENAME and returns HEADER, a struct containing image metadata.

%  Notes
%  -----
%  This is a helper function in support of examples and may change in a
%  future release.

% Copyright 2012 The MathWorks, Inc.

% Open file for reading.
fid = fopen(filename);

% Read a line of the line at a time until end of file.
thisLine = fgetl(fid);

% Initialize the struct we will use to package metadata
outStruct = struct();

while ischar(thisLine)
    
    [startIndex, endIndex] = regexp(thisLine, ' := ');
    
    switch (lower(thisLine(1:(startIndex-1))))
        
        case 'modality'
            outStruct.Modality = thisLine((endIndex+1):end);
        case 'slice thickness'
            outStruct.SliceThickness = str2double(thisLine(endIndex:end));
        case 'pixel size'
            [startIdx,endIdx] = regexp(thisLine,' : ');
            outStruct.PixelSize(1) = str2double(thisLine(endIndex:startIdx));
            outStruct.PixelSize(2) = str2double(thisLine((endIdx+1):end));
        case 'rows'
            outStruct.Rows = str2double(thisLine(endIndex:end));
        case 'columns'
            outStruct.Columns = str2double(thisLine(endIndex:end));
        case 'slices'
            outStruct.Slices  = str2double(thisLine(endIndex:end));    
    end
    
    thisLine = fgetl(fid);
    
end

% Close file
fclose(fid);
            
    
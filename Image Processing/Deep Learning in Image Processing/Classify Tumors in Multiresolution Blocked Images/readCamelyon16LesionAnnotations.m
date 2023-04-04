function [maskROICancer,maskROINonCancer] = readCamelyon16LesionAnnotations(xmlFilename)
% Read lesion annotation postions from the XML file, xmlFilename and return
% the cell arrays of region positions containing cancer in maskROICancer
% and region positions of normal tissue within cancer regions in
% maskROINonCancer

% Copyright 2021 The MathWorks, Inc.

maskROINonCancer = {};
maskROICancer = {};
if ~exist(xmlFilename,'file')
    % warning('The lesion annotations XML file, %s does not exist.\n',xmlFilename);
    return
end
s = readstruct(xmlFilename);
annotations = s.Annotations.Annotation;
numAnnotations = length(annotations);
for idx = 1:numAnnotations
    coordinates = struct2table(annotations(idx).Coordinates.Coordinate);
    out = [double(coordinates.XAttribute),double(coordinates.YAttribute)];
    if strcmp(annotations(idx).PartOfGroupAttribute,'_2')
        maskROINonCancer{end+1} = cat(1,out); %#ok<AGROW>
    else
        maskROICancer{end+1} = cat(1,out); %#ok<AGROW>
    end
end

end


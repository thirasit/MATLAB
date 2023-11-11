function [hbim, hCancer, hNonCancer] = showCamelyon16TumorAnnotations(bim, annotationDir)
% Load and display Camelyon16 lesion annotations from corresponding XML file

% Copyright 2021 The MathWorks, Inc.

[~, id] = fileparts(bim.Source);
xmlFile = string(annotationDir) + filesep + id + '.xml';
if ~isfile(xmlFile)
    % warning('The lesion annotations XML file, %s does not exist.\n',xmlFile);
else
    
    [cancerXYs,nonCancerXYs] = readCamelyon16LesionAnnotations(xmlFile);
    
    % Display the tumor image 
    hbim = bigimageshow(bim);
    
    % The cancer regions in red
    for ind = 1:numel(cancerXYs)
        hCancer(ind) = images.roi.Freehand('Position', cancerXYs{ind},...
            'Parent', gca,...
            'FaceSelectable', false,...
            'InteractionsAllowed', 'none',...
            'Color', 'r'); %#ok<AGROW>
    end
    
    % Normal regions within a cancerous region in green.
    hNonCancer = [];
    for ind = 1:numel(nonCancerXYs)
        hNonCancer(ind) = images.roi.Freehand('Position', nonCancerXYs{ind},...
            'Parent', gca,...
            'FaceSelectable', false,...
            'InteractionsAllowed', 'none',...
            'Color', 'g'); %#ok<AGROW>
    end
    
end
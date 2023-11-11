function bmasks = createMaskForCamelyon16TumorTissue(bims,annotationDir,maskDir,resolutionLevel)
% Write blockedImage masks at the specified resolution level,
% resolutionLevel for tumor regions in images in bims. The tumor regions
% (lesion annotations) are specified in the XML files in the directory
% annotationDir. The masks are written to disk at the specified location,
% maskDir.
%
% The lesion annotations in XML files are read and converted to polygons.
% The polygons are used to create image masks on a block-by-block basis.
% The masks are written to disk and used during training to read the image
% blocks containing tumor.

% Copyright 2021 The MathWorks, Inc.


bmasks = blockedImage.empty();
blockSize = bims(1).BlockSize;

for ind = 1:numel(bims)
    imageSize = bims(ind).Size(resolutionLevel,1:2);
    
    [~,id] = fileparts(bims(ind).Source);
    xmlFile = annotationDir+filesep+id+".xml";

    [cancerXYs,nonCancerXYs] = readCamelyon16LesionAnnotations(xmlFile);

    % Note: this should always be in this order since non-cancer regions
    % can occur inside cancer regions (and hence should 'overwrite' the
    % cancer label).
    roiXYs = [nonCancerXYs,cancerXYs];
    maskLocation = fullfile(maskDir,id);
    
    if isempty(roiXYs)
        bmasks(ind) = blockedImage(maskLocation,[512 512],imageSize,false,"Mode",'w',...
            'WorldStart',bims(ind).WorldStart(resolutionLevel,1:2), ...
            'WorldEnd',bims(ind).WorldEnd(resolutionLevel,1:2));
        bmasks(ind).Mode = 'r';
        continue
    end
    
    roiLabelIds = [false(1,numel(nonCancerXYs)),true(1,numel(cancerXYs))];
       
    bmasks(ind) = polyToBlockedImage(roiXYs,roiLabelIds,imageSize, ...
        'WorldStart',bims(ind).WorldStart(resolutionLevel, 1:2),...
        'WorldEnd',bims(ind).WorldEnd(resolutionLevel, 1:2),...
        'OutputLocation',maskLocation);
end

end
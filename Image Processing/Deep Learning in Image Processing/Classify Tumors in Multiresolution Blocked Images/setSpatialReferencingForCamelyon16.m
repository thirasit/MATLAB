function bims = setSpatialReferencingForCamelyon16(bims)
%function spatialRefOut = setSpatialReferencingForCamelyon16(fileName)
% setSpatialReferencingForCamelyon16 Gets the spatial referencing
% information for each resolution level from the image file metadata

% Copyright 2019-2021 The MathWorks, Inc.

for ind = 1:numel(bims)
    bim = bims(ind);
    fileName = bim.Source;
    metadata = extractMetadataFromTiff(fileName);
    
    pixelSpacingMetaData = metadata.PIM_DP_SCANNED_IMAGES(1).PIIM_PIXEL_DATA_REPRESENTATION_SEQUENCE;
    
    % blockedImage sorts image levels based on size. The first level
    % usually has the most data either way.
    firstLevelPixelSpacing = pixelSpacingMetaData(1);
    assert(isequal(firstLevelPixelSpacing.PIIM_PIXEL_DATA_REPRESENTATION_ROWS,...
        bim.Size(1,1)))
    
    bim.UserData.InvalidLevels = [];
    bim.UserData.PixelSpacing = [];
    
    % Align all the level starting point to 0.
    bim.WorldStart = [0 0 0];
    
    for lInd = 1:bim.NumLevels
        levelSize = bim.Size(lInd,:);
        % Corresponding index in the meta data
        metadataIndex = find([pixelSpacingMetaData.PIIM_PIXEL_DATA_REPRESENTATION_ROWS]==levelSize(1)...
            & [pixelSpacingMetaData.PIIM_PIXEL_DATA_REPRESENTATION_COLUMNS]==levelSize(2),1);
        if isempty(metadataIndex)
            % No metadata for this level. Usually means this evel contains
            % invalid image data or is not spatially registered with the
            % rest of the levels.
            bim.UserData.InvalidLevels(end+1) = lInd;
            bim.UserData.PixelSpacing(lInd,:) = [0 0];
        else
            levelPixelSpacing = pixelSpacingMetaData(metadataIndex);
            relativePixelSpacing = double(levelPixelSpacing.DICOM_PIXEL_SPACING) ./ double(firstLevelPixelSpacing.DICOM_PIXEL_SPACING);
            relativePixelSpacing(3) = 1; % assumed for color channel
            bim.WorldEnd(lInd,:) = levelSize.*relativePixelSpacing;
            bim.UserData.PixelSpacing(lInd,:) = levelPixelSpacing.DICOM_PIXEL_SPACING;
        end
    end
end
end

function metadata = extractMetadataFromTiff(filename)
T = Tiff(filename, 'r');
rawMetadataChar = T.getTag(Tiff.TagID.ImageDescription);

if contains(rawMetadataChar, '<?xml')
    isInArray = false;
    rawMetadataStr = string(rawMetadataChar);
    metadata = convertXML(rawMetadataStr, isInArray);
else
    metadata = struct([]);
end
end


function [metadata, s] = convertXML(s, isInArray)

openings = strfind(s, "<");
closings = strfind(s, ">");

assert(numel(openings) == numel(closings));

metadata = struct([]);
attributeName = [];
attributeType = [];

itemNumber = 0;

while (strlength(s) > 0) && (numel(openings) > 0)
    substr = extractBetween(s, openings(1)+1, closings(1)-1);
    
    if isempty(substr) || isequal(substr{1}(1), '?')
        % No-op
    else
        parts = split(substr, " ");
        tagName = parts(1);
        
        switch tagName
            case "Attribute"
                isName = startsWith(parts, "Name");
                namePart = parts(isName);
                attributeName = extractBetween(namePart, '"', '"');
                
                isType = startsWith(parts, "PMSVR");
                typePart = parts(isType);
                attributeType = extractBetween(typePart, '"', '"');
            case "/Attribute"
                if attributeType ~= "IDataObjectArray"
                    attributeValueEnd = openings(1) - 1;
                    attributeValue = s{1}(1:attributeValueEnd);
                    value = convert(attributeValue, attributeType);
                    if isInArray
                        metadata(itemNumber).(attributeName) = value;
                    else
                        metadata(1).(attributeName) = value;
                    end
                end
            case "Array"
                % Recurse only for PIM_DP_SCANNED_IMAGES
                if attributeName ~= "PIM_DP_SCANNED_IMAGES" &&...
                        attributeName ~= "PIIM_PIXEL_DATA_REPRESENTATION_SEQUENCE"
                    return
                end
                willBeInArray = true;
                s = extractAfter(s, closings(1));
                if itemNumber > 0
                    [metadata(itemNumber).(attributeName), s] = convertXML(s, willBeInArray);
                else
                    [metadata(1).(attributeName), s] = convertXML(s, willBeInArray);
                end
                
                openings = strfind(s, "<");
                closings = strfind(s, ">");
                continue  % Don't update openLocs, closeLocs twice
            case "/Array"
                % Leave array context
                s = extractAfter(s, closings(1));
                break
            case "DataObject"
                if isInArray
                    itemNumber = itemNumber + 1;
                end
            case "/DataObject"
                % No-op
            otherwise
                
        end
    end
    
    newStart = closings(1);
    s = extractAfter(s, closings(1));
    openings = openings - newStart;
    closings = closings - newStart;
    openings(1) = [];
    closings(1) = [];
end

end


function value = convert(rawValue, attributeType)
switch attributeType
    case "IString"
        value = string(rawValue);
    case "IDataObjectArray"
        assert(false)
    case "IUInt16"
        value = uint16(sscanf(rawValue, '%d'));
    case "IDoubleArray"
        rawValue = strrep(rawValue, '&quot;', '');
        value = sscanf(rawValue, '%f')';
    case "IUInt32"
        value = uint32(sscanf(rawValue, '%d'));
    case "IStringArray"
        rawValue = strrep(rawValue, '&quot;', '"');
        rawValue = strrep(rawValue, '" ', '"\');
        rawValue = string(rawValue);
        value = split(rawValue, "\");
        value = strrep(value, """", "");
end
end

function dsOut = createCombinedDatastoreForLowLightRecovery(imageDir,info)
% The createCombinedDatastoreForLowLightRecovery function creates a
% combined datastore that consists of a pair of short exposure and long
% exposure images. The images are normalized and the short exposure images
% have an additional gain that corrects for the difference between the
% exposure times.
%
% Copyright 2021 The MathWorks, Inc.

shortFilenameKeys = extractAfter(info.ShortExposureFilename,"./Sony/short/");

fileNameIsoMap = containers.Map(shortFilenameKeys,info.ISO);
fileNameApertureMap = containers.Map(shortFilenameKeys,info.Aperture);

dsShort = imageDatastore(fullfile(imageDir,info.ShortExposureFilename), ...
    'ReadFcn',@(name) raw2planar(rawread(name)),'FileExtensions',{'.ARW'});
dsShort = transform(dsShort,@transformInputImage);

dsLong = imageDatastore(fullfile(imageDir,info.LongExposureFilename), ...
    'ReadFcn',@raw2rgb,'FileExtensions',{'.ARW'});
dsLong = transform(dsLong,@transformOutputImage);

dsOut = combine(dsShort,dsLong);
dsOut = transform(dsOut,'IncludeInfo',true,@(data,info) addMetadataToInfo(data,info,fileNameIsoMap,fileNameApertureMap));

dsOut = transform(dsOut,'IncludeInfo',true,@(data,info) applyGain(data,info));

end

function dataOut = transformInputImage(dataIn)
dataOut = single(dataIn);
dataOut = max(dataOut-512,0) / (16383 - 512); % Normalize between [0,1].
end

function dataOut = transformOutputImage(dataOut)
dataOut = {single(dataOut) ./ single(intmax('uint16'))};
end

function [data,info] = applyGain(data,info)
    gain = min(300,info.LongExposureTime/info.ShortExposureTime);
    data{1} = data{1} .* gain;
end

function [data,infoOut] = addMetadataToInfo(data,info,isoMap,apertureMap)

xInfo = info{1};
yInfo = info{2};

infoOut.ShortExposureFilename = xInfo.Filename;
infoOut.LongExposureFilename = yInfo.Filename;

[~,nameLong,~] = fileparts(info{2}.Filename);
[~,nameShort,ext] = fileparts(info{1}.Filename);
shortName = string(nameShort) + string(ext);
iso = isoMap(shortName);
aperture = apertureMap(shortName);

infoOut.ISO = iso;
infoOut.Aperture = aperture;

temp = split(string(nameShort),"_");
shortTime = double(extractBefore(temp(3),"s"));
temp = split(string(nameLong),"_");
longTime = double(extractBefore(temp(3),"s"));

infoOut.ShortExposureTime = shortTime;
infoOut.LongExposureTime = longTime;

end
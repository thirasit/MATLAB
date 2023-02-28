function [boundingBox, orientation, Iclusters] = clusteringLocalization(lines, imSize)

%------------------------------------------------------------------------
% Determine Bisectors of Barcode Line Segments
%------------------------------------------------------------------------

% Table to store the properties of the bisectors of the detected lines.
linesBisector = array2table(zeros(length(lines), 4), 'VariableNames', {'theta', 'rho', 'x', 'y'});

% Use the orientation values of the lines to determine the orientation.
% values of the bisectors
idxNeg = find([lines.theta] < 0);
idxPos = find([lines.theta] >= 0);

negAngles = 90 + [lines(idxNeg).theta];
linesBisector.theta(idxNeg) = negAngles;

posAngles = [lines(idxPos).theta] - 90;
linesBisector.theta(idxPos) = posAngles;

% Determine the midpoints of the detected lines.
midPts = zeros(length(lines),2);

% Determine the 'rho' values of the bisectors.
for i = 1:length(lines)
    midPts(i,:) = (lines(i).point1 + lines(i).point2)/2;
    linesBisector.rho(i) = abs(midPts(i,2) - tand(lines(i).theta) * midPts(i,1))/...
        ((tand(lines(i).theta)^2 + 1) ^ 0.5);
end

% Update the [x,y] locations of the bisectors using their polar
% coordinates.
[linesBisector.x, linesBisector.y] = pol2cart(deg2rad(linesBisector.theta),linesBisector.rho,'ro');

%------------------------------------------------------------------------
% Perform Clustering on the Bisectors to Identity the Individual Barcodes
%------------------------------------------------------------------------

% Store the [x,y] data of the bisectors to be used for clustering.
X = [linesBisector.x,linesBisector.y];

% Get pairwise distance between the points
D = pdist2(X,X);

% Perform density-based spatial clustering to separate the different
% barcodes in the image.
searchRadius = max(imSize/5);
minPoints = 10;
idx = dbscan(D,searchRadius, minPoints);

% Identify the number of clusters (barcodes).
numClusters = unique(idx(idx > 0));

% Store the endpoints of the detected lines.
dataXY = cell(1, length(numClusters));

% Image to show the detected clusters (barcodes).
Iclusters = ones(imSize);

for i = 1:length(numClusters)
    classIdx = find(idx == i);
    
    rgbColor = rand(1,3);
    startPts = reshape([lines(classIdx).point1], 2, length(classIdx))';
    endPts = reshape([lines(classIdx).point2], 2, length(classIdx))';
    
    % Insert lines corresponding to the current cluster (barcode).
    Iclusters = insertShape(Iclusters, 'line', [startPts, endPts], ...
        'LineWidth', 2, 'Color', rgbColor);
    
    % Update the endpoints of the lines in each cluster (barcode).
    dataXY{i} = [startPts; endPts];
end

%------------------------------------------------------------------------
% Localization parameters for the barcode
%------------------------------------------------------------------------

orientation = zeros(1,length(numClusters));
boundingBox = zeros(length(numClusters), 4);

% Padding the cropped images of barcodes.
padding = 40;

% Determine the ROI and orientation of the individual clusters (barcodes).
for i = 1:length(numClusters)
    
    % Bounding box coordinates with padding.
    x1 = min(dataXY{i}(:,1)) - padding;
    x2 = max(dataXY{i}(:,1)) + padding;
    y1 = min(dataXY{i}(:,2)) - padding;
    y2 = max(dataXY{i}(:,2)) + padding;
    
    boundingBox(i,:) = [x1, y1, x2-x1, y2-y1];
    
    % Orientation of the barcode.
    orientation(i) = mean(linesBisector.theta(idx == i));
    
end

end
function B = anomalyMapOverlayForConcreteAnomalyDetector(A,scoreMap,varargin)
% anomalyMapOverlayForConcreteAnomalyDetector Overlay heatmap on an input image using per-pixel anomaly scores.

%   Copyright 2021 The MathWorks, Inc.

narginchk(2,8);

displayRange = parseOptionalArguments(scoreMap, varargin{:});
map = jet(256);

% Normalize input image and heatmap to the same range [0 1]
A = mat2gray(A);

% Rescale the anomaly scores image based on the display range parameter.
scoreMap = rescale(scoreMap,'InputMin',displayRange(1),'InputMax',displayRange(2));

% Map per-pixel anomaly scores to a colormap and represent as an RGB image
% map = jet(256);
scoreMapRGB = ind2rgb(gray2ind(scoreMap,size(map,1)),map);

% Create weights for the anomaly scoremap to overlay only in regions of
% high scores. This allows the underlying image to be seen without
% occlusion.
scoreMapWeight = scoreMap;
imageWeight = 1-scoreMapWeight;


% Blend the anomaly scoremap and image using corresponding weights
B = im2uint8(imageWeight.*A + scoreMapWeight.*scoreMapRGB);

end

function displayRange = parseOptionalArguments(scoreMap,varargin)

narginchk(1,Inf);

parser = inputParser();
parser.addParameter('ScoreMapRange',[min(scoreMap(:)) max(scoreMap(:))]);

parser.parse(varargin{:});
parsedInputs = parser.Results;
displayRange = parsedInputs.ScoreMapRange;

end

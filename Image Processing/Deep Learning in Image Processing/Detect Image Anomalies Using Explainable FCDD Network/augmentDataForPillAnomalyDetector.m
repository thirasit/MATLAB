function data = augmentDataForPillAnomalyDetector(data)
% The augmentDataForPillAnomalyDetector function randomly applies 90
% degree rotation and horizontal and vertical reflection to an input image.
%
% Copyright 2021 The MathWorks, Inc.

% Add randomized rotation to training set
rotAmount = randi(4) - 1;
data = rot90(data,rotAmount);

% Add randomized horizontal reflection
if rand > 0.5
    data = fliplr(data);
end

% Add randomized vertical reflection
if rand > 0.5
    data = flipud(data);
end

data = {data};

end
function dataOut = augmentDataForRAWToRGB(dataIn)
% The augmentDataForRAWToRGB function randomly applies 90 degree rotation
% and horizontal reflection to pairs of image patches.

% Copyright 2021 The MathWorks, Inc.

dataOut = cell(size(dataIn));
for idx = 1:size(dataIn,1)

    % Randomized rotation
    rotAmount = randi(4)-1;
    dataOut(idx,:) = {
        rot90(dataIn{idx,1},rotAmount), ...
        rot90(dataIn{idx,2},rotAmount)};

    % Randomized horizontal reflection
    xReflection = rand > 0.5;
    if xReflection
        dataOut(idx,:) = {
            fliplr(dataOut{idx,1}), ...
            fliplr(dataOut{idx,2})};
    end
end

end
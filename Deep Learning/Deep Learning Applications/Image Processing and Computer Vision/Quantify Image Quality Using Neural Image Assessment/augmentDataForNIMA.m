function dataOut = augmentDataForNIMA(dataIn,cropSize)
% The augmentDataForNIMA function randomly crops input images to a
% target size and applies horizontal reflection with 50% probability.
%
% Copyright 2020 The MathWorks, Inc.

[I,C] = dataIn{:};

% Random crop
win = randomWindow2d(size(I),cropSize);
Iout = imcrop(I,win);

% Randomized horizontal reflection
doXReflection = rand > 0.5;
if doXReflection
    Iout = fliplr(Iout);
end

% Return augmented data
dataOut = {Iout,C};

end
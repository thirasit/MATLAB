function dataOut = augmentDataForDayToDusk(dataIn,sz)
% The augmentDataForDayToDusk function resizes an input image to a target
% size, sz, randomly applies horizontal reflection with 50% probability,
% and normalizes the image to the range [-1, 1].
%
% Copyright 2020 The MathWorks, Inc.

finalSize = sz(1:2);  
I = imresize(dataIn,finalSize);
mirror = rand(1) < 0.5;
if mirror
    I = fliplr(I);
end

I = im2single(I);
dataOut = (I - 0.5)/0.5;

end
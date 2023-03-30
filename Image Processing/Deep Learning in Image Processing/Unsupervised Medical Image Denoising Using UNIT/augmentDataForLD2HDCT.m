function dataOut = augmentDataForLD2HDCT(dataIn,sz)
% The augmentDataForLD2HDCT function resizes an input image to a target
% size, sz, randomly applies horizontal reflection with 50% probability,
% and normalizes the image to the range [-1, 1].
%
% Copyright 2021 The MathWorks, Inc.

finalSize = sz(1:2);  
I = imresize(dataIn,finalSize);
if rand(1) < 0.5
    I = fliplr(I);
end

I = im2single(I);
dataOut = (I - 0.5)/0.5;

end
function [out1,out2] = concatenateMiniBatchLD2HDCT(im1,im2)
% concatenateMiniBatchLD2HDCT - Concatenates the input minibatch for training

%   Copyright 2021 The MathWorks, Inc.

out1 = cat(4,im1{:});
out2 = cat(4,im2{:});

end
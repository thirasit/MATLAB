function im = normalizeCTImages(im)
% normalizeCTImages - normalize the CT images for training and
% visualization.

%   Copyright 2021 The MathWorks, Inc.

%% Rescale
win = [-1024 3071];
im = single(im);
im = im - win(1);
im = im / (win(2)-win(1));
im(im>1) = 1;
im(im<0) = 0;
im = rescale(im2single(im),-1,1,'inputMin',0,'inputMax',1);
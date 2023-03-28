function displayWaferScoreMap(im,sm,ax)
% displayWaferScoreMap displays the gradCAM score (sm) as a color overlay
% on a wafer image (im) in an axes (ax).

% Copyright 2021, The MathWorks, Inc.

imshow(imresize(im,4),[],Parent=ax)
hold on
imagesc(imresize(sm,4),AlphaData=0.5,Parent=ax)
colormap parula

end
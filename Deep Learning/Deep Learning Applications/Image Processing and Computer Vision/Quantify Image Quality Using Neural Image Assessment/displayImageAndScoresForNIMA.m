function displayImageAndScoresForNIMA(tl,im,m,s,t)
% The displayImageAndScoresForNIMA function displays an image (im) in a
% tile of a tiledLayoutl (tl). The title of the tile contains information
% information about the image (t), the mean score (m), and the standard
% deviation of scores (s).
%
% Copyright 2020 The MathWorks, Inc.

nexttile(tl);
imshow(im);
title([t; ...
    "Mean Score: "+num2str(m); ...
    "Std Dev: "+num2str(s)])

end
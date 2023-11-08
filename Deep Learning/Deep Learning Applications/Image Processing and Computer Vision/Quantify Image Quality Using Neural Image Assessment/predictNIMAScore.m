function [meanScore,stdScore] = predictNIMAScore(dlnet,X)
% PREDICTNIMASCORE predicts the mean and standard deviation of the score
% distribution for individual images using a trained NIMA model
%
% Copyright 2020 The MathWorks, Inc.

targetSize = [224 224];
X = imresize(X,targetSize);
dlX = dlarray(double(X),'SSCB');
dlY = predict(dlnet,dlX);
Y = extractdata(dlY);
meanScore = (1:10)*Y;
stdScore = sqrt(((1:10).^2)*Y-meanScore^2);
end
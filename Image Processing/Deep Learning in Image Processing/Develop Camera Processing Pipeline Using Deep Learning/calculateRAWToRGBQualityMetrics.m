function [mssimSum,psnrSum] = calculateRAWToRGBQualityMetrics(I,Iref)
% Compute psnr and mssim, mean reducing over channel dim and sum reducing
% over observation dimension

% Copyright 2021 The MathWorks, Inc.

I = gather(extractdata(I));
I = im2uint8(I); % Network predicts [0,1]. Scale to [0,255] and cast to uint8.
Iref = uint8(gather(extractdata(Iref)));

numObservations = size(I,4);

mssimSum = 0;
psnrSum = 0;
for idx = 1:numObservations
    mssimRGB = mean([
                multissim(I(:,:,1,idx),Iref(:,:,1,idx)),...
                multissim(I(:,:,2,idx),Iref(:,:,2,idx)),...
                multissim(I(:,:,3,idx),Iref(:,:,3,idx))]);
    psnrRGB = mean([
                psnr(I(:,:,1,idx),Iref(:,:,1,idx)),...
                psnr(I(:,:,2,idx),Iref(:,:,2,idx)),...
                psnr(I(:,:,3,idx),Iref(:,:,3,idx))]);
    mssimSum = mssimSum + mssimRGB;
    psnrSum = psnrSum + psnrRGB;
end

end
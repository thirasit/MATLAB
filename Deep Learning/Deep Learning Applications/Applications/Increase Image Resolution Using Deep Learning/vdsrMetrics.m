function superResolutionMetrics(net,testImages,scaleFactors)
% SUPERRESOLUTIONMETRICS Calculate average PSNR and SSIM for each scale factor
%
% superResolutionMetrics(net,testImages,scaleFactors) calculates the
% average PSNR and SSIM for the test images, testImages for a given
% network, net for each scale factor in scaleFactors

%   Copyright 2017 The MathWorks, Inc.

for scaleFactor = scaleFactors
    fprintf('Results for Scale factor %d\n\n',scaleFactor);
    
    for idx = 1:numel(testImages.Files)
        
        I = readimage(testImages,idx);
        Iycbcr = rgb2ycbcr(I);
        Ireference = im2double(Iycbcr);
        
        % Resize the reference image by a scale factor of 4 to create a low-resolution image using bicubic interpolation
        lowResolutionImage = imresize(Ireference,1/scaleFactor,'bicubic');
        
        % Upsample the low-resolution image using bicubic interpolation
        upsampledImage = imresize(lowResolutionImage,[size(Ireference,1) size(Ireference,2)],'bicubic');
        
        % Separate the upsampled low-resolution image into luminance and color components.
        Iy  = upsampledImage(:,:,1);
        Icb = upsampledImage(:,:,2);
        Icr = upsampledImage(:,:,3);
        
        % Recreate the upsampled image from the luminance and color components and
        % convert to RGB colorspace
        Ibicubic = ycbcr2rgb(cat(3,Iy,Icb,Icr));
        
        % Pass the luminance component of upsampled low-resolution image through
        % the trained network and observe the activations from the last layer i.e.
        % Regression Layer. The output of the network is the desired residual
        % image. We pass only the luminance component through the network because
        % we used only the luminance channel while training. The color components
        % are upsampled using bicubic interpolation.
        residualImage = activations(net,Iy,41);
        residualImage = double(residualImage);
        
        % Add the residual image from the network to the upsampled luminance
        % component to get the high-resolution network output
        Isr = Iy + residualImage;
        
        % Concatenate the upsampled luminance and color components and convert to RGB colorspace to get the final
        % high-resolution color image
        Ivdsr = ycbcr2rgb(cat(3,Isr,Icb,Icr));
        
        % Convert the reference image to RGB colorspace
        Ireference = ycbcr2rgb(Ireference);
        
        % Compare the PSNR and SSIM of the super-resolved image using bicubic interpolation versus that using VDSR. The difference in
        % PSNR shows how much the network improved the image resolution. Higher
        % PSNR and SSIM values generally indicate better results.
        
        % PSNR
        bicubicPSNR(idx) = psnr(Ibicubic,Ireference); %#ok<*AGROW>
        vdsrPSNR(idx) = psnr(Ivdsr,Ireference);
        
        % SSIM
        bicubicSSIM(idx) = ssim(Ibicubic,Ireference);
        vdsrSSIM(idx) = ssim(Ivdsr,Ireference);
        
    end
    
    % Average PSNR for each test set
    % Bicubic
    avgBicubicPSNR = mean(bicubicPSNR);
    fprintf('Average PSNR for Bicubic = %f\n',avgBicubicPSNR);
    
    % VDSR
    avgVdsrPSNR = mean(vdsrPSNR);
    fprintf('Average PSNR for VDSR = %f\n',avgVdsrPSNR);
    
    
    % Average SSIM for each test set
    % Bicubic
    avgBicubicSSIM = mean(bicubicSSIM);
    fprintf('Average SSIM for Bicubic = %f\n',avgBicubicSSIM);
    
    % VDSR
    avgVdsrSSIM = mean(vdsrSSIM);
    fprintf('Average SSIM for VDSR = %f\n\n',avgVdsrSSIM);

end

end
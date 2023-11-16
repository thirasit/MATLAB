function jpegDeblockingMetrics(IOriginal,I10,I20,I50,I10predicted,I20predicted,I50predicted)
% Compare SSIM values
ssimI10 = ssim(I10,IOriginal);
ssimI10predicted = ssim(I10predicted,IOriginal);
ssimI20 = ssim(I20,IOriginal);
ssimI20predicted = ssim(I20predicted,IOriginal);
ssimI50 = ssim(I50,IOriginal);
ssimI50predicted = ssim(I50predicted,IOriginal);
disp('------------------------------------------')
disp('SSIM Comparison')
disp('===============')
disp(['I10: ' num2str(ssimI10) '    I10_predicted: ' num2str(ssimI10predicted)])
disp(['I20: ' num2str(ssimI20) '    I20_predicted: ' num2str(ssimI20predicted)])
disp(['I50: ' num2str(ssimI50) '    I50_predicted: ' num2str(ssimI50predicted)])

% Compare PSNR values
psnrI10 = psnr(I10,IOriginal);
psnrI10predicted = psnr(I10predicted,IOriginal);
psnrI20 = psnr(I20,IOriginal);
psnrI20predicted = psnr(I20predicted,IOriginal);
psnrI50 = psnr(I50,IOriginal);
psnrI50predicted = psnr(I50predicted,IOriginal);
disp('------------------------------------------')
disp('PSNR Comparison')
disp('===============')
disp(['I10: ' num2str(psnrI10) '    I10_predicted: ' num2str(psnrI10predicted)])
disp(['I20: ' num2str(psnrI20) '    I20_predicted: ' num2str(psnrI20predicted)])
disp(['I50: ' num2str(psnrI50) '    I50_predicted: ' num2str(psnrI50predicted)])

% Compare NIQE values
niqeI10 = niqe(I10);
niqeI10predicted = niqe(I10predicted);
niqeI20 = niqe(I20);
niqeI20predicted = niqe(I20predicted);
niqeI50 = niqe(I50);
niqeI50predicted = niqe(I50predicted);
disp('------------------------------------------')
disp('NIQE Comparison')
disp('===============')
disp(['I10: ' num2str(niqeI10) '    I10_predicted: ' num2str(niqeI10predicted)])
disp(['I20: ' num2str(niqeI20) '    I20_predicted: ' num2str(niqeI20predicted)])
disp(['I50: ' num2str(niqeI50) '    I50_predicted: ' num2str(niqeI50predicted)])
disp('NOTE: Smaller NIQE score signifies better perceptual quality')

% Compare BRISQUE values
brisqueI10 = brisque(I10);
brisqueI10predicted = brisque(I10predicted);
brisqueI20 = brisque(I20);
brisqueI20predicted = brisque(I20predicted);
brisqueI50 = brisque(I50);
brisqueI50predicted = brisque(I50predicted);
disp('------------------------------------------')
disp('BRISQUE Comparison')
disp('==================')
disp(['I10: ' num2str(brisqueI10) '    I10_predicted: ' num2str(brisqueI10predicted)])
disp(['I20: ' num2str(brisqueI20) '    I20_predicted: ' num2str(brisqueI20predicted)])
disp(['I50: ' num2str(brisqueI50) '    I50_predicted: ' num2str(brisqueI50predicted)])
disp('NOTE: Smaller BRISQUE score signifies better perceptual quality')
end
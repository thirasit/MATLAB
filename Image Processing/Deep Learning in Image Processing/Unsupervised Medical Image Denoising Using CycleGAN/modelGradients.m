%%% Supporting Functions
% Model Gradients Function
% The function modelGradients takes as input the two generator and discriminator dlnetwork objects and a mini-batch of input data. The function returns the gradients of the loss with respect to the learnable parameters in the networks and the scores of the four networks. Because the discriminator outputs are not in the range [0, 1], the modelGradients function applies the sigmoid function to convert discriminator outputs into probability scores.
function [genHD2LDGrad,genLD2HDGrad,discLDGrad,discHDGrad, ...
    genHD2LDState,genLD2HDState,scores,imagesOutLDAndHDGenerated,imagesOutHDAndLDGenerated] = ...
    modelGradients(genLD2HD,genHD2LD,discLD,discHD,imageHD,imageLD,lambda)

% Translate images from one domain to another: low-dose to high-dose and
% vice versa
[imageLDGenerated,genHD2LDState] = forward(genHD2LD,imageHD);
[imageHDGenerated,genLD2HDState] = forward(genLD2HD,imageLD);

% Calculate predictions for real images in each domain by the corresponding
% discriminator networks
predRealLD = forward(discLD,imageLD);
predRealHD = forward(discHD,imageHD);

% Calculate predictions for generated images in each domain by the
% corresponding discriminator networks
predGeneratedLD = forward(discLD,imageLDGenerated);
predGeneratedHD = forward(discHD,imageHDGenerated);

% Calculate discriminator losses for real images
discLDLossReal = lossReal(predRealLD);
discHDLossReal = lossReal(predRealHD);

% Calculate discriminator losses for generated images
discLDLossGenerated = lossGenerated(predGeneratedLD);
discHDLossGenerated = lossGenerated(predGeneratedHD);

% Calculate total discriminator loss for each discriminator network
discLDLossTotal = 0.5*(discLDLossReal + discLDLossGenerated);
discHDLossTotal = 0.5*(discHDLossReal + discHDLossGenerated);

% Calculate generator loss for generated images
genLossHD2LD = lossReal(predGeneratedLD);
genLossLD2HD = lossReal(predGeneratedHD);

% Complete the round-trip (cycle consistency) outputs by applying the
% generator to each generated image to get the images in the corresponding
% original domains
cycleImageLD2HD2LD = forward(genHD2LD,imageHDGenerated);
cycleImageHD2LD2HD = forward(genLD2HD,imageLDGenerated);

% Calculate cycle consistency loss between real and generated images
cycleLossLD2HD2LD = cycleConsistencyLoss(imageLD,cycleImageLD2HD2LD,lambda);
cycleLossHD2LD2HD = cycleConsistencyLoss(imageHD,cycleImageHD2LD2HD,lambda);

% Calculate identity outputs
identityImageLD = forward(genHD2LD,imageLD);
identityImageHD = forward(genLD2HD,imageHD);
 
% Calculate fidelity loss (SSIM) between the identity outputs
fidelityLossLD = mean(1-multissim(identityImageLD,imageLD),"all");
fidelityLossHD = mean(1-multissim(identityImageHD,imageHD),"all");

% Calculate total generator loss
genLossTotal = genLossHD2LD + cycleLossHD2LD2HD + ...
    genLossLD2HD + cycleLossLD2HD2LD + fidelityLossLD + fidelityLossHD;

% Calculate scores of generators
genHD2LDScore = mean(sigmoid(predGeneratedLD),"all");
genLD2HDScore = mean(sigmoid(predGeneratedHD),"all");

% Calculate scores of discriminators
discLDScore = 0.5*mean(sigmoid(predRealLD),"all") + ...
    0.5*mean(1-sigmoid(predGeneratedLD),"all");
discHDScore = 0.5*mean(sigmoid(predRealHD),"all") + ...
    0.5*mean(1-sigmoid(predGeneratedHD),"all");

% Combine scores into cell array
scores = {genHD2LDScore,genLD2HDScore,discLDScore,discHDScore};

% Calculate gradients of generators
genLD2HDGrad = dlgradient(genLossTotal,genLD2HD.Learnables,RetainData=true);
genHD2LDGrad = dlgradient(genLossTotal,genHD2LD.Learnables,RetainData=true);

% Calculate gradients of discriminators
discLDGrad = dlgradient(discLDLossTotal,discLD.Learnables,RetainData=true);
discHDGrad = dlgradient(discHDLossTotal,discHD.Learnables);

% Return mini-batch of images transforming low-dose CT into high-dose CT
imagesOutLDAndHDGenerated = {imageLD,imageHDGenerated};

% Return mini-batch of images transforming high-dose CT into low-dose CT
imagesOutHDAndLDGenerated = {imageHD,imageLDGenerated};
end
%% Supporting Functions
% Loss Functions
% The computeDiscLoss helper function calculates the discriminator loss. Each discriminator loss is a sum of two components:
% - The squared difference between a vector of ones and the predictions of the discriminator on real images, Y_real
% - The squared difference between a vector of zeros and the predictions of the discriminator on generated images, Yˆ_translated
% discriminatorLoss=(1−Y_real)^2+(0−Yˆ_translated)^2
function discLoss = computeDiscLoss(Yreal,Ytranslated)
    discLoss = mean(((1-Yreal).^2),"all") + ...
               mean(((0-Ytranslated).^2),"all");
end

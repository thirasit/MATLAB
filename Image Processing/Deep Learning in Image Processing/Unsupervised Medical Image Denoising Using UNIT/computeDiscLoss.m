%%% Supporting Functions
function discLoss = computeDiscLoss(Yreal,Ytranslated)
    discLoss = mean(((1-Yreal).^2),"all") + ...
               mean(((0-Ytranslated).^2),"all");
end
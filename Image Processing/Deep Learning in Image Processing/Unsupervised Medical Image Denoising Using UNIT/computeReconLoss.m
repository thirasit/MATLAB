%%% Supporting Functions
function reconLoss = computeReconLoss(Yreal,Yrecon)
    reconLoss = mean(abs(Yreal-Yrecon),"all");
end
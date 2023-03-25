function klLoss = computeKLLoss(hidden)
    klLoss = mean(abs(hidden.^2),"all");
end
%%% Helper Function
% The helper function computeRRSE computes the RRSE given the true response variable trueY and the predicted values predY.
% This code creates the computeRRSE helper function.
function rrse = computeRRSE(trueY,predY)
    error = trueY(:) - predY(:);
    meanY = mean(trueY(:),"omitnan");
    rrse = sqrt(sum(error.^2,"omitnan")/sum((trueY(:) - meanY).^2,"omitnan"));
end
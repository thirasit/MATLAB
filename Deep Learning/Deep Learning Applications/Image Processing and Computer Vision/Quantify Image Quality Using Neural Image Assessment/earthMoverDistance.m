%% Supporting Functions
%%% Loss Function
% The earthMoverDistance function calculates the EMD between the ground truth and predicted distributions for a specified r-norm value.
% The earthMoverDistance uses the computeCDF helper function to calculate the cumulative probabilities of the predicted distribution.
function loss = earthMoverDistance(YPred,cdfY,r)
    N = size(cdfY,1);
    cdfYPred = computeCDF(YPred);
    cdfDiff = (1/N) * (abs(cdfY - cdfYPred).^r);
    lossArray = sum(cdfDiff,1).^(1/r);
    loss = mean(lossArray);
    
end
function cdfY = computeCDF(Y)
% Given a probability mass function Y, compute the cumulative probabilities
    [N,miniBatchSize] = size(Y);
    L = repmat(triu(ones(N)),1,1,miniBatchSize);
    L3d = permute(L,[1 3 2]);
    prod = Y.*L3d;
    prodSum = sum(prod,1);
    cdfY = reshape(prodSum(:)',miniBatchSize,N)';
end

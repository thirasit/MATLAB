%%% Supporting Functions
% The calculateDistance helper function calculates the Mahalanobis distance between each embedding feature vector specified by XEmbeddings and the learned Gaussian distribution for the corresponding patch with mean specified by means and covariance matrix specified by covars.
function distances = calculateDistance(XEmbeddings,H,W,B,means,covars)
    distances = zeros([H*W 1 B]);
    for dIdx = 1:H*W
        distances(dIdx,1,:) = pdist2((squeeze(means(dIdx,:))),(squeeze(XEmbeddings(dIdx,:,:))'),"mahal",(squeeze(covars(dIdx,:,:))));
    end
end
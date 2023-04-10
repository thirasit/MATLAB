%%% Supporting Functions
%%% Model Predictions Function
% The modelPredictions function calculates the estimated probabilities, loss, and ground truth cumulative probabilities of mini-batches of data.
function [dlYPred,loss,cdfYOrig] = modelPredictions(dlnet,mbq)
    reset(mbq);
    loss = 0;
    numObservations = 0;
    dlYPred = [];    
    cdfYOrig = [];
    
    while hasdata(mbq)     
        [dlX,cdfY] = next(mbq);
        miniBatchSize = size(dlX,4);
        
        dlY = predict(dlnet,dlX);
        loss = loss + earthMoverDistance(dlY,cdfY,2)*miniBatchSize;
        dlYPred = [dlYPred dlY];
        cdfYOrig = [cdfYOrig cdfY];
        
        numObservations = numObservations + miniBatchSize;
        
    end
    loss = loss / numObservations;
end
%% Learning Rate Schedule Function
function currentLR = piecewiseLearningRateWithWarmup(iteration,epoch,learningRate,warmupPeriod,numEpochs)
% The piecewiseLearningRateWithWarmup function computes the current
% learning rate based on the iteration number.
    persistent warmUpEpoch;
    
    if iteration <= warmupPeriod
        % Increase the learning rate for the number of iterations in the warmup period.
        currentLR = learningRate*((iteration/warmupPeriod)^4);
        warmUpEpoch = epoch;
    elseif iteration >= warmupPeriod && epoch < warmUpEpoch+floor(0.6*(numEpochs-warmUpEpoch))
        % After the warmup period, keep the learning rate constant if the remaining number of epochs is less than 60 percent. 
        currentLR = learningRate;
        
    elseif epoch >= warmUpEpoch + floor(0.6*(numEpochs-warmUpEpoch)) && epoch < warmUpEpoch+floor(0.9*(numEpochs-warmUpEpoch))
        % If the remaining number of epochs is more than 60 percent but less
        % than 90 percent, multiply the learning rate by 0.1.
        currentLR = learningRate*0.1;
        
    else
        % If more than 90 percent of the epochs remain, multiply the learning
        % rate by 0.01.
        currentLR = learningRate*0.01;
    end
end

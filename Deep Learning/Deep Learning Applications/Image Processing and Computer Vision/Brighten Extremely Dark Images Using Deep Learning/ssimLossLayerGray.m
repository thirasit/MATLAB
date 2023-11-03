classdef ssimLossLayerGray < nnet.layer.RegressionLayer

% Copyright 2021 The MathWorks, Inc.
 
    methods
        function layer = ssimLossLayerGray()           
            layer.Name = 'ssimL1Loss';    
        end

        function loss = forwardLoss(~, Y, T)
            
            % Compute ssimLoss using a grayscale representation because the
            % metric is not well defined for color input
            ssimLoss = mean(1-multissim(iRGBToGray(Y),iRGBToGray(T),'NumScales',5),'all');
            L1loss =  mean(abs(Y-T),'all');
            
            alpha = 7/8;
            loss = alpha * ssimLoss + (1-alpha)* L1loss;
        end
        
    end
    
end

function y = iRGBToGray(rgb)
% This is a batched RGB to grayscale conversion.
% Y = 0.2989*R + 0.5810*G + 0.1140*B
    sizeIn = size(rgb,[1 2]);
    batchSize = size(rgb,4);
    weights = [0.2989;0.5810;0.1140];
    rgb = reshape(rgb,[],size(rgb,3),size(rgb,4));
    y = pagemtimes(rgb,weights);
    y = reshape(y,[sizeIn,1,batchSize]);
end
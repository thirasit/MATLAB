% Copyright 2018 The MathWorks, Inc.

classdef adaptiveNormalizationMu < nnet.layer.Layer
    
    properties (Learnable)
        % Layer learnable parameters        
        % Scaling coefficient  
        mu
        
    end
    
    methods
        function layer = adaptiveNormalizationMu( numChannels, name)
            % Create an adaptiveNormalizationMu with numChannels channels
            
            % Set layer name
            if nargin == 2
                layer.Name = name;
            end
            
            % Set layer description
            layer.Description = ...
                ['mu layer', num2str(numChannels), ' channels'];
            layer.mu = 0;
            
        end
        
        function Z = predict(layer,X)

            Z =  layer.mu*X;
            
        end
                
        
        function [dLdX, dMu] = backward(layer, ~, ~, dLdZ, ~)
            % Backward propagate the derivative of the loss function through

            dLdmu = sum(dLdZ(:));
            dLdX = dLdZ*layer.mu;
            dMu = dLdmu;
            
        end
    end
end
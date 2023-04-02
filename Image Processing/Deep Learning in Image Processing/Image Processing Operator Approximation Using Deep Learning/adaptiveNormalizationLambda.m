% Copyright 2018 The MathWorks, Inc.

classdef adaptiveNormalizationLambda < nnet.layer.Layer
    
    properties (Learnable)
        % Layer learnable parameters        
        % Scaling coefficient          
        lambda
    end
    
    methods
        function layer = adaptiveNormalizationLambda( numChannels, name)
            % Create an adaptiveNormalizationLambda with numChannels channels
            
            % Set layer name
            if nargin == 2
                layer.Name = name;
            end
            
            % Set layer description
            layer.Description = ...
                ['lambda layer', num2str(numChannels), ' channels'];
            layer.lambda = 1;
            
        end
        
        function Z = predict(layer,X)            
            Z =  layer.lambda*X;            
        end
        
        
        
        function [dLdX, dLambda] = backward(layer, X, ~, dLdZ, ~)
            % Backward propagate the derivative of the loss function through

            lambdaVal = dLdZ.*X;
            dLdLambda = sum(lambdaVal(:));
            dLdX = dLdZ*layer.lambda; 
           
            dLambda = dLdLambda;
    
        end
    end
end
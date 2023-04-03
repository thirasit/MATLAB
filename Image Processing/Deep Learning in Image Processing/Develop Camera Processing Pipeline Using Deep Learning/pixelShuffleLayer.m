classdef pixelShuffleLayer < nnet.layer.Layer

% Copyright 2021 The MathWorks, Inc.

    properties
        UpscaleFactor
    end
    
    methods
        function layer = pixelShuffleLayer(name,upscaleFactor)
            % Create a pixelShuffleLayer.
            % This function must have the same name as the class.

            layer.Name = name;
            layer.UpscaleFactor = upscaleFactor;

        end
        
        function X = predict(layer,X)
            % Forward input data through the layer at prediction time and
            % output the result.
            %
            % Inputs:
            %         layer       - Layer to forward propagate through
            %         X1, ..., Xn - Input data
            % Outputs:
            %         Z1, ..., Zm - Outputs of layer forward function
           
            % Layer forward function for prediction goes here.            
            scale_factor = layer.UpscaleFactor;
            sizeIn = size(X);
            outChannels = sizeIn(3) / (scale_factor^2);
            outHeight = sizeIn(1) * scale_factor;
            outWidth = sizeIn(2) * scale_factor;
            batchSize = size(X,4);
            
            temp = reshape(X,[sizeIn(1:2),scale_factor,scale_factor,outChannels,batchSize]);
            temp = permute(temp,[3 1 4 2 5 6]);
            X = reshape(temp,[outHeight,outWidth,outChannels,batchSize]);
            
        end
    end
end
classdef tanhScaledAndShiftedLayer < nnet.layer.Layer

% Copyright 2021 The MathWorks, Inc.

    properties
    end
    
    methods
        function layer = tanhScaledAndShiftedLayer(name)
            % (Optional) Create a myLayer.
            % This function must have the same name as the class.

            layer.Name = name;
        end
        
        function X = predict(~,X)
            % Forward input data through the layer at prediction time and
            % output the result.
            %
            % Inputs:
            %         layer       - Layer to forward propagate through
            %         X1, ..., Xn - Input data
            % Outputs:
            %         Z1, ..., Zm - Outputs of layer forward function
           
            X = 0.58*tanh(X)+0.5;
        end
    end
end
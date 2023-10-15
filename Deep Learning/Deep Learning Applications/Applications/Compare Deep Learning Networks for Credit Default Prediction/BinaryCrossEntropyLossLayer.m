classdef BinaryCrossEntropyLossLayer < nnet.layer.RegressionLayer
    
    methods
        function layer = BinaryCrossEntropyLossLayer(name)
            if isempty(name)
                layer.Name = "";
            else
                layer.Name = name;
            end
        end
        
        function loss = forwardLoss(~, Y, T)
            loss = crossentropy(Y, T, ...
                'DataFormat', 'CB', ...
                'TargetCategories','independent');
        end
    end
end
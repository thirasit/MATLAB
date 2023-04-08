%%% Supporting Functions
%%% Calculate Content Loss
% The contentLoss helper function calculates the weighted mean squared difference between the content image features and the transfer image features.
function loss = contentLoss(transferContentFeatures,contentFeatures,contentWeights)

    loss = 0;
    for i=1:numel(contentFeatures)
        temp = 0.5 .* mean((transferContentFeatures{1,i}-contentFeatures{1,i}).^2,"all");
        loss = loss + (contentWeights(i)*temp);
    end
end
function out = distanceFunction(xTest,xEnsemble)

% Use a function handle to compute a distance that weights each
% coordinate contribution differently.
W = [.1 .2 .3];            % coordinate weights
out = (sqrt((xTest - xEnsemble).^2 * W'));
       
end
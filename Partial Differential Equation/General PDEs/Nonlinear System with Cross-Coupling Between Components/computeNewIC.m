%%% Function Computing Initial Conditions
function newU0 = computeNewIC(resultsObject)
newU0 = 0.1*resultsObject.NodalSolution(:,:,end).';
end
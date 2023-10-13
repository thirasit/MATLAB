%% helperPreprocess
% The helper function helperPreprocess uses the maximum sample number to preprocess the data.
% The sample number indicates the signal length, which is consistent across the data set.
% A for-loop goes over the data set with a signal length filter to form sets of 52 signals.
% Each set is an element of a cell array.
% Each cell array represents a single simulation.
function processed = helperPreprocess(mydata,limit)
    H = size(mydata);
    processed = {};
    for ind = 1:limit:H
        x = mydata(ind:(ind+(limit-1)),4:end);
        processed = [processed; x'];
    end
end

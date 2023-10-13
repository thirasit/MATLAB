%% helperNormalize
% The helper function helperNormalize uses the data, mean, and standard deviation to normalize the data.
function data = helperNormalize(data,m,s)
    for ind = 1:size(data)
        data{ind} = (data{ind} - m)./s;
    end
end
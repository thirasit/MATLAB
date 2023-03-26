%%% Supporting Functions
% The addLabelData helper function creates a one-hot encoded representation of label information in data.
function [data,info] = addLabelData(data,info)
    if info.Label == categorical("normal")
        onehotencoding = 0;
    else
        onehotencoding = 1;
    end
    data = {data,onehotencoding};
end
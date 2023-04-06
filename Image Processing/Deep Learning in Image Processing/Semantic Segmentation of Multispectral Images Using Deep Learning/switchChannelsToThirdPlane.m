%switchChannelsToThirdPlane rearranges data with channels in the
% first dimension so that channels are in the third dimension.
%
%  OUT = switchChannelsToThirdPlane(IM) permutes the first dimension of IM
%  to its third dimension.

% Copyright 2017-2022 The MathWorks, Inc.

function out = switchChannelsToThirdPlane(im)
    
    for i = 1:size(im,1)
        out(:,:,i) = im(i,:,:);
    end
end
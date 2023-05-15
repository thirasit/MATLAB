function J = vehicleCostFcnLC(stage,x,u,dmv,params)
%   This is a helper function for example purposes and may be removed or
%   modified in the future.

% Copyright 2019-2021 The MathWorks, Inc.

%#codegen
Wdmv = 1;
Wx = [2.5e-5 0;0 1/9];
if stage == 1 % first stage
    J = dmv'*Wdmv*dmv;
elseif stage == 31 % last stage (p+1)
    J = (params-x(3:4))'*Wx*(params-x(3:4));
else % stage from 2 to p
    J = dmv'*Wdmv'*dmv + (params-x(3:4))'*Wx*(params-x(3:4));
end

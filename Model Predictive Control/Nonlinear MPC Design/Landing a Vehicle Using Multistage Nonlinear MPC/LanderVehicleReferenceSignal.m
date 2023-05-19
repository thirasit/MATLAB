function ref = LanderVehicleReferenceSignal(k, planned, pLander)
% Lander Vehicle reference signal generator.

% Copyright 2023 The MathWorks, Inc.

% k start from 1
last = numel(planned);
expectStartIdx = (k-1)*6+1;
expectEndIdx = (k+pLander)*6;
len = (pLander+1)*6;
ref = zeros(len,1);
if expectEndIdx<=last
    for ct=1:len
        ref(ct) = planned(expectStartIdx+ct-1);
    end
elseif expectStartIdx<=last
    copied = last - expectStartIdx + 1;
    for ct=1:copied
        ref(ct) = planned(expectStartIdx+ct-1);
    end
    missed = 6*(pLander+1)-copied;
    appended = repmat(planned(end-5:end),missed/6,1);
    ref(copied+1:end) = appended;
else
    for ct=0:6:len-1
        ref(ct+1:ct+6) = planned(end-5:end);
    end
end


% Copyright 2020 The MathWorks, Inc.

aPoseObsNow = interp1(timeObs,aPosesObs,time);
bPoseObsNow = interp1(timeObs,bPosesObs,time);

posesNow = [aPoseObsNow; bPoseObsNow];
paras{10} = posesNow; 
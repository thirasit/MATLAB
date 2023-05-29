% Copyright 2020 The MathWorks, Inc.

% Create a sequence of motions with desired frequency
tsObs = 0.1;
freqMotion = 1/45;

timeObs = 0:tsObs:30;
aPosesObs = repmat([0.4 0.35 0.35],length(timeObs),1);
aPosesObs(:,3) = 0.32 + 0.15 * sin( (2*pi*freqMotion)*timeObs');

bPosesObs = repmat([0.4 0.5 0.15],length(timeObs),1);
bPosesObs(:,1) = 0.38 + 0.15 * sin( (2*pi*freqMotion)*timeObs');

% Find pose of moving obstaclea at t=0
tNow = 0;
aPoseObsNow = interp1(timeObs,aPosesObs,tNow);
bPoseObsNow = interp1(timeObs,bPosesObs,tNow);
posesNow = [aPoseObsNow ; bPoseObsNow];


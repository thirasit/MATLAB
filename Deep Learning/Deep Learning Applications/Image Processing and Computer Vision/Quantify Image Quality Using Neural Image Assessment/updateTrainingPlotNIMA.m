function updateTrainingPlotNIMA(hAx,loss,epoch,iteration,start)
% The helper function updateTrainingPlotNIMA updates training plot with 
% respective loss values.
%
% Copyright 2020 The MathWorks, Inc.

D = duration(0,0,toc(start),'Format','hh:mm:ss');
loss = double(gather(extractdata(loss)));
addpoints(hAx,iteration,loss)
title("Epoch: "+epoch+", Iter: "+iteration+", Elapsed: "+string(D))
drawnow   

end
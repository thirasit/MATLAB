function updateTrainingPlotRAWToRGB(batchLine,validationLine,iteration,loss,start,epoch,validationQueue,...
    valSetSize,valBatchSize,net,vggNet,contentWeight)

% Copyright 2021 The MathWorks, Inc.

% Use to control frequency of update to plots
miniBatchLossFrequency = 5;
validationFrequency = 200;

if ~mod(iteration,miniBatchLossFrequency) || iteration == 1
    updateLossLine(batchLine,iteration,loss,start,epoch);
end

if ~mod(iteration,validationFrequency) || iteration == 1
    valLoss = computeValidationLoss(net,validationQueue,vggNet,valSetSize,valBatchSize,contentWeight);
    updateLossLine(validationLine,iteration,valLoss,start,epoch);
end

end

function valLoss = computeValidationLoss(net,validationQueue,vggNet,valSetSize,valBatchSize,contentWeight)

lossTotal = 0.0;
while hasdata(validationQueue)
    [Xpatch,Yexp] = next(validationQueue);
    Yexp = gpuArray(dlarray(Yexp,'SSCB'));
    Ypred = forward(net,Xpatch);
    
    valLoss = maeLoss(Yexp,Ypred) + contentWeight.*contentLoss(vggNet,Yexp,Ypred);
    
    lossTotal = lossTotal + valLoss;
end

valLoss = lossTotal / (valSetSize / valBatchSize);
reset(validationQueue);

end

function updateLossLine(hLine,t,lossVal,start,epoch)

lossVal = double(gather(extractdata(lossVal)));
addpoints(hLine,t,lossVal);
D = duration(0,0,toc(start),'Format','hh:mm:ss');
title("Epoch" + epoch + ", Elapsed: " + string(D));
drawnow limitrate

end

function loss = maeLoss(Y,T)
loss = mean(abs(Y-T),'all');
end

function loss = mseLoss(Y,T)
loss = mean((Y-T).^2,'all');
end

function loss = contentLoss(net,Y,T)

layers = ["relu1_1","relu1_2","relu2_1","relu2_2","relu3_1","relu3_2","relu3_3","relu4_1"];
[T1,T2,T3,T4,T5,T6,T7,T8] = forward(net,T,'Outputs',layers);
[X1,X2,X3,X4,X5,X6,X7,X8] = forward(net,Y,'Outputs',layers);

l1 = mseLoss(X1,T1);
l2 = mseLoss(X2,T2);
l3 = mseLoss(X3,T3);
l4 = mseLoss(X4,T4);
l5 = mseLoss(X5,T5);
l6 = mseLoss(X6,T6);
l7 = mseLoss(X7,T7);
l8 = mseLoss(X8,T8);

% Weight each layer activation roughly equally
loss = l1 + 0.0449*l2 + 0.0107*l3 + .0023*l4 + 6.9445e-04*l5 +...
            2.0787e-04*l6 + 2.0118e-04*l7 + 6.4759e-04*l8;

end
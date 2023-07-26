%%% Model Loss Function
% The modelLoss helper function takes as inputs a dlnetwork object pinn and a mini-batch of input data XY.
% The function returns the loss and the gradients of the loss with respect to the learnable parameters in pinn.
% To compute the gradients automatically, use the dlgradient function.
% Train the model by enforcing that, given an input (x,y), the output of the network u(x,y) fulfills the Poisson equation and the boundary conditions.
function [loss,gradients] = modelLoss(model,net,XY,pdeCoeffs)
dim = 2;
[U,~] = forward(net,XY);

% Compute gradients of U and Laplacian of U.
gradU = dlgradient(sum(U,"all"),XY,EnableHigherDerivatives=true);
Laplacian = 0;
for i=1:dim
    gradU2 = dlgradient(sum(pdeCoeffs.c.*gradU(i,:),"all"), ...
                          XY,EnableHigherDerivatives=true);
    Laplacian = gradU2(i,:)+Laplacian;
end

% Enforce PDE. Calculate lossF.
res = -pdeCoeffs.f - Laplacian + pdeCoeffs.a.*U;
zeroTarget = zeros(size(res),"like",res);
lossF = mse(res,zeroTarget);

% Enforce boundary conditions. Calculate lossU.
actualBC = []; % Boundary information
BC_XY = []; % Boundary coordinates
% Loop over the boundary edges and find boundary
% coordinates and actual BC assigned to PDE model.
numBoundaries = model.Geometry.NumEdges;
for i=1:numBoundaries
    BCi = findBoundaryConditions(model.BoundaryConditions,"Edge",i);
    BCiNodes = findNodes(model.Mesh,"region","Edge",i);
    BC_XY = [BC_XY,model.Mesh.Nodes(:,BCiNodes)]; %#ok<AGROW> 
    actualBCi = ones(1,numel(BCiNodes))*BCi.u;
    actualBC = [actualBC actualBCi]; %#ok<AGROW>
end
BC_XY = dlarray(BC_XY,"CB"); % Format the coordinates
[predictedBC,~] = forward(net,BC_XY);
lossU = mse(predictedBC,actualBC);

% Combine the losses. Use a weighted linear combination 
% of loss (lossF and lossU) terms.
lambda = 0.4; % Weighting factor
loss = lambda*lossF + (1-lambda)*lossU;

% Calculate gradients with respect to the learnable parameters.
gradients = dlgradient(loss,net.Learnables); 
end

%% Eigenvalues and Eigenmodes of Square
% This example shows how to compute the eigenvalues and eigenmodes of a square domain.

% The eigenvalue PDE problem is −Δu=λu.
% This example finds the eigenvalues smaller than 10 and the corresponding eigenmodes.

% Create a model. Import and plot the geometry.
% The geometry description file for this problem is called squareg.m.
figure
model = createpde();
geometryFromEdges(model,@squareg);

pdegplot(model,"EdgeLabels","on")
ylim([-1.5,1.5])
axis equal

% Specify the Dirichlet boundary condition u=0 for the left boundary.
applyBoundaryCondition(model,"dirichlet","Edge",4,"u",0);

% Specify the zero Neumann boundary condition for the upper and lower boundary.
applyBoundaryCondition(model,"neumann","Edge",[1,3],"g",0,"q",0);

% Specify the generalized Neumann condition ∂u/∂n − 3/4u = 0 for the right boundary.
applyBoundaryCondition(model,"neumann","Edge",2,"g",0,"q",-3/4);

% The eigenvalue PDE coefficients for this problem are c = 1, a = 0, and d = 1.
% You can enter the eigenvalue range r as the vector [-Inf 10].
specifyCoefficients(model,"m",0,"d",1,"c",1,"a",0,"f",0);
r = [-Inf,10];

% Create a mesh and solve the problem.
generateMesh(model,"Hmax",0.05);
results = solvepdeeig(model,r);

% There are six eigenvalues smaller than 10 for this problem.
l = results.Eigenvalues

% Plot the first and last eigenfunctions in the specified range.
u = results.Eigenvectors;
pdeplot(model,"XYData",u(:,1));

pdeplot(model,"XYData",u(:,length(l)));

figure
imshow("Opera Snapshot_2023-07-21_072644_www.mathworks.com.png")
axis off;

% Look at the difference between the first and the second eigenvalue compared to π^2/4:
l(2) - l(1) - pi^2/4

% Likewise, the fifth eigenmode is made up of the first eigenmode in the x direction and the third eigenmode in the y direction. As expected, l(5)-l(1) is approximately equal to π^2:
l(5) - l(1) - pi^2

% You can explore higher modes by increasing the search range to include eigenvalues greater than 10.

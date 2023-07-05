%% Electrostatic Potential in Air-Filled Frame
% This example shows how to find the electrostatic potential in an air-filled annular quadrilateral frame.

% The PDE governing this problem is the Poisson equation
%−∇⋅(ε∇V)=ρ.

% Here, ρ is the space charge density, and ε is the absolute dielectric permittivity of the material.
% The toolbox uses the relative permittivity of the material ε_r, such that ε=ε_r x ε_0, where ε_0 is the absolute permittivity of the vacuum.
% The relative permittivity for air is 1.00059.
% Note that the permittivity of the air does not affect the result in this example as long as the coefficient is constant.

% Assuming that there is no charge in the domain, the Poisson equation simplifies to the Laplace equation: ΔV=0.
% For this example, use the following boundary conditions:
% - The electrostatic potential at the inner boundary is 1000V.
% - The electrostatic potential at the outer boundary is 0V.

% Create an electromagnetic model for electrostatic analysis.
emagmodel = createpde("electromagnetic","electrostatic");

% Import and plot a geometry of a simple frame.
figure
importGeometry(emagmodel,"Frame.STL");
pdegplot(emagmodel,"EdgeLabels","on")

% Specify the vacuum permittivity value in the SI system of units.
emagmodel.VacuumPermittivity = 8.8541878128E-12;

% Specify the relative permittivity of the material.
electromagneticProperties(emagmodel,"RelativePermittivity",1.00059); 

% Specify the electrostatic potential at the inner boundary.
electromagneticBC(emagmodel,"Voltage",1000,"Edge",[1 2 4 6]);

% Specify the electrostatic potential at the outer boundary.
electromagneticBC(emagmodel,"Voltage",0,"Edge",[3 5 7 8]); 

% Generate the mesh.
generateMesh(emagmodel); 

% Solve the model.
% Plot the electric potential using the Contour parameter to display equipotential lines.
figure
R = solve(emagmodel); 
u = R.ElectricPotential;
pdeplot(emagmodel,"XYData",u,"Contour","on")

%% Scattering Problem
% Solve a simple scattering problem, where you compute the waves reflected by an object illuminated by incident waves.
% This example shows how to solve a scattering problem using the electromagnetic workflow.
% For the general PDE workflow, see Helmholtz Equation on Disk with Square Hole.

% For this problem, assume that the domain is an infinite horizontal membrane that is subjected to small vertical displacements.
% The membrane is fixed at the object boundary.
% The medium is homogeneous, and the phase velocity (propagation speed) of a wave, α, is constant.
% For this problem, assume α=1.
% In this case, the frequency wave number equals the frequency, k=ω/α= ω.

% To solve the scattering problem, first create an electromagnetic model for harmonic analysis.
emagmodel = createpde("electromagnetic","harmonic");

% Specify the frequency as 4π.
omega = 4*pi;

% Represent the square surface with a diamond-shaped hole.
% Define a diamond in a square, place them in one matrix, and create a set formula that subtracts the diamond from the square.
square = [3; 4; -5; -5; 5; 5; -5; 5; 5; -5];
diamond = [2; 4; 2.1; 2.4; 2.7; 2.4; 1.5; 1.8; 1.5; 1.2];
gd = [square,diamond];
ns = char('square','diamond')';
sf = 'square - diamond';

% Create the geometry.
g = decsg(gd,sf,ns);
geometryFromEdges(emagmodel,g);

% Include the geometry in the model and plot it with the edge labels.
figure; 
pdegplot(emagmodel,"EdgeLabels","on"); 
xlim([-6,6])
ylim([-6,6])

% Specify the vacuum permittivity and permeability values as 1.
emagmodel.VacuumPermittivity = 1;
emagmodel.VacuumPermeability = 1;

% Specify the relative permittivity, relative permeability, and conductivity of the material.
electromagneticProperties(emagmodel,"RelativePermittivity",1, ...
                                    "RelativePermeability",1, ...
                                    "Conductivity",0);

% Apply the absorbing boundary condition on the edges of the square.
% Specify the thickness and attenuation rate for the absorbing region by using the Thickness, Exponent, and Scaling arguments.
electromagneticBC(emagmodel,"Edge",[1 2 7 8], ...
                            "FarField","absorbing", ...
                            "Thickness",2, ...
                            "Exponent",4, ...
                            "Scaling",1);

% Apply the boundary condition on the diamond edges.
innerBCFunc = @(location,~) [-exp(-1i*omega*location.x); ...
                            zeros(1,length(location.x))];
bInner = electromagneticBC(emagmodel,"Edge",[3 4 5 6], ...
                                     "ElectricField",innerBCFunc);

% Generate a mesh.
generateMesh(emagmodel,"Hmax",0.1);

% Solve the harmonic analysis model for the frequency ω=4π.
result = solve(emagmodel,"Frequency",omega);

% Plot the real part of the x-component of the resulting electric field.
u = result.ElectricField;

figure
pdeplot(emagmodel,"XYData",real(u.Ex),"Mesh","off");
colormap(jet)

% Interpolate the resulting electric field to a grid covering the portion of the geometry, for x and y from -1 to 4.
v = linspace(-1,4,101);
[X,Y] = meshgrid(v);
Eintrp = interpolateHarmonicField(result,X,Y);

% Reshape Eintrp.Ex and plot the x-component of the resulting electric field.
EintrpX = reshape(Eintrp.ElectricField.Ex,size(X));

figure
surf(X,Y,real(EintrpX),"LineStyle","none");
view(0,90)
colormap(jet)

% Using the solutions for a vector of frequencies, create an animation showing the corresponding solution to the time-dependent wave equation.
result = solve(emagmodel,"Frequency",omega/10:omega);
figure
for m = 1:length(omega/10:omega)
    u = result.ElectricField;
    pdeplot(emagmodel,"XYData",real(u.Ex(:,m)),"Mesh","off");
    colormap(jet)
    M(m) = getframe;
end

% To play the animation, use the movie function.
% For example, to play the animation five times in a loop with 3 frames per second, use the movie(M,5,3) command.

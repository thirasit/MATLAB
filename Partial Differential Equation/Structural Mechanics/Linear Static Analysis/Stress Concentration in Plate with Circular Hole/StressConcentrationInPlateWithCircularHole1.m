%% Stress Concentration in Plate with Circular Hole
% Perform a 2-D plane-stress elasticity analysis.

% A thin rectangular plate under a uniaxial tension has a uniform stress distribution.
% Introducing a circular hole in the plate disturbs the uniform stress distribution near the hole, resulting in a significantly higher than average stress.
% Such a thin plate, subject to in-plane loading, can be analyzed as a 2-D plane-stress elasticity problem.
% In theory, if the plate is infinite, then the stress near the hole is three times higher than the average stress.
% For a rectangular plate of finite width, the stress concentration factor is a function of the ratio of hole diameter to the plate width.
% This example approximates the stress concentration factor using a plate of a finite width.

%%% Create Structural Model and Include Geometry
% Create a structural model for static plane-stress analysis.
model = createpde("structural","static-planestress");

% The plate must be sufficiently long, so that the applied loads and boundary conditions are far from the circular hole.
% This condition ensures that a state of uniform tension prevails in the far field and, therefore, approximates an infinitely long plate.
% In this example the length of the plate is four times greater than its width.
% Specify the following geometric parameters of the problem.
radius = 20.0;
width = 50.0;
totalLength = 4*width;

% Define the geometry description matrix (GDM) for the rectangle and circle.
R1 = [3 4 -totalLength  totalLength ...
           totalLength -totalLength ...
          -width -width width width]'; 
C1 = [1 0 0 radius 0 0 0 0 0 0]';

% Define the combined GDM, name-space matrix, and set formula to construct decomposed geometry using decsg.
gdm = [R1 C1];
ns = char('R1','C1');
g = decsg(gdm,'R1 - C1',ns');

% Create the geometry and include it into the structural model.
geometryFromEdges(model,g);

% Plot the geometry displaying edge labels.
figure
pdegplot(model,"EdgeLabel","on");
axis([-1.2*totalLength 1.2*totalLength -1.2*width 1.2*width])
title("Geometry with Edge Labels")

% Plot the geometry displaying vertex labels.
figure
pdegplot(model,"VertexLabels","on");
axis([-1.2*totalLength 1.2*totalLength -1.2*width 1.2*width])
title("Geometry with Vertex Labels")

%%% Specify Model Parameters
% Specify Young's modulus and Poisson's ratio to model linear elastic material behavior. Remember to specify physical properties in consistent units.
structuralProperties(model,"YoungsModulus",200E3,"PoissonsRatio",0.25);

% Restrain all rigid-body motions of the plate by specifying sufficient constraints.
% For static analysis, the constraints must also resist the motion induced by applied load.

% Set the x-component of displacement on the left edge (edge 3) to zero to resist the applied load.
% Set the y-component of displacement at the bottom left corner (vertex 3) to zero to restraint the rigid body motion.
structuralBC(model,"Edge",3,"XDisplacement",0);
structuralBC(model,"Vertex",3,"YDisplacement",0);

% Apply the surface traction with a non-zero x-component on the right edge of the plate.
structuralBoundaryLoad(model,"Edge",1,"SurfaceTraction",[100;0]);

%%% Generate Mesh and Solve
% To capture the gradation in solution accurately, use a fine mesh.
% Generate the mesh, using Hmax to control the mesh size.
generateMesh(model,"Hmax",radius/6);

% Plot the mesh.
figure
pdemesh(model)

% Solve the plane-stress elasticity model.
R = solve(model);

%%% Plot Stress Contours
% Plot the x-component of the normal stress distribution.
% The stress is equal to applied tension far away from the circular boundary.
% The maximum value of stress occurs near the circular boundary.
figure
pdeplot(model,"XYData",R.Stress.sxx,"ColorMap","jet")
axis equal
title("Normal Stress Along x-Direction")

%%% Interpolate Stress
% To see the details of the stress variation near the circular boundary, first define a set of points on the boundary.
thetaHole = linspace(0,2*pi,200);
xr = radius*cos(thetaHole);
yr = radius*sin(thetaHole);
CircleCoordinates = [xr;yr];

% Then interpolate stress values at these points by using interpolateStress.
% This function returns a structure array with its fields containing interpolated stress values.
stressHole = interpolateStress(R,CircleCoordinates);

% Plot the normal direction stress versus angular position of the interpolation points.
figure
plot(thetaHole,stressHole.sxx)
xlabel("\theta")
ylabel("\sigma_{xx}")
title("Normal Stress Around Circular Boundary")

%%% Solve the Same Problem Using Symmetric Model
% The plate with a hole model has two axes of symmetry.
% Therefore, you can model a quarter of the geometry.
% The following model solves a quadrant of the full model with appropriate boundary conditions.

% Create a structural model for the static plane-stress analysis.
symModel = createpde("structural","static-planestress");

% Create the geometry that represents one quadrant of the original model.
% You do not need to create additional edges to constrain the model properly.
R1 = [3 4 0 totalLength/2 totalLength/2 ...
      0 0 0 width width]';
C1 = [1 0 0 radius 0 0 0 0 0 0]'; 
gm = [R1 C1];
sf = 'R1-C1';
ns = char('R1','C1');
g = decsg(gm,sf,ns');
geometryFromEdges(symModel,g);

% Plot the geometry displaying the edge labels.
figure
pdegplot(symModel,"EdgeLabel","on");
axis equal
title("Symmetric Quadrant with Edge Labels")

% Specify structural properties of the material.
structuralProperties(symModel,"YoungsModulus",200E3, ...
                              "PoissonsRatio",0.25);

% Apply symmetric constraints on the edges 3 and 4.
structuralBC(symModel,"Edge",[3 4],"Constraint","symmetric");

% Apply surface traction on the edge 1.
structuralBoundaryLoad(symModel,"Edge",1,"SurfaceTraction",[100;0]);

% Generate mesh and solve the symmetric plane-stress model.
generateMesh(symModel,"Hmax",radius/6);
Rsym = solve(symModel);

% Plot the x-component of the normal stress distribution.
% The results are identical to the first quadrant of the full model.
figure
pdeplot(symModel,"XYData",Rsym.Stress.sxx,"ColorMap","jet");
axis equal
title("Normal Stress Along x-Direction for Symmetric Model")

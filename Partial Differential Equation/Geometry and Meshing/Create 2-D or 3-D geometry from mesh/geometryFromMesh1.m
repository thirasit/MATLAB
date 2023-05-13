%% Create 2-D or 3-D geometry from mesh

%%% Geometry from Volume Mesh
% Import a tetrahedral mesh into a PDE model.

% Load a tetrahedral mesh into your workspace.
% The tetmesh file ships with your software.
% Put the data in the correct shape for geometryFromMesh.
load tetmesh
nodes = X';
elements = tet';

% Create a PDE model and import the mesh into the model.
model = createpde();
geometryFromMesh(model,nodes,elements);

% View the geometry and face numbers.
figure
pdegplot(model,"FaceLabels","on","FaceAlpha",0.5)

%%% Geometry from Convex Hull
% Create a geometric block from the convex hull of a mesh grid of points.

% Create a 3-D mesh grid.
[x,y,z] = meshgrid(-2:4:2);

% Create the convex hull.
x = x(:);
y = y(:);
z = z(:);
K = convhull(x,y,z);

% Put the data in the correct shape for geometryFromMesh.
nodes = [x';y';z'];
elements = K';

% Create a PDE model and import the mesh.
model = createpde();
geometryFromMesh(model,nodes,elements);

% View the geometry and face numbers.
figure
pdegplot(model,"FaceLabels","on","FaceAlpha",0.5)

%%% Geometry from alphaShape
% Create a 3-D geometry using the MATLAB® alphaShape function.
% First, create an alphaShape object of a block with a cylindrical hole.
% Then import the geometry into a PDE model from the alphaShape boundary.

% Create a 2-D mesh grid.
[xg,yg] = meshgrid(-3:0.25:3);
xg = xg(:);
yg = yg(:);

% Create a unit disk. 
% Remove all the mesh grid points that fall inside the unit disk, and include the unit disk points.
t = (pi/24:pi/24:2*pi)';
x = cos(t);
y = sin(t);
circShp = alphaShape(x,y,2);
in = inShape(circShp,xg,yg);
xg = [xg(~in); cos(t)];
yg = [yg(~in); sin(t)];

% Create 3-D copies of the remaining mesh grid points, with the z-coordinates ranging from 0 through 1. 
% Combine the points into an alphaShape object.
zg = ones(numel(xg),1);
xg = repmat(xg,5,1);
yg = repmat(yg,5,1);
zg = zg*(0:.25:1);
zg = zg(:);
shp = alphaShape(xg,yg,zg);

% Obtain a surface mesh of the alphaShape object.
[elements,nodes] = boundaryFacets(shp);

% Put the data in the correct shape for geometryFromMesh.
nodes = nodes';
elements = elements';

% Create a PDE model and import the surface mesh.
model = createpde();
geometryFromMesh(model,nodes,elements);

% View the geometry and face numbers.
figure
pdegplot(model,"FaceLabels","on","FaceAlpha",0.5)

% To use the geometry in an analysis, create a volume mesh.
generateMesh(model);

%%% 2-D Multidomain Geometry
% Create a 2-D multidomain geometry from a mesh.

% Load information about nodes, elements, and element-to-domain correspondence into your workspace.
% The file MultidomainMesh2D ships with your software.
load MultidomainMesh2D

% Create a PDE model.
model = createpde;

% Import the mesh into the model.
geometryFromMesh(model,nodes,elements,ElementIdToRegionId);

% View the geometry and face numbers.
figure
pdegplot(model,"FaceLabels","on")

%%% 3-D Multidomain Geometry
% Create a 3-D multidomain geometry from a mesh.

% Load information about nodes, elements, and element-to-domain correspondence into your workspace.
% The file MultidomainMesh3D ships with your software.
load MultidomainMesh3D

% Create a PDE model.
model = createpde;

% Import the mesh into the model.
geometryFromMesh(model,nodes,elements,ElementIdToRegionId);

% View the geometry and cell numbers.
figure
pdegplot(model,"CellLabels","on")

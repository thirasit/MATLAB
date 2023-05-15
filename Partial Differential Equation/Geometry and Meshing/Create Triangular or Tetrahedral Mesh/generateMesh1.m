%% Create Triangular or Tetrahedral Mesh
%%% Generate 2-D Mesh
% Generate the default 2-D mesh for the L-shaped geometry.
% Create a PDE model and include the L-shaped geometry.
model = createpde(1);
geometryFromEdges(model,@lshapeg);

% Generate the default mesh for the geometry.
generateMesh(model);

% View the mesh.
figure
pdeplot(model)

%%% Generate 3-D Mesh
% Create a mesh that is finer than the default.
% Create a PDE model and include the BracketTwoHoles geometry.
model = createpde(1);
importGeometry(model,"BracketTwoHoles.stl");

% Generate a default mesh for comparison.
generateMesh(model)

% View the mesh.
figure
pdeplot3D(model)

% Create a mesh with target maximum element size 5 instead of the default 7.3485.
generateMesh(model,"Hmax",5)

% View the mesh.
figure
pdeplot3D(model)

%%% Refine Mesh on Specified Edges and Vertices
% Generate a 2-D mesh with finer spots around the specified edges and vertices.
% Create a model.
model = createpde;

% Create and plot a 2-D geometry representing a circle with a diamond-shaped hole in its center.
figure
g = geometryFromEdges(model,@scatterg);
pdegplot(g,"VertexLabels","on","EdgeLabels","on")

% Generate a mesh for this geometry using the default mesh parameters.
m1 = generateMesh(model)

% Plot the resulting mesh.
figure
pdeplot(m1)

% Generate a mesh with the target size on edge 1, which is smaller than the target minimum element size, MinElementSize, of the default mesh.
m2 = generateMesh(model,"Hedge",{1,0.001})

% Plot the resulting mesh.
figure
pdeplot(m2)

% Generate a mesh specifying the target sizes for edge 1 and vertices 6 and 7.
m3 = generateMesh(model,"Hedge",{1,0.001},"Hvertex",{[6 7],0.002})

% Plot the resulting mesh.
figure
pdeplot(m3)

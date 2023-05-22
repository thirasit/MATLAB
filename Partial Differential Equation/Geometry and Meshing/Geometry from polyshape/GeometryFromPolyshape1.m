%% Geometry from polyshape
% This example shows how to create a polygonal geometry using the MATLAB® polyshape function.
% Then use the triangulated representation of the geometry as an input mesh for the geometryFromMesh function.

% Create and plot a polyshape object of a square with a hole.
t = pi/12:pi/12:2*pi;
pgon = polyshape({[-0.5 -0.5 0.5 0.5], 0.25*cos(t)}, ...
                 {[0.5 -0.5 -0.5 0.5], 0.25*sin(t)})

figure
plot(pgon)
axis equal

% Create a triangulation representation of this object.
tr = triangulation(pgon);

% Create a PDE model.
model = createpde;

% With the triangulation data as a mesh, use the geometryFromMesh function to create a geometry.
% Plot the geometry.
tnodes = tr.Points';
telements = tr.ConnectivityList';

figure
geometryFromMesh(model,tnodes,telements);
pdegplot(model)

% Plot the mesh.
figure
pdemesh(model)

% Because the triangulation data resulted in a low-quality mesh, generate a new finer mesh for further analysis.
generateMesh(model)

% Plot the mesh.
figure
pdemesh(model)

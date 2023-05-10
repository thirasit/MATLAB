%% Import geometry from STL or STEP file
%%% Import 3-D Geometry from STL File Without Creating Model

% Create a geometry object from an STL geometry file.
gm = importGeometry("ForearmLink.stl");

% Plot the geometry.
figure
pdegplot(gm)

%%% Import Planar Geometry from STL File into Model
% Import a planar STL geometry and include it in a PDE model.
% When importing a planar geometry, importGeometry converts it to a 2-D geometry by mapping it to the xy-plane.

% Create a PDEModel container.
model = createpde;

% Import a geometry into the container.
importGeometry(model,"PlateHolePlanar.stl")

% Plot the geometry with the edge labels.
figure
pdegplot(model,"EdgeLabels","on")

%%% Import 3-D Geometry from STEP File
% Create a geometry object from a STEP geometry file.
gm = importGeometry("BlockWithHole.step");

% Plot the geometry.
figure
pdegplot(gm,"FaceAlpha",0.3)

% Now import the same geometry while specifying the relative sag.
% You can use this parameter to control the accuracy of the geometry import.
gm = importGeometry("BlockWithHole.step","MaxRelativeDeviation",10);

% Plot the geometry.
figure
pdegplot(gm,"FaceAlpha",0.3)

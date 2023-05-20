%% STL File Import
% This example shows how to import a geometry from an STL file, and then plot the geometry.
% Generally, you create the STL file by exporting from a CAD system, such as SolidWorks®.
% For best results, export a fine (not coarse) STL file in binary (not ASCII) format.
% After importing, view the geometry using the pdegplot function.
% To see the face IDs, set the FaceLabels name-value pair to "on".

% View the geometry examples included with Partial Differential Equation Toolbox™.
figure
gm = importGeometry("Torus.stl");
pdegplot(gm)

figure
gm = importGeometry("Block.stl");
pdegplot(gm,"FaceLabels","on")

figure
gm = importGeometry("Plate10x10x1.stl");
pdegplot(gm,"FaceLabels","on")

figure
gm = importGeometry("Tetrahedron.stl");
pdegplot(gm,"FaceLabels","on")

figure
gm = importGeometry("BracketWithHole.stl");
pdegplot(gm,"FaceLabels","on")

figure
gm = importGeometry("DampingMounts.stl");
pdegplot(gm,"CellLabels","on")

figure
gm = importGeometry("MotherboardFragment1.stl");
pdegplot(gm)

figure
gm = importGeometry("PlateHoleSolid.stl");
pdegplot(gm,"FaceLabels","on")

figure
gm = importGeometry("PlateSquareHoleSolid.stl");
pdegplot(gm)

figure
gm = importGeometry("SquareBeam.stl");
pdegplot(gm,"FaceLabels","on")

figure
gm = importGeometry("BracketTwoHoles.stl");
pdegplot(gm,"FaceLabels","on")

% To see hidden portions of the geometry, rotate the figure using Rotate 3D button  or the view function.
% You can rotate the angle bracket to obtain the following view.
figure
pdegplot(gm,"FaceLabels","on")
view([-24 -19])

figure
gm = importGeometry("ForearmLink.stl");
pdegplot(gm,"FaceLabels","on");

figure
pdegplot(gm,"FaceLabels","on","FaceAlpha",0.5)

% When you import a planar STL geometry, the toolbox converts it to a 2-D geometry by mapping it to the X-Y plane.
figure
gm = importGeometry("PlateHolePlanar.stl");
pdegplot(gm,"EdgeLabels","on")

figure
gm = importGeometry("PlateSquareHolePlanar.stl");
pdegplot(gm);

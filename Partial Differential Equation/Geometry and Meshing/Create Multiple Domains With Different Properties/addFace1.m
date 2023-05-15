%% Create Multiple Domains With Different Properties
%%% Fill Void Region in 2-D Geometry
% Add a face to a 2-D geometry to fill an internal void.
% Create a PDE model.
model = createpde();

% Import the geometry. This geometry has one face.
gm = importGeometry(model,"PlateSquareHolePlanar.stl")

% Plot the geometry and display the face labels.
figure
pdegplot(gm,"FaceLabels","on")

% Zoom in and display the edge labels of the small hole at the center.
figure
pdegplot(gm,"EdgeLabels","on")
axis([49 51 99 101])

% Fill the hole by adding a face.
% The number of faces in the geometry changes to 2.
gm = addFace(gm,[1 8 4 5])

% Plot the modified geometry and display the face labels.
figure
pdegplot(gm,"FaceLabels","on")

%%% Split Cells in 3-D Geometry
% Add a face in a 3-D geometry to split a cell into two cells.
% Create a PDE model.
model = createpde();

% Import the geometry.
% The geometry consists of one cell.
gm = importGeometry(model,"MotherboardFragment1.stl")

% Plot the geometry and display the edge labels.
% Zoom in on the corresponding part of the geometry to see the edge labels there more clearly.
figure
pdegplot(gm,"EdgeLabels","on","FaceAlpha",0.5)

xlim([-0.05 0.05])
ylim([-0.05 0.05])
zlim([0 0.05])

% Split the cuboid on the right side into a separate cell.
% For this, add a face bounded by edges 1, 3, 6, and 12.
[gm,ID] = addFace(gm,[1 3 6 12])

% Plot the modified geometry and display the cell labels.
figure
pdegplot(gm,"CellLabels","on","FaceAlpha",0.5)

% Now split the cuboid on the left side of the board and all cylinders into separate cells by adding a face at the bottom of each shape. 
% To see edge labels more clearly, zoom and rotate the plot.
% Use a cell array to add several new faces simultaneously.
[gm,IDs] = addFace(gm,{[5 7 8 10], ...
                        30, ...
                        31, ...
                        32, ...
                        33, ...
                        13})

% Plot the modified geometry and display the cell labels.
figure
pdegplot(gm,"CellLabels","on","FaceAlpha",0.5)

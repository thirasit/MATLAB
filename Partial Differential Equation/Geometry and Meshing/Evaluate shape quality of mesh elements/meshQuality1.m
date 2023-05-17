%% Evaluate Shape Quality of Mesh Elements

%%% Element Quality of 3-D Mesh
% Evaluate the shape quality of the elements of a 3-D mesh.
% Create a PDE model.
model = createpde;

% Include and plot the following geometry.
figure
importGeometry(model,"PlateSquareHoleSolid.stl");
pdegplot(model)

% Create and plot a coarse mesh.
mesh = generateMesh(model,"Hmax",35)

figure
pdemesh(model)

% Evaluate the shape quality of all mesh elements.
% Display the first five values.
Q = meshQuality(mesh);
Q(1:5)

% Find the elements with the quality values less than 0.2.
elemIDs = find(Q < 0.2);

% Highlight these elements in blue on the mesh plot.
figure
pdemesh(mesh,"FaceAlpha",0.5)
hold on
pdemesh(mesh.Nodes,mesh.Elements(:,elemIDs), ...
                  "FaceColor","blue", ...
                  "EdgeColor","blue")

% Plot the element quality in a histogram.
figure
hist(Q)
xlabel("Element Shape Quality","fontweight","b")
ylabel("Number of Elements","fontweight","b")

% Find the worst quality value.
Qworst = min(Q)

% Find the corresponding element IDs.
elemIDs = find(Q==Qworst)

%%% Element Quality of 2-D Mesh
% Evaluate the shape quality of the elements of a 2-D mesh.
% Create a PDE model.
model = createpde;

% Include and plot the following geometry.
figure
importGeometry(model,"PlateSquareHolePlanar.stl");
pdegplot(model)

% Create and plot a coarse mesh.
mesh = generateMesh(model,"Hmax",20)

figure
pdemesh(model)

% Find the IDs of the elements within a box enclosing the center of the plate.
elemIDs = findElements(mesh,"box",[25,75],[80,120]);

% Evaluate the shape quality of these elements.
% Display the result as a column vector.
Q = meshQuality(mesh,elemIDs);
Q.'

% Find the elements with the quality values less than 0.4.
elemIDs04 = elemIDs(Q < 0.4)

% Highlight these elements in green on the mesh plot. Zoom in to see the details.
figure
pdemesh(mesh,"ElementLabels","on")
hold on
pdemesh(mesh.Nodes,mesh.Elements(:,elemIDs04),"EdgeColor","green")
zoom(10)

%%% Element Quality Determined by Aspect Ratio
% Determine the shape quality of mesh elements by using the ratios of minimal to maximal dimensions.
% Create a PDE model and include the L-shaped geometry.
model = createpde(1);
geometryFromEdges(model,@lshapeg);

% Generate the default mesh for the geometry.
mesh = generateMesh(model);

% View the mesh.
figure
pdeplot(model)

% Evaluate the shape quality of mesh elements by using the minimal to maximal dimensions ratio.
% Display the first five values.
Q = meshQuality(mesh,"aspect-ratio");
Q(1:5)

% Evaluate the shape quality of mesh elements by using the default setting.
% Display the first five values.
Q = meshQuality(mesh);
Q(1:5)


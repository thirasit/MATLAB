%% Thermal Deflection of Bimetallic Beam
% This example shows how to solve a coupled thermo-elasticity problem.
% Thermal expansion or contraction in mechanical components and structures occurs due to temperature changes in the operating environment.
% Thermal stress is a secondary manifestation: the structure experiences stresses when structural constraints prevent free thermal expansion or contraction of the component.
% Deflection of a bimetallic beam is a common physics experiment.
% A typical bimetallic beam consists of two materials bonded together.
% The coefficients of thermal expansion (CTE) of these materials are significantly different.

figure
imshow("ThermalDeflectionOfABimetallicStripExample_01.png")
axis off;

% This example finds the deflection of a bimetallic beam using a structural finite-element model.
% The example compares this deflection to the analytic solution based on beam theory approximation.
% Create a static structural model.
structuralmodel = createpde("structural","static-solid");

% Create a beam geometry with these dimensions.
L = 0.1; % m
W = 5e-3; % m
H = 1e-3; % m
gm = multicuboid(L,W,[H,H],"Zoffset",[0,H]);

% Include the geometry in the structural model.
structuralmodel.Geometry = gm;

% Plot the geometry.
figure
pdegplot(structuralmodel)

% Identify the cell labels of the cells for which you want to specify material properties.
% First, display the cell label for the bottom cell.
% To see the cell label clearly, zoom into the left end of the beam and rotate the geometry.
figure
pdegplot(structuralmodel,"CellLabels","on")
axis([-L/2 -L/3 -W/2 W/2 0 2*H])
view([0 0])
zticks([])

% Now, display the cell label for the top cell.
% To see the cell label clearly, zoom into the right end of the beam and rotate the geometry.
figure
pdegplot(structuralmodel,"CellLabels","on")
axis([L/3 L/2 -W/2 W/2 0 2*H])
view([0 0])
zticks([])

% Specify Young's modulus, Poisson's ratio, and the linear coefficient of thermal expansion to model linear elastic material behavior.
% To maintain unit consistency, specify all physical properties in SI units.

% Assign the material properties of copper to the bottom cell.
Ec = 137e9; % N/m^2
nuc = 0.28;
CTEc = 20.00e-6; % m/m-C
structuralProperties(structuralmodel,"Cell",1, ...
                                     "YoungsModulus",Ec, ...
                                     "PoissonsRatio",nuc, ...
                                     "CTE",CTEc);

% Assign the material properties of invar to the top cell.
Ei = 130e9; % N/m^2
nui = 0.354;
CTEi = 1.2e-6; % m/m-C
structuralProperties(structuralmodel,"Cell",2, ...
                                     "YoungsModulus",Ei, ...
                                     "PoissonsRatio",nui, ...
                                     "CTE",CTEi);

% For this example, assume that the left end of the beam is fixed.
% To impose this boundary condition, display the face labels on the left end of the beam.
figure
pdegplot(structuralmodel,"FaceLabels","on","FaceAlpha",0.25)
axis([-L/2 -L/3 -W/2 W/2 0 2*H])
view([60 10])
xticks([])
yticks([])
zticks([])

% Apply a fixed boundary condition on faces 5 and 10.
structuralBC(structuralmodel,"Face",[5,10],"Constraint","fixed");

% Apply the temperature change as a thermal load. Use a reference temperature of 25 degrees Celsius and an operating temperature of 125 degrees Celsius.
% Thus, the temperature change for this model is 100 degrees Celsius.
structuralBodyLoad(structuralmodel,"Temperature",125);
structuralmodel.ReferenceTemperature = 25;

% Generate a mesh and solve the model.
generateMesh(structuralmodel,"Hmax",H/2);
R = solve(structuralmodel);

% Plot the deflected shape of the bimetallic beam with the magnitude of displacement as the colormap data.
figure
pdeplot3D(structuralmodel,"ColorMapData",R.Displacement.Magnitude, ...
                          "Deformation",R.Displacement, ...
                          "DeformationScaleFactor",2)
title("Deflection of Invar-Copper Beam")

% You also can plot the deflected shape of the bimetallic beam with the magnitude of displacement as the colormap data by using the Visualize PDE Results Live Editor task.
% First, create a new live script by clicking the New Live Script button in the File section on the Home tab.

figure
imshow("ThermalDeflectionOfABimetallicStripExample_07.png")
axis off;

% On the Live Editor tab, select Task > Visualize PDE Results.
% This action inserts the task into your script.

figure
imshow("ThermalDeflectionOfABimetallicStripExample_08.png")
axis off;

% To plot the magnitude of displacement, follow these steps.
% 1. In the Select results section of the task, select R from the drop-down list.
% 2. In the Specify data parameters section of the task, set Type to Displacement and Component to Magnitude.

figure
imshow("ThermalDeflectionOfABimetallicStripExample_10.png")
axis off;

figure
imshow("ThermalDeflectionOfABimetallicStripExample_09.png")
axis off;

figure
imshow("Opera Snapshot_2023-06-14_120558_www.mathworks.com.png")
axis off;

K1 = 14 + (Ec/Ei)+ (Ei/Ec);
deflectionAnalytical = 3*(CTEc - CTEi)*100*2*H*L^2/(H^2*K1);

% Compare the analytical results and the results obtained in this example.
% The results are comparable because of the large aspect ratio.
PDEToobox_Deflection = max(R.Displacement.uz);
percentError = 100*(PDEToobox_Deflection - ...
                    deflectionAnalytical)/PDEToobox_Deflection;

bimetallicResults = table(PDEToobox_Deflection, ...
                          deflectionAnalytical,percentError);
bimetallicResults.Properties.VariableNames = {'PDEToolbox', ...
                                              'Analytical', ...
                                              'PercentageError'};
disp(bimetallicResults)


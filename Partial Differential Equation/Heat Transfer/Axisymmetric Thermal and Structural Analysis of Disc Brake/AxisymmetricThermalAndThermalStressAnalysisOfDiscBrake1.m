%% Axisymmetric Thermal and Structural Analysis of Disc Brake
% This example shows a quasistatic axisymmetric thermal stress analysis workflow by reproducing the results of the simplified disc brake model discussed in [1].
% Disc brakes absorb mechanical energy through friction and transform it into thermal energy, which then dissipates.
% The example uses a simplified model of a disc brake in a single braking process from a constant initial angular speed to a standstill.
% The workflow has two steps:

% 1. Transient thermal analysis to compute the temperature distribution in the disc using the heat flux from brake pads
% 2. Quasistatic structural analysis to compute thermal stresses at several solution times using previously obtained temperature distribution to specify thermal loads

% The resulting plots show the temperature distribution, radial stress, hoop stress, and von Mises stress for the corresponding solution times.

%%% Disc Brake Properties and Geometry
% Based on the assumptions used in [1], the example reduces the analysis domain to a rectangular region corresponding to the axisymmetric section of the annular disc.
% Because of the geometric and load symmetry of the disc, the example models only half the thickness of the disc and the effect of one pad.
% In the following figure, the left edge corresponds to the inner radius of the disc r_d.
% The right edge corresponds to the outer radius of the disc R_d and also coincides with the outer radius of the pad R_p.
% The disc experiences pressure from the pad, which generates the heat flux.
% Instead of modeling the pad explicitly, include its effect in the thermal analysis by specifying this heat flux as a boundary condition from the inner radius of the pad r_p to the outer radius of the pad R_p.

figure
imshow("AxisymmetricThermalAndThermalStressAnalysisOfDiscBrakeExample_01.png")
axis off;

%%% Thermal Analysis: Compute Temperature Distribution
% Create a transient axisymmetric thermal model.
modelT = createpde("thermal","transient-axisymmetric");

% Create a geometry with two adjacent rectangles.
% The top edge of the longer rectangle (on the right) represents the disc-pad contact region.
R1 = [3,4, [  66,  76.5,  76.5,   66, -5.5, -5.5, 0, 0]/1000]';
R2 = [3,4, [76.5, 113.5, 113.5, 76.5, -5.5, -5.5, 0, 0]/1000]';

gdm = [R1 R2];
ns = char('R1','R2');
g = decsg(gdm,'R1 + R2',ns');

% Assign the geometry to the thermal model.
geometryFromEdges(modelT,g);

% Plot the geometry with the edge and face labels.
figure
pdegplot(modelT,"EdgeLabels","on","FaceLabels","on")

% Generate a mesh. To match the mesh used in [1], use the linear geometric order instead of the default quadratic order.
generateMesh(modelT,"Hmax",0.5E-04,"GeometricOrder","linear");

% Specify the thermal material properties of the disc.
alphad = 1.44E-5; % Diffusivity of disc
Kd = 51;
rhod = 7100;
cpd = Kd/rhod/alphad;
thermalProperties(modelT,"ThermalConductivity",Kd, ...
                         "MassDensity",rhod, ...
                         "SpecificHeat",cpd);

% Specify the heat flux boundary condition to account for the pad region.
% For the definition of the qFcn function, see Heat Flux Function.
thermalBC(modelT,"Edge",6,"HeatFlux",@qFcn);

% Set the initial temperature.
thermalIC(modelT,20);

% Solve the model for the times used in [1].
tlist = [0 0.1 0.2 1.0 2.0 3.0 3.96];
Rt = solve(modelT,tlist);

% Plot the temperature variation with time at three key radial locations.
% The resulting plot is comparable to the plot obtained in [1].
iTRd = interpolateTemperature(Rt,[0.1135;0],1:numel(Rt.SolutionTimes));
iTrp = interpolateTemperature(Rt,[0.0765;0],1:numel(Rt.SolutionTimes));
iTrd = interpolateTemperature(Rt,[0.066;0],1:numel(Rt.SolutionTimes));

figure
plot(tlist,iTRd)
hold on
plot(tlist,iTrp)
plot(tlist,iTrd)
title("Temperature Variation with Time at Key Radial Locations")
legend("R_d","r_p","r_d")
xlabel("t, s")
ylabel("T,^{\circ}C")

%%% Structural Analysis: Compute Thermal Stress
% Create an axisymmetric static structural analysis model.
model = createpde("structural","static-axisymmetric");

% Assign the geometry and mesh used for the thermal model.
model.Geometry = modelT.Geometry;
model.Mesh = modelT.Mesh;

% Specify the structural properties of the disc.
structuralProperties(model,"YoungsModulus",99.97E9, ...
                           "PoissonsRatio",0.29, ...
                           "CTE",1.08E-5);

% Constrain the model to prevent rigid motion.
structuralBC(model,"Edge",[3,4],"ZDisplacement",0);

% Specify the reference temperature that corresponds to the state of zero thermal stress of the model.
model.ReferenceTemperature = 20;

% Specify the thermal load by using the transient thermal results Rt.
% The solution times are the same as in the thermal model analysis.
% For each solution time, solve the corresponding static structural analysis problem and plot the temperature distribution, radial stress, hoop stress, and von Mises stress.
% For the definition of the plotResults function, see Plot Results Function.
% The results are comparable to figure 5 from [1].
for n = 2:numel(Rt.SolutionTimes)
structuralBodyLoad(model,"Temperature",Rt,"TimeStep",n);
R = solve(model);
plotResults(model,R,modelT,Rt,n);
end

%%% References
% [1] Adamowicz, Adam. "Axisymmetric FE Model to Analysis of Thermal Stresses in a Brake Disc." Journal of Theoretical and Applied Mechanics 53, issue 2 (April 2015): 357–370. https://doi.org/10.15632/jtam-pl.53.2.357.

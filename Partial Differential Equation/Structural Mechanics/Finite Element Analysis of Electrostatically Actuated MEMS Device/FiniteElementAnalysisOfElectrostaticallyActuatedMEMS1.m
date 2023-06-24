%% Finite Element Analysis of Electrostatically Actuated MEMS Device
% This example shows a simple approach to the coupled electromechanical finite element analysis of an electrostatically actuated micro-electromechanical (MEMS) device.
% For simplicity, this example uses the relaxation-based algorithm rather than the Newton method to couple the electrostatic and mechanical domains.

%%% MEMS Devices
% MEMS devices typically consist of movable thin beams or electrodes with a high aspect ratio that are suspended over a fixed electrode.

figure
imshow("FiniteElementAnalysisOfElectrostaticallyActuatedMEMSExample_01.png")
axis off;

% Actuation, switching, and other signal and information processing functions can use the electrode deformation caused by the application of voltage between the movable and fixed electrodes.
% FEM provides a convenient tool for characterizing the inner workings of MEMS devices, and can predict temperatures, stresses, dynamic response characteristics, and possible failure mechanisms.
% One of the most common MEMS switches is the series of cantilever beams suspended over a ground electrode.

figure
imshow("FiniteElementAnalysisOfElectrostaticallyActuatedMEMSExample_02.png")
axis off;

% This example uses the following geometry to model a MEMS switch.
% The top electrode is 150 μm in length and 2 μm in thickness.
% Young’s modulus E is 170 GPa, and Poisson’s ratio υ is 0.34.
% The bottom electrode is 50 μm in length and 2 μm in thickness, and is located 100 μm from the leftmost end of the top electrode.
% The gap between the top and bottom electrodes is 2 μm.

figure
imshow("FiniteElementAnalysisOfElectrostaticallyActuatedMEMSExample_03.png")
axis off;

% A voltage applied between the top electrode and the ground plane induces electrostatic charges on the surface of the conductors, which in turn leads to electrostatic forces acting normal to the surface of the conductors.
% Because the ground plane is fixed, the electrostatic forces deform only the top electrode.
% When the beam deforms, the charge redistributes on the surface of the conductors.
% The resultant electrostatic forces and the deformation of the beam also change.
% This process continues until the system reaches a state of equilibrium.

%%% Approach for Coupled Electromechanical Analysis
% For simplicity, this example uses the relaxation-based algorithm rather than the Newton method to couple the electrostatic and mechanical domains. The example follows these steps:
% 1. Solve the electrostatic FEA problem in the nondeformed geometry with the constant potential V0 on the movable electrode.
% 2. Compute the load and boundary conditions for the mechanical solution by using the calculated values of the charge density along the movable electrode. The electrostatic pressure on the movable electrode is given by
%P=1/(2ϵ)∣D∣^2,
% where ∣D∣ is the magnitude of the electric flux density and ϵ is the electric permittivity next to the movable electrode.
% 3. Compute the deformation of the movable electrode by solving the mechanical FEA problem.
% 4. Update the charge density along the movable electrode by using the calculated displacement of the movable electrode,

figure
imshow("Opera Snapshot_2023-06-23_113231_www.mathworks.com.png")
axis off;

% where ∣D_def(x)∣ is the magnitude of the electric flux density in the deformed electrode, ∣D_0(x)∣ is the magnitude of the electric flux density in the undeformed electrode, G is the distance between the movable and fixed electrodes in the absence of actuation, and v(x) is the displacement of the movable electrode at position x along its axis.
% 5. Repeat steps 2–4 until the electrode deformation values in the last two iterations converge.

%%% Electrostatic Analysis
% In the electrostatic analysis part of this example, you compute the electric potential around the electrodes.

% First, create the cantilever switch geometry by using the constructive solid geometry (CSG) modeling approach.
% The geometry for electrostatic analysis consists of three rectangles represented by a matrix.
% Each column of the matrix describes a basic shape.
rect_domain = [3 4 1.75e-4 1.75e-4 -1.75e-4 -1.75e-4 ...
                  -1.7e-5 1.3e-5 1.3e-5 -1.7e-5]';
rect_movable = [3 4 7.5e-5 7.5e-5 -7.5e-5 -7.5e-5 ...
                    2.0e-6 4.0e-6 4.0e-6 2.0e-6]';
rect_fixed = [3 4 7.5e-5 7.5e-5 2.5e-5 2.5e-5 -2.0e-6 0 0 -2.0e-6]';
gd = [rect_domain,rect_movable,rect_fixed];

% Create a name for each basic shape. Specify the names as a matrix whose columns contain the names of the corresponding columns in the basic shape matrix.
ns = char('rect_domain','rect_movable','rect_fixed');
ns = ns';

% Create a formula describing the unions and intersections of the basic shapes.
sf = 'rect_domain-(rect_movable+rect_fixed)';

% Create the geometry by using the decsg function.
dl = decsg(gd,sf,ns);

% Create a PDE model and include the geometry in the model.
model = createpde;
geometryFromEdges(model,dl);

% Plot the geometry.
pdegplot(model,"EdgeLabels","on","FaceLabels","on")
xlabel("x-coordinate, meters")
ylabel("y-coordinate, meters")
axis([-2e-4,2e-4,-4e-5,4e-5])
axis square

% The edge numbers in this geometry are:
% - Movable electrode: E3, E7, E11, E12
% - Fixed electrode: E4, E8, E9, E10
% - Domain boundary: E1, E2, E5, E6

% Set constant potential values of 20 V to the movable electrode and 0 V to the fixed electrode and domain boundary.
V0 = 0;
V1 = 20;
applyBoundaryCondition(model,"dirichlet", ...
                             "Edge",[4,8,9,10],"u",V0);
applyBoundaryCondition(model,"dirichlet", ...
                             "Edge",[1,2,5,6],"u",V0);
applyBoundaryCondition(model,"dirichlet", ...
                             "Edge",[3,7,11,12],"u",V1);

% The PDE governing this problem is the Poisson equation,
%−∇⋅(ϵ∇V)=ρ,
% where ϵ is the coefficient of permittivity and ρ is the charge density.
% The coefficient of permittivity does not affect the result in this example as long as the coefficient is constant.
% Assuming that there is no charge in the domain, you can simplify the Poisson equation to the Laplace equation,
%ΔV=0.
% Specify the coefficients.
specifyCoefficients(model,"m",0,"d",0,"c",1,"a",0,"f",0);

% Generate a relatively fine mesh.
hmax = 5e-6;
generateMesh(model,"Hmax",hmax);
pdeplot(model)
xlabel("x-coordinate, meters")
ylabel("y-coordinate, meters")
axis([-2e-4, 2e-4,-4e-5, 4e-5])
axis square

% Solve the model.
results = solvepde(model);

% Plot the electric potential in the exterior domain.
u = results.NodalSolution;
figure
pdeplot(model,"XYData",results.NodalSolution, ...
              "ColorMap","jet");

title("Electric Potential");
xlabel("x-coordinate, meters")
ylabel("y-coordinate, meters")
axis([-2e-4,2e-4,-4e-5,4e-5])
axis square

% You also can plot the electric potential in the exterior domain by using the Visualize PDE Results Live Editor task.
% First, create a new live script by clicking the New Live Script button in the File section on the Home tab.

figure
imshow("FiniteElementAnalysisOfElectrostaticallyActuatedMEMSExample_07.png")
axis off;

% On the Live Editor tab, select Task > Visualize PDE Results.
% This action inserts the task into your script.

figure
imshow("FiniteElementAnalysisOfElectrostaticallyActuatedMEMSExample_08.png")
axis off;

% To plot the electric potential, follow these steps.
% 1. In the Select results section of the task, select results from the drop-down list.
% 2. In the Specify data parameters section of the task, set Type to Nodal solution.

figure
imshow("FiniteElementAnalysisOfElectrostaticallyActuatedMEMSExample_14.png")
axis off;

figure
imshow("FiniteElementAnalysisOfElectrostaticallyActuatedMEMSExample_09.png")
axis off;

%%% Mechanical Analysis
% In the mechanical analysis part of this example, you compute the deformation of the movable electrode.

% Create a structural model.
structuralmodel = createpde("structural","static-planestress");

% Create the movable electrode geometry and include it in the model.
% Plot the geometry.
dl = decsg(rect_movable);
geometryFromEdges(structuralmodel,dl);
pdegplot(structuralmodel,"EdgeLabels","on")
xlabel("x-coordinate, meters")
ylabel("y-coordinate, meters")
axis([-1e-4,1e-4,-1e-5,1e-5])
axis square

% Specify the structural properties: Young's modulus E is 170 GPa and Poisson's ratio ν is 0.34.
structuralProperties(structuralmodel,"YoungsModulus",170e9, ...
                                     "PoissonsRatio",0.34);

% Specify the pressure as a boundary load on the edges.
% The pressure tends to draw the conductor into the field regardless of the sign of the surface charge.
% For the definition of the CalculateElectrostaticPressure function, see Electrostatic Pressure Function.
pressureFcn = @(location,state) - ...
              CalculateElectrostaticPressure(results,[],location);
structuralBoundaryLoad(structuralmodel,"Edge",[1,2,4], ...
                                       "Pressure",pressureFcn, ...
                                       "Vectorized","on");

% Specify that the movable electrode is fixed at edge 3.
structuralBC(structuralmodel,"Edge",3,"Constraint","fixed");

% Generate a mesh.
hmax = 1e-6;
generateMesh(structuralmodel,"Hmax",hmax);
pdeplot(structuralmodel);
xlabel("x-coordinate, meters")
ylabel("y-coordinate, meters")
axis([-1e-4, 1e-4,-1e-5, 1e-5])
axis square

% Solve the equations.
R = solve(structuralmodel);

% Plot the displacement for the movable electrode.
pdeplot(structuralmodel,"XYData",R.VonMisesStress, ...
                        "Deformation",R.Displacement, ...
                        "DeformationScaleFactor",10, ...
                        "ColorMap","jet");

title("von Mises Stress in Deflected Electrode")
xlabel("x-coordinate, meters")
ylabel("y-coordinate, meters")
axis([-1e-4,1e-4,-1e-5,1e-5])
axis square

% Find the maximal displacement.
maxdisp = max(abs(R.Displacement.uy));
fprintf('Finite element maximal tip deflection is: %12.4e\n', ...
         maxdisp);

% Repeatedly update the charge density along the movable electrode and solve the model until the electrode deformation values converge.
olddisp = 0;
while abs((maxdisp-olddisp)/maxdisp) > 1e-10
% Impose boundary conditions
  pressureFcn = @(location,state) - ...
                CalculateElectrostaticPressure(results,R,location);
  bl = structuralBoundaryLoad(structuralmodel, ...
                              "Edge",[1,2,4], ...
                              "Pressure",pressureFcn, ...
                              "Vectorized","on");
% Solve the equations
    R = solve(structuralmodel);
    olddisp = maxdisp;
    maxdisp = max(abs(R.Displacement.uy));
    delete(bl)
end

% Plot the displacement.
pdeplot(structuralmodel,"XYData",R.VonMisesStress, ...
                        "Deformation",R.Displacement, ...
                        "DeformationScaleFactor",10, ...
                        "ColorMap","jet");

title("von Mises Stress in Deflected Electrode")
xlabel("x-coordinate, meters")
ylabel("y-coordinate, meters")
axis([-1e-4,1e-4,-1e-5,1e-5])
axis square

% Find the maximal displacement.
maxdisp = max(abs(R.Displacement.uy));
fprintf('Finite element maximal tip deflection is: %12.4e\n', maxdisp);

%%% References
% [1] Sumant, P. S., N. R. Aluru, and A. C. Cangellaris. "A Methodology for Fast Finite Element Modeling of Electrostatically Actuated MEMS." International Journal for Numerical Methods in Engineering. Vol 77, Number 13, 2009, 1789-1808.

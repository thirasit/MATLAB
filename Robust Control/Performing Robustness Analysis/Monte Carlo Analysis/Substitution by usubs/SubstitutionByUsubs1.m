%% Substitution by usubs
% If an uncertain matrix or model object (umat, uss, ufrd) has many uncertain parameters, it is often useful to freeze some, but not all, of the uncertain parameters to specific values for analysis.
% The usubs command accomplishes this, and also allows more complicated substitutions for an element.

% usubs accepts a list of element names and respective values to substitute for them.
% For example, can create three uncertain real parameters and use them to create a 2-by-2 uncertain matrix, A.
delta = ureal('delta',2); 
eta = ureal('eta',6); 
rho = ureal('rho',-1); 
A = [3+delta+eta delta/eta;7+rho rho+delta*eta] 

% Use usubs to substitute the uncertain element named delta in A with the value 2.3, leaving all other uncertain elements intact.
% That the result, B, is an uncertain matrix with dependence only on eta and rho.
B = usubs(A,'delta',2.3)

% To set multiple elements, list individually, or group the values in a data structure.
% For instance, the following code creates identical uncertain matrices B1 and B2.
% In each case, you replace delta by 2.3, and eta by the uncertain real parameter A.Uncertainty.rho.
B1 = usubs(A,'delta',2.3,'eta',A.Uncertainty.rho)

S.delta = 2.3;
S.eta = A.Uncertainty.rho;
B2 = usubs(A,S)

% usubs ignores substitutions that do not match uncertain parameters in the model or matrix.
% For example, the following returns an uncertain matrix that is the same as A.
B3 = usubs(A,'fred',5); 

%%% Specifying the Substitution with Structures
% An alternative syntax for usubs is to specify the substituted values in a structure, whose field names are the names of the elements being substituted with values.
% For example, create a structure NV with fields delta and eta.
% Set the values of these fields to be the desired values for substitution.
% Then perform the substitution with usubs.
NV.delta = 2.3; 
NV.eta = A.Uncertainty.rho; 
B4 = usubs(A,NV)

% Here, B4 is the same as B1 and B2 above.
% Again, any superfluous fields are ignored.
% Therefore, adding an additional field gamma to NV does not alter the result of substitution.
NV.gamma = 0; 
B5 = usubs(A,NV)

% Analysis commands such as wcgain, robstab, and usample all return substitutable values in this structure format.

%%% Nominal and Random Values
% To fix specified elements to their nominal values, use the replacement value 'Nominal'.
% To set an element to a random value, use 'Random'.
% For example, create a numeric matrix by fixing uncertain parameters in A: Set eta to its nominal value, set delta to a random value, and set rho to 6.5.
B6 = usubs(A,'eta','Nominal','delta','Random','rho',6.5) 

% In the structure format, to set an uncertain element to its nominal value, set the corresponding value in the structure.
S = struct('eta',A.Uncertainty.eta.NominalValue,'rho',6.5);
B7 = usubs(A,S)

% Use usample to set the remaining element to a random value.
B8 = usample(B7,'delta',1)

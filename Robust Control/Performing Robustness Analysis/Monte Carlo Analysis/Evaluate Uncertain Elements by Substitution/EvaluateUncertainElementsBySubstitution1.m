%% Evaluate Uncertain Elements by Substitution
% You can make substitutions for uncertain elements in uncertain matrices and models using usubs.
% Doing so is useful for evaluating uncertain objects at particular values of the uncertain parameters, or for sampling uncertain objects at multiple parameter values.

% For example, create an uncertain matrix with three uncertain parameters.
a = ureal('a',3);
b = ureal('b',10,'Percentage',20);
c = ureal('c',3,'Percentage',40);
M = [-a, 1/b; b, a+1/b; 1, c]

% Substitute all instances of the uncertain real parameter a with the value 4.
% This operation results in a umat containing only two uncertain real parameters, b and c.
M2 = usubs(M,'a',4)

% You can replace all instances of one uncertain real parameter with another.
% For example, replace all instances of b in M with the uncertain parameter a.
% The resulting umat contains only the parameters a and c, and has two additional occurrences of a, compared to M.
M3 = usubs(M,'b',M.Uncertainty.a)

% Next, evaluate M at the nominal value of a and a random value of b.
M4 = usubs(M,'a','NominalValue','b','Random')

% Use the usample command to generate multiple random instances of umat, uss, or ufrd uncertain objects.

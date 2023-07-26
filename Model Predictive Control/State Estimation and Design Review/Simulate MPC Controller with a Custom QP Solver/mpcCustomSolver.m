%% Review the saved mpcCustomSolver.m file.
function [x, status] = mpcCustomSolver(H, f, A, b, x0)
% mpcCustomSolver allows user to specify a custom quadratic programming
% (QP) solver to solve the QP problem formulated by MPC controller.  When
% the "mpcobj.Optimizer.CustomSolver" property is set true, instead of
% using the built-in QP solver, MPC controller will now use the customer QP
% solver defined in this function for simulations in MATLAB and Simulink.
%
% The MPC QP problem is defined as follows:
%   Find an optimal solution, x, that minimizes the quadratic objective
%   function, J = 0.5*x'*H*x + f'*x, subject to linear inequality
%   constraints, A*x >= b.
%
% Inputs (provided by MPC controller at run-time):
%       H: a n-by-n Hessian matrix, which is symmetric and positive definite.
%       f: a n-by-1 column vector.
%       A: a m-by-n matrix of inequality constraint coefficients.
%       b: a m-by-1 vector of the right-hand side of inequality constraints.
%      x0: a n-by-1 vector of the initial guess of the optimal solution.
%
% Outputs (fed back to MPC controller at run-time):
%       x: must be a n-by-1 vector of optimal solution. 
%  status: must be an finite integer of:
%           positive value: number of iterations used in computation
%                        0: maximum number of iterations reached
%                       -1: QP is infeasible
%                       -2: Failed to find a solution due to other reasons
% Note that even if solver failed to find an optimal solution, "x" must be
% returned as a n-by-1 vector (i.e. set it to the initial guess x0)
%
% DO NOT CHANGE LINES ABOVE

% The following code is an example of how to implement the custom QP solver
% in this function.  It requires Optimization Toolbox to run.

% Define QUADPROG options and turn off display of optimization results in
% Command window.
options = optimoptions('quadprog');
options.Display = 'none';  
% By definition, constraints required by "quadprog" solver is defined as
% A*x <= b.  However, in our MPC QP problem, the constraints are defined as
% A*x >= b.  Therefore, we need to implement some conversion here:
A_custom = -A;
b_custom = -b;
% Compute the QP's optimal solution.  Note that the default algorithm used
% by "quadprog" ('interior-point-convex') ignores x0.  "x0" is used here as
% an input argument for illustration only.
H = (H+H')/2; % ensure Hessian is symmetric
[x, ~, Flag, Output] = quadprog(H, f, A_custom, b_custom, [], [], [], [], x0, options);
% Converts the "flag" output to "status" required by the MPC controller.
switch Flag
    case 1
        status = Output.iterations;
    case 0
        status = 0;
    case -2
        status = -1;
    otherwise
        status = -2;
end
% Always return a non-empty x of the correct size.  When the solver fails,
% one convenient solution is to set x to the initial guess.
if status <= 0
    x = x0;
end

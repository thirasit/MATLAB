function [x, status] = mpcCustomSolverCodeGen(H, f, A, b, x0)
%#codegen
% mpcCustomSolverCodeGen allows the user to specify a custom (QP) solver
% written in MATLAB to be used by MPC controller in code generation.
%
% Workflow:
%   (1) Copy this template file to your work folder and rename it to
%       "mpcCustomSolverCodeGen.m".  The work folder must be on the path. 
%   (2) Modify the "mpcCustomSolverCodeGen.m" to use your solver.
%       Note that your solver must use only fixed-size data.
%   (3) Set "mpcobj.Optimizer.CustomSolverCodeGen = true" to tell the MPC
%       controller to use the solver in code generation.
% To generate code:
%   In MATLAB, use "codegen" command with "mpcmoveCodeGeneration" (require MATLAB Coder) 
%   In Simulink, generate code with MPC and Adaptive MPC blocks
%
% To use this solver for simulation in MATLAB and Simulink, you need to:
%   (1) Copy "mpcCustomSolver.txt" template file to your work folder and 
%       rename it to "mpcCustomSolver.m".  The work folder must be on the path. 
%   (2) Modify the "mpcCustomSolver.m" to use your solver.
%   (3) Set "mpcobj.Optimizer.CustomSolver = true" to tell the MPC
%       controller to use the solver in simulation.
%
% The MPC QP problem is defined as follows: 
%
%       min J(x) = 0.5*x'*H*x + f'*x, s.t. A*x >= b.
%
% Inputs (provided by MPC controller at run-time):
%       H: a n-by-n Hessian matrix, which is symmetric and positive definite.
%       f: a n-by-1 column vector.
%       A: a m-by-n matrix of inequality constraint coefficients.
%       b: a m-by-1 vector of the right-hand side of inequality constraints.
%      x0: a n-by-1 vector of the initial guess of the optimal solution.
%
% Outputs (sent back to MPC controller at run-time):
%       x: must be a n-by-1 vector of optimal solution. 
%  status: must be an integer of:
%           positive value: number of iterations used in computation
%                        0: maximum number of iterations reached
%                       -1: QP is infeasible
%                       -2: Failed to find a solution due to other reasons
% Note that:
%   (1) When solver fails to find an optimal solution (status<=0), "x" 
%       still needs to be returned.
%   (2) To use sub-optimal QP solution in MPC, return the sub-optimal "x" 
%       with "status = 0".  In addition, you need to set
%       "mpcobj.Optimizer.UseSuboptimalSolution = true" in MPC controller. 
%
% DO NOT CHANGE LINES ABOVE

% This template implements a showcase QP solver using "Dantzig" algorithm
% by G. B. Dantzig, A. Orden, and P. Wolfe, "The generalized simplex method
% for minimizing a linear form under linear inequality constraints",
% Pacific J. of Mathematics, 5:183–195, 1955.
%
% User is expected to modify this template and plug in own custom QP solver
% that replaces the "Dantzig" algorithm.  

ZERO = zeros('like',H);
ONE = ones('like',H);
% xmin is a constant term that adds to the initial basis because "dantzig"
% requires positive optimization variables.  A fixed "xmin" does not work
% for all MPC problems.
xmin = -1e3*ones(size(f(:)))*ONE; 

maxiter = 200*ONE;
nvar = length(f);
ncon = length(b);
a = -H*xmin(:); 
H = H\eye(nvar);
rhsc = A*xmin(:) - b(:);
rhsa = a-f(:);
TAB = -[H H*A';A*H A*H*A'];
basisi = [H*rhsa; rhsc + A*H*rhsa];
ibi = -(1:nvar+ncon)'*ONE;
ili = -ibi*ONE;
%% Call EML function "qpdantzg"
[basis,ib,il,iter] = qpdantzg(TAB,basisi,ibi,ili,maxiter); %#ok<ASGLU>
%% status
if iter > maxiter
    status = ZERO;
elseif iter < ZERO
    status = -ONE;    
else
    status = iter;
end
%% optimal variable
x = zeros(nvar,1,'like',H);
for j = 1:nvar
    if il(j) <= ZERO
        x(j) = xmin(j);
    else
        x(j) = basis(il(j))+xmin(j);
    end
end

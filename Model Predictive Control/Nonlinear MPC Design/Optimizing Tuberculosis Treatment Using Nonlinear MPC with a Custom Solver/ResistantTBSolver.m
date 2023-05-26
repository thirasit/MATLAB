function [zopt,cost,exitflag] = ResistantTBSolver(FUN,z0,A,b,Aeq,beq,lb,ub,NONLINCON)
% This is an interface function that calls a XYZ nonlinear programming
% solver to solve an NLP problem defined by an nlmpc controller. The
% input and output definitions of this function are identical to fmincon.
%
% This interface function converts fmincon inputs to the format required
% by the XYZ solver and converts the results back to the fmincon outputs.
%
% Inputs
%       FUN: nonlinear cost. FUN accepts input z (decision variabls) and
%            returns cost f (a scalar value evaluated at z) and its
%            gradient g (a nz-by-1 vector evaluated at z).  
%        z0: initial guess of z
%       A,b: A*z<=b
%   Aeq,beq: Aeq*z==beq
%     lb,ub: lower and upper bounds of z
% NONLINCON: nonlinear constraints. NONLINCON accepts input z and returns
%            the vectors C and Ceq as the first two outputs, representing
%            the nonlinear inequalities and equalities respectively where
%            FUN is minimized subject to C(z) <= 0 and Ceq(z) = 0.
%            NONLINCON also returns Jacobian matrices of C (a nz-by-ncin
%            sparse matrix) and Ceq (a nz-by-nceq sparse matrix).
%
% Outputs
%     zopt:  optimal solution of z
%     cost:  optimal cost at optimal z
% exitflag:
%            1  First order optimality conditions satisfied.
%            0  Too many function evaluations or iterations.
%           -1  Stopped by output/plot function.
%           -2  No feasible point found.
%
% You can use this example as a template to implement an interface file to
% your own NLP solver. The solver must be an M file or a MEX file on the
% MATLAB path.
%
% DO NOT EDIT LINES ABOVE.
%
% Copyright 2018 The MathWorks, Inc.

%% Set dimensional information of linear and nonlinear constraints
num_lin_ineq = size(A,1);
num_lin_eq = size(Aeq,1);
[in,eq] = NONLINCON(z0);
num_non_ineq = length(in);
num_non_eq = length(eq);
total = num_non_ineq + num_non_eq + num_lin_ineq + num_lin_eq;
logicals_nlineq = false(total,1);
logicals_nlineq(1:num_non_ineq) = true;
logicals_nleq = false(total,1);
logicals_nleq(num_non_ineq+(1:num_non_eq)) = true;
logicals_ineq = false(total,1);
logicals_ineq(num_non_ineq+num_non_eq+(1:num_lin_ineq)) = true;
logicals_eq = false(total,1);
logicals_eq(num_non_ineq+num_non_eq+num_lin_ineq+(1:num_lin_eq)) = true;
options = struct('nlineq',logicals_nlineq,'nleq',logicals_nleq,...
                 'ineq',logicals_ineq,'eq',logicals_eq);
%% Set decision variable bounds
options.lb = lb;
options.ub = ub;
%% Set RHS of nonlinear constraints
options.cl = [-inf(num_non_ineq,1);zeros(num_non_eq,1)];
options.cu = [zeros(num_non_ineq,1);zeros(num_non_eq,1)];
%% Set RHS of linear constraints
options.rl = [-inf(num_lin_ineq,1);beq];
options.ru = [b;beq];
%% Set A matrix
options.A = sparse([A; Aeq]);
%% Set XYZ solver optons
options.algorithm = struct('print_level',0,'max_iter',200,...
                           'max_cpu_time',1000,'tol',1.0000e-06,...
                           'hessian_approximation','limited-memory');
%% Set function handles used by XYZ solver
Jstr = sparse(ones(num_non_ineq+num_non_eq,length(z0)));
funcs = struct('objective',@(x) fval(FUN,x),...
              'gradient',@(x) gval(FUN,x),...
              'constraints',@(x) conval(NONLINCON,x),...
              'jacobian',@(x) jacval(NONLINCON,x),...
              'jacobianstructure',@() Jstr...
              );
%% Call XYZ and return cost and status
[zopt,output] = XYZsolver(z0,funcs,options);
cost = FUN(zopt);
exitflag = convertStatustoExitflag(output.status);

%% Utility functions
function f = fval(fun,z)
% Return nonlinear cost
[f,~] = fun(z);

function g = gval(fun,z)
% Return cost gradient
[~,g] = fun(z);

function c = conval(nonlcon,z)
% Return nonlinear constraints
[in,eq] = nonlcon(z);
c = [in;eq];

function J = jacval(nonlcon,z)
% Return constraints Jacobian as nc-by-nz in sparse matrix
% Jin is nz-by-ncin sparse, Jeq is nz-by-nceq sparse
[~,~,Jin,Jeq] = nonlcon(z); 
J = [Jin Jeq]';

function exitflag = convertStatustoExitflag(status)
switch(status)
    case 0
        %info.Status = 'Success';
        exitflag = 1;
    case 1
        %info.Status = 'Solved to Acceptable Level';
        exitflag = 1;
    case 2
        %info.Status = 'Infeasible';
        exitflag = -1;
    case 3
        %info.Status = 'Search Direction Becomes Too Small';
        exitflag = -2;
    case 4
        %info.Status = 'Diverging Iterates';
        exitflag = -2;
    case 6
        %info.Status = 'Feasible Point Found';
        exitflag = 1;
    case -1
        %info.Status = 'Exceeded Iterations';
        exitflag = 0;
    case -4 
        %info.Status = 'Max Time Exceeded';
        exitflag = 0;
    otherwise        
        %info.Status = 'IPOPT Error';
        exitflag = -2;
end


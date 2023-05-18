function xk1 = FlyingRobotStateFcnDiscreteTime(xk, uk, Ts)
% Nonlinear discrete-time state transition for the flying robot model.
%
% Discretization uses the trapezoidal formula, assuming the input, uk, is
% constant during time interval Ts.
%
% The trapezoidal formula is implicit; that is, you cannot solve for xk1
% algebraically. You need to solve a set of nonlinear equations.  
% This function uses FSOLVE for this purpose.

% Copyright 2018-2021 The MathWorks, Inc.

% FlyingRobotStateFcn is the continuous-time state function for this
% example. Obtain the state derivatives at the current point.
xk = xk(:);     % Make sure inputs are column vectors
uk = uk(:);
ffun = @(xk,uk) FlyingRobotStateFcn(xk,uk);
fk = ffun(xk,uk);

% Extrapolation using xk1 = xk + Ts*fk is risky, since it might put xk1 in
% an infeasible region, which could prevent convergence. A safer
% alternative is xk1 = xk, but this method produces a poor estimate.
xk1 = xk + Ts*fk;

% Solve for xk1 satisfying the Trapezoidal rule.
FUN = @(xk1) TrapezoidalRule(xk,xk1,uk,Ts,fk,ffun);
Options = optimoptions('fsolve','Display','none');
xk1 = fsolve(FUN,xk1,Options);

% Trapezoidal rule function
function f = TrapezoidalRule(xk,xk1,uk,Ts,fk,ffun)
% Time derivatives at point xk1.
fk1 = ffun(xk1,uk);
% The following must be zero to satisfy the Trapezoidal Rule
f = xk1 - (xk + (Ts/2)*(fk1 + fk));



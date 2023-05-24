function x1 = fedbatch_StateFcnDT(x, u_in, Ts)

% Integrates the fed-batch model for one control interval using forward
% Euler formula

Nstep = 100;
x1 = x;
dt = Ts/Nstep;
for i = 1:Nstep
    x1 = x1 + dt*fedbatch_StateFcn(x1, u_in);
end


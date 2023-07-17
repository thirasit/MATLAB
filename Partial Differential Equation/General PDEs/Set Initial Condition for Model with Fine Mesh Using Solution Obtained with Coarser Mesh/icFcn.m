%% Initial Conditions Function
function u0 = icFcn(region,interpolant)
u0 = interpolant(region.x',region.y');
end
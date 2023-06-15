%%% ODE Helper Function
function f = CMSODEf(t,u,Kode,Fode,loadedVertex)
Fode(loadedVertex) = 10*sin(6000*t);
f = -Kode*u +Fode;
end

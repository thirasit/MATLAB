function ResistantTBPlot(Info,Ts)
% Plot optimal state trajectory and MV moves.
%
% States:
%   x(1) = S, number of susceptible individuals
%   x(2) = T, number treated effectively and immune
%   x(3) = L2, latent with resistant TB, non-infections
%   x(4) = I1, infectious with typical TB
%   x(5) = I2, infectious with resistant TB
%
%   L1, latent with typical TB, non-infections, is N - sum(x).
%
% Manipulated variables (MVs):
%   u(1):  "case finding".  Effort expended to identify those needing
%           treatment.  Relatively inexpensive.
%   u(2):  "case holding"   Effort to maintain effective treatment.
%           relatively costly.
%
% Copyright 2018 The MathWorks, Inc.

Xopt = Info.Xopt;
Xopt = [Xopt(:,1:2) 30000-sum(Xopt,2) Xopt(:,3:5)];
MVopt = Info.MVopt;
p = size(Xopt,1)-1;
nx = size(Xopt,2);
nmv = size(MVopt,2);
% Integrate ODEs using calculated U to check accuracy of prediction model
Xp = zeros(p+1,nx);
Xp(1,:) = Xopt(1,:);
for k = 2:p+1
    ODEFUN = @(t,x) ResistantTBStateFcn(x,MVopt(k-1,:)');
    [~,YOUT] = ode45(ODEFUN,[0 Ts],Xp(k-1,[1 2 4 5 6])');
    Xp(k,[1 2 4 5 6]) = YOUT(end,:);            
    Xp(k,3) = 30000 - sum(YOUT(end,:));
end
% plots
t = Ts*(0:p);
figure(1)
states = {'S','T','L1','L2','I1','I2'};
for i = 1:nx
    subplot(3,2,i)
    plot(t,Xopt(:,i),'-',t,Xp(:,i),'o')
    title(states{i})
end
figure(2)
MVs = {'Finding','Holding'};
for i = 1:nmv
    subplot(nmv,1,i)
    stairs(t(1:end),MVopt(:,i))
    title(MVs{i})
end
fprintf('Optimal cost = %8.1f\n', Info.Cost)
fprintf('Final     L2 = %8.1f\n', Xp(end,4))
fprintf('Final     I2 = %8.1f\n', Xp(end,6))

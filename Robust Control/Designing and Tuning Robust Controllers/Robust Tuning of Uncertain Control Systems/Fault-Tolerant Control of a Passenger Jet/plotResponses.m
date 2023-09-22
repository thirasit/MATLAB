function plotResponses(OutageCases,mu,alpha,beta)
% Plot simulation results for FaultTolerantControlExample demo.

% Copyright 1986-2012 The MathWorks, Inc.
assignin('base','muStep',mu)
assignin('base','alphaStep',alpha)
assignin('base','betaStep',beta)
clf
subplot(311); title('Flight-path bank angle rate (deg/s)'); grid; hold on
subplot(312); title('Angle of attack (deg)'); grid; hold on
subplot(313); title('Sideslip angle (deg)'); grid; hold on
set(findobj(gcf,'type','axes'),'YLim',[-1.5 1.5])
for k = 9:-1:1
   assignin('base','outage',OutageCases(k,:))
   sim('faultTolerantAircraft');
   if k==1, st = 'r-'; else st = 'b--'; end
   subplot(311); plot(y.Time,y.Data(:,1),st);
   subplot(312); plot(y.Time,y.Data(:,2),st);
   subplot(313); plot(y.Time,y.Data(:,3),st);
end
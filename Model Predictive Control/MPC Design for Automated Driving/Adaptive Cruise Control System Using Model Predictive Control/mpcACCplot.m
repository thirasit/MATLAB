function mpcACCplot(logsout,D_default,t_gap,v_set)
%% Get the data from simulation
a_ego = logsout.getElement('a_ego');             % acceleration of ego car
v_ego = logsout.getElement('v_ego');             % velocity of ego car
a_lead = logsout.getElement('a_lead');           % acceleration of lead car
v_lead = logsout.getElement('v_lead');           % velocity of lead car
d_rel = logsout.getElement('d_rel');             % actual distance
d_safe = D_default + t_gap*v_ego.Values.Data;    % desired distance

%% Plot the results
figure('position',[100 100 960 800])

% acceleration
subplot(3,1,1)
plot(a_ego.Values.time,a_ego.Values.Data,'r',...
     a_lead.Values.time,a_lead.Values.Data,'b')
grid on
ylim([-3.2,2.2])
legend('ego','lead','location','SouthEast')
title('Acceleration')
xlabel('time (sec)')
ylabel('$m/s^2$','Interpreter','latex')

% velocity
subplot(3,1,2)
plot(v_ego.Values.time,v_ego.Values.Data,'r',...
     v_lead.Values.time,v_lead.Values.Data,'b',...
     v_lead.Values.time,v_set*ones(length(v_lead.Values.time),1),'k--')
grid on
ylim([15,35])
legend('ego','lead','set','location','SouthEast')
title('Velocity')
xlabel('time (sec)')
ylabel('$m/s$','Interpreter','latex')

% distance
subplot(3,1,3)
plot(d_rel.Values.time,d_rel.Values.Data,'r',...
     d_rel.Values.time,d_safe,'b')
grid on
legend('actual','safe','location','SouthEast')
title('Distance between two cars')
xlabel('time (sec)')
ylabel('$m$','Interpreter','latex')



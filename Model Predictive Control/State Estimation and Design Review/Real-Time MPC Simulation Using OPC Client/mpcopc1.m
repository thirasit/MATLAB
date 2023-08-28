%% Real-Time MPC Simulation Using OPC Client
% This example shows how to implement an online model predictive controller using the OPC client supplied with the Industrial Communication Toolbox™ software.

% The example uses the Matrikon™ OPC Simulation Server to simulate the behavior of an industrial process in Windows®.

%%% Download the Matrikon OPC Simulation Server
% Download and install the OPC Simulation Server.
% Perform a default installation of the Simulation Server, including all prerequisites.

% After downloading and installing the server, install and register the OPC Foundation Core components.
opcregister('-silent') 

%%% Connect to OPC Server
% To connect to the OPC server, first clear any existing OPC connections.
opcreset

% Clear the callback persistent variables.
clear mpcopcPlantStep
clear mpcopcMPCStep

% Connect to the OPC Server.
try
    h = opcda('localhost','Matrikon.OPC.Simulation.1');
    connect(h);
catch ME
    disp('The Matrikon(TM) OPC Simulation Server must be running on the local machine.')
    return
end

%%% Configure Plant OPC I/O
% In practice, the plant would be a physical process, and the OPC tags which define its I/O would already have been created on the OPC server.
% However, in this case, since an OPC simulation server is used, the plant behavior must be simulated.

% To do so, you define tags for the plant manipulated and measured variables and create a callback function (mpcopcPlantStep) to simulate the plant response to changes in the manipulated variables.

% Two OPC groups are required, one to represent the two manipulated variables to be read by the plant simulator and another to write back the two measured plant outputs storing the results of the plant simulation.

% Build an OPC group for two plant inputs and initialize them to zero.
plant_read = addgroup(h,'plant_read');
imv1 = additem(plant_read,'Bucket Brigade.Real8','double');
writeasync(imv1,0);
imv2 = additem(plant_read,'Bucket Brigade.Real4','double');
writeasync(imv2,0);

% Build an OPC group for the plant outputs.
plant_write = addgroup(h,'plant_write');
opv1 = additem(plant_write,'Bucket Brigade.Time', 'double');
opv2 = additem(plant_write,'Bucket Brigade.Money', 'double');

% Suppress the command line display.
plant_read.WriteAsyncFcn = [];
plant_write.WriteAsyncFcn = [];

%%% Create MPC Controller
% Create a plant model with two inputs and two outputs.
plant_model = ss([-.2 -.1; 0 -.05],eye(2,2),eye(2,2),zeros(2,2));
disc_plant_model = c2d(plant_model,1);

% Create an MPC controller with a control horizon 6 steps and a prediction horizon of 20 steps.
mpcobj = mpc(disc_plant_model,1,20,6);

mpcobj.weights.ManipulatedVariablesRate = [1 1];

% Obtain the controller state and calculate a single control move.
state = mpcstate(mpcobj);

mv = mpcmove(mpcobj,state,[1;1]',[1 1]');

%%% Build OPC I/O for MPC Controller
% Build two OPC groups, one to read the two measured plant outputs and the other to write back the two manipulated variables.

% Build an OPC group for the MPC controller inputs (plant outputs and references).
mpc_read = addgroup(h,'mpc_read');
impcpv1 = additem(mpc_read,'Bucket Brigade.Time','double');
writeasync(impcpv1,0);
impcpv2 = additem(mpc_read,'Bucket Brigade.Money','double');
writeasync(impcpv2,0);
impcref1 = additem(mpc_read,'Bucket Brigade.Int2','double');
writeasync(impcref1,1);
impcref2 = additem(mpc_read,'Bucket Brigade.Int4','double');
writeasync(impcref2,1);

% Build an OPC group for MPC controller outputs (plant inputs).
mpc_write = addgroup(h,'mpc_write');
additem(mpc_write,'Bucket Brigade.Real8','double');
additem(mpc_write,'Bucket Brigade.Real4','double');

% Suppress the command line display.
mpc_read.WriteAsyncFcn = [];
mpc_write.WriteAsyncFcn = [];

%%% Build OPC Groups to Trigger Simulator and Controller
% Build two OPC groups based on the same external OPC timer to trigger execution of both plant simulation and MPC execution when the contents of the OPC time tag change.
gtime = addgroup(h,'time');
time_tag = additem(gtime,'Triangle Waves.Real8');
gtime.UpdateRate = 1;
gtime.DataChangeFcn = {@mpcopcPlantStep plant_read plant_write disc_plant_model};

gmpctime = addgroup(h,'mpctime');
additem(gmpctime,'Triangle Waves.Real8');
gmpctime.UpdateRate = 1;
gmpctime.DataChangeFcn = {@mpcopcMPCStep mpc_read mpc_write mpcobj};

%%% Log Data from Plant Measured Outputs
% Log the plant measured outputs from tags 'Bucket Brigade.Time' and 'Bucket Brigade.Money'.
mpc_read.RecordsToAcquire = 40;
start(mpc_read);
while mpc_read.RecordsAcquired < mpc_read.RecordsToAcquire
    pause(3)
    fprintf('Logging data: Record %d / %d\n',mpc_read.RecordsAcquired,mpc_read.RecordsToAcquire)
end

stop(mpc_read);

% Extract and plot the logged data
[itemID,value,quality,timeStamp,eventTime] = getdata(mpc_read,'double');
plot((timeStamp(:,1)-timeStamp(1,1))*24*60*60,value)
title('Measured Outputs Logged from Tags Bucket Brigade.Time,Bucket Brigade.Money')
xlabel('Time (secs)')

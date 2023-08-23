%% Use the GPU to Compute MPC Moves in MATLAB
% This example shows how to generate CUDA® code and use the GPU to compute optimal MPC moves in MATLAB®, using the mpcmoveCodeGeneration function.

%%% Create Plant Model and Design MPC Controller
% Fix random generator seed for reproducibility.
rng(0);

% Create a discrete-time strictly proper plant with 10 states, 3 inputs, and 3 outputs.
plant = drss(10,3,3);
plant.D = 0;

% Create a random initial state for the plant, to be used later in simulation.
x0 = rand(10,1);

% Create an MPC controller with sampling time 0.1 seconds and default prediction and control horizons.
mpcobj = mpc(plant,0.1);

% Specify random constraints on the manipulated and measured variables.
for ct=1:3
    mpcobj.MV(ct).Min = -1*rand;
    mpcobj.MV(ct).Max = 1*rand;
end

for ct=1:3
    mpcobj.OV(ct).Min = -10*rand;
    mpcobj.OV(ct).Max = 10*rand;
end

% Get handle to mpcobj internal state.
xmpc=mpcstate(mpcobj);

%%% Simulate Closed Loop Using mpcmove
% Before generating the code, simulate the plant in closed loop using mpcmove to make sure the behavior is acceptable.
% For this example, the result of the simulation with mpcmove is stored so it can be later compared to the simulation using generated code.

% Initialize arrays that will store moves and outputs for later plotting.
yMV = [];
uMV = [];

% Initialize plant and controller states.
x = x0;
xmpc.Plant=x0;

% Run a closed-loop simulation by calling mpcmove in a loop for 5 steps.
for ct = 1:5
    % Update and store the plant output.
    y = plant.C*x;
    yMV = [yMV y];
    % Compute control actions with ref = ones(1,3)
    u = mpcmove(mpcobj,xmpc,y,ones(1,3));
    % Update and store the plant state.
    x = plant.A*x + plant.B*u;
    uMV = [uMV u];
end

%%% Create Data Structures for Code Generation and Simulation
% Reset controller initial conditions.
xmpc.Plant=x0;
xmpc.Disturbance=zeros(1,3);
xmpc.LastMove=zeros(1,3);

% Use getCodeGenerationData to create the three structures needed for code generation and simulation from the MPC object and its initial state.
% The coredata structure contains the main configuration parameters of the MPC controller that are constant at run time.
% The statedata structure contains the states of the MPC controller, such as for example the state of the plant model, the estimated disturbance, the covariance matrix, and the last control move.
% The onlinedata structure contains data that you must update at each control interval, such as measurement and reference signals, constraints, and weights.
[coredata,statedata,onlinedata] = getCodeGenerationData(mpcobj,'InitialState',xmpc);

% Store the initial state data structure for later re-initialization.
statedata0=statedata;

%%% Simulate Closed Loop Using mpcmoveCodeGeneration
% The mpcmoveCodeGeneration function allows you to simulate the MPC controller in closed loop in a manner similar to mpcmove.
% It takes in the three controller data structures, where statedata and onlinedata represent the current values of the controller states and input signals, respectively, and calculates the optimal control move and the new value of the controller states.
% You can then generate code from mpcmoveCodeGeneration (in this example also CUDA code) and compile it to an executable file (in this example one running on the GPU) which has the same inputs and outputs and therefore can be called from MATLAB in exactly the same way.

% Initialize arrays to store moves and outputs for later plotting.
yCDG = [];
uCDG = [];

% Initialize plant and controller states.
x = x0;
statedata=statedata0;

% Run a closed-loop simulation by calling mpcmoveCodeGeneration in a loop for 5 steps.
for ct = 1:5
    % Update and store the plant output.
    y = plant.C*x;
    yCDG = [yCDG y];
    % Update measured output and reference in online data.
    onlinedata.signals.ym = y;    
    onlinedata.signals.ref = ones(1,3);    
    % Compute control actions.
    [u,statedata] = mpcmoveCodeGeneration(coredata,statedata,onlinedata);
    % Update and store the plant state.
    x = plant.A*x + plant.B*u;
    uCDG = [uCDG u];
end

%%% Generate MEX Function for GPU Execution
% Create a GPU coder configuration option object using the coder.gpuConfig function, and configure the code generation options.
CfgGPU = coder.gpuConfig('mex');
CfgGPU.TargetLang = 'C++';
CfgGPU.EnableVariableSizing = false;
CfgCPU.ConstantInputs = 'IgnoreValues';

% Generate the MEX function mympcmoveGPU from the mpcmoveCodeGeneration MATLAB function, using the codegen command.
% This command generates CUDA code and compiles it to obtain the MEX executable file mympcmoveGPU which runs on the GPU.
codegen('-config',CfgGPU,'mpcmoveCodeGeneration','-o','mympcmoveGPU','-args',{coder.Constant(coredata),statedata,onlinedata});

%%% Simulate Closed Loop Using mympcmoveGPU
% Initialize arrays that will store moves and outputs for later plotting.
yGPU = [];
uGPU = [];

% Initialize plant and controller states.
x = x0;
statedata=statedata0;

% Run a closed-loop simulation by calling mympcmoveGPU in a loop for 5 steps.
for ct = 1:5
    % Update and store the plant output.
    y = plant.C*x;
    yGPU = [yGPU y];
    % Update measured output and reference in online data.
    onlinedata.signals.ym = y;    
    onlinedata.signals.ref = ones(1,3);    
    % Compute control actions.
    [u,statedata] = mympcmoveGPU(coredata,statedata,onlinedata);
    % Update and store the plant state.
    x = plant.A*x + plant.B*u;
    uGPU = [uGPU u];
end

%%% Generate MEX Function for CPU Execution
% Create a coder configuration option object using the coder.Config function, and configure the code generation options.
CfgCPU = coder.config('mex');
CfgCPU.DynamicMemoryAllocation='off';
CfgCPU.EnableVariableSizing = false;
CfgCPU.ConstantInputs = 'IgnoreValues';

% Generate the MEX function mympcmoveCPU from the mpcmoveCodeGeneration MATLAB function, using the codegen command.
% This command generates C code and compiles it to obtain the MEX executable file mympcmoveCPU which runs on the CPU.
codegen('-config',CfgCPU,'mpcmoveCodeGeneration','-o','mympcmoveCPU','-args',{coder.Constant(coredata),statedata,onlinedata});

%%% Simulate Closed Loop Using mympcmoveCPU
% Initialize arrays that will store moves and outputs for later plotting.
yCPU = [];
uCPU = [];

% Initialize plant and controller states.
x = x0;
statedata=statedata0;

% Run a closed-loop simulation by calling mympcmoveCPU in a loop for 5 steps.
for ct = 1:5
    % Update and store the plant output.
    y = plant.C*x;
    yCPU = [yCPU y];
    % Update measured output and reference in online data.
    onlinedata.signals.ym = y;    
    onlinedata.signals.ref = ones(1,3);    
    % Compute control actions.
    [u,statedata] = mympcmoveCPU(coredata,statedata,onlinedata);
    % Update and store the plant state.
    x = plant.A*x + plant.B*u;
    uCPU = [uCPU u];
end

%%% Compare MPC Moves
% First, compare the plant inputs and outputs obtained from mpcmove and the ones obtained using the GPU.
uGPU-uMV

yGPU-yMV

% The simulation results are identical, except for negligible numerical errors, to those using mpcmove.
uCPU-uMV

yCPU-yMV

% Similarly the difference between results obtained by running the mpcmoveCodeGeneration in MATLAB and running the generated code on the CPU is negligible.
uCPU-uCDG

yCPU-yCDG

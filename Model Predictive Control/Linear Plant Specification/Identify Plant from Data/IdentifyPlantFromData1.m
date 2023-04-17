%% Identify Plant from Data
% When designing a model predictive controller, you can specify the internal predictive plant model using a linear identified model.
% You use System Identification Toolbox™ software to estimate a linear plant model in one of these forms:
% - State-space model — idss (System Identification Toolbox)
% - Transfer function model — idtf (System Identification Toolbox)
% - Polynomial model — idpoly (System Identification Toolbox)
% - Process model — idproc (System Identification Toolbox)
% - Grey-box model — idgrey (System Identification Toolbox)
% You can estimate the plant model programmatically at the command line or interactively using the System Identification app.

%%% Identify Plant from Data at the Command Line
% This example shows how to identify a plant model at the command line.
% For information on identifying models using the System Identification app, see Identify Linear Models Using System Identification App (System Identification Toolbox).
% Load the measured input/output data.
load plantIO

% This command imports the plant input signal, u, plant output signal, y, and sample time, Ts to the MATLAB® workspace.
% Create an iddata object from the input and output data.
mydata = iddata(y,u,Ts);

% You can optionally assign channel names and units for the input and output signals.
mydata.InputName = "Voltage";
mydata.InputUnit = "V";
mydata.OutputName = "Position";
mydata.OutputUnit = "cm";

% Typically, you must preprocess identification I/O data before estimating a model.
% For this example, remove the offsets from the input and output signals by detrending the data.
mydatad = detrend(mydata);

% You can also remove offsets by creating an ssestOptions object and specifying the InputOffset and OutputOffset options.
% For this example, estimate a second-order, linear state-space model using the detrended data.
% To estimate a discrete-time model, specify the sample time as Ts.
ss1 = ssest(mydatad,2,Ts=Ts)

% You can use this identified plant as the internal prediction model for your MPC controller.
% When you do so, the controller converts the identified model to a discrete-time, state-space model.
% By default, the MPC controller discards any unmeasured noise components from your identified model.
% To configure noise channels as unmeasured disturbances, you must first create an augmented state-space model from your identified model.
% For example:
ss2 = ss(ss1,"augmented")

% This command creates a state-space model, ss2, with two input groups, Measured and Noise, for the measured and noise inputs respectively.
% When you import the augmented model into your MPC controller, channels in the Noise input group are defined as unmeasured disturbances.

%%% Working with Impulse-Response Models
% You can use System Identification Toolbox software to estimate finite step-response or finite impulse-response (FIR) plant models using measured data.
% Such models, also known as nonparametric models, are easy to determine from plant data ([1] and [2]) and have intuitive appeal.

% Use the impulseest (System Identification Toolbox) function to estimate an FIR model from measured data.
% This function generates the FIR coefficients encapsulated as an idtf (System Identification Toolbox) object; that is, a transfer function model with only numerator coefficients.
% impulseest is especially effective in situations where the input signal used for identification has low excitation levels.
% To design a model predictive controller for this plant, you can convert the identified FIR plant model to a numeric LTI model.
% However, this conversion usually yields a high-order plant, which can degrade the controller design.
% For example, the numerical precision issues with high-order plants can affect estimator design.
% This result is particularly an issue for MIMO systems.

% Model predictive controllers work best with low-order parametric models. Therefore, to design a model predictive controller using measured plant data, you can:
% - Estimate a low-order parametric model using a parametric estimator, such as ssest (System Identification Toolbox).
% - Initially identify a nonparametric model using impulseest, and then estimate a low-order parametric model from the response of the nonparametric model. For an example, see [3].
% - Initially identify a nonparametric model using impulseest, and then convert the FIR model to a state-space model using idss (System Identification Toolbox). You can then reduce the order of the state-space model using balred. This approach is similar to the method used by ssregest (System Identification Toolbox).

%%% References
% [1] Cutler, C., and F. Yocum, "Experience with the DMC inverse for identification," Chemical Process Control — CPC IV (Y. Arkun and W. H. Ray, eds.), CACHE, 1991.
% [2] Ricker, N. L., "The use of bias least-squares estimators for parameters in discrete-time pulse response models," Ind. Eng. Chem. Res., Vol. 27, pp. 343, 1988.
% [3] Wang, L., P. Gawthrop, C. Chessari, T. Podsiadly, and A. Giles, "Indirect approach to continuous time system identification of food extruder," J. Process Control, Vol. 14, Number 6, pp. 603–615, 2004.

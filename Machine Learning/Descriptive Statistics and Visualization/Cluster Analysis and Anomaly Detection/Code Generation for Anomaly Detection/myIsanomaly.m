function varargout = myIsanomaly(MdlFileName,x,varargin) %#codegen
%MYISANOMALY Entry-point function for anomaly detection 
% This function supports only the example Code Generation for Anomaly 
% Detection and might change in a future release. 
% This function detects anomalies in new observations x using the saved 
% anomaly detection model in the MdlFileName file.
Mdl = loadLearnerForCoder(MdlFileName,DataType="single");
[varargout{1:nargout}] = isanomaly(Mdl,x,varargin{:});
end
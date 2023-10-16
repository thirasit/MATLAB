function [tf,scores] = myIsanomalySVM(MdlFileName,x,scoreThreshold) %#codegen
%MYISANOMALY Entry-point function for anomaly detection 
% This function supports only the example Code Generation for Anomaly 
% Detection and might change in a future release. 
% This function detects anomalies in new observations x using the saved 
% one-class support vector machine model in the MdlFileName file.
Mdl = loadLearnerForCoder(MdlFileName,DataType="single");
[~,scores] = predict(Mdl,x);
tf = scores < scoreThreshold;
end
function label = classifyX (X) %#codegen 
%CLASSIFYX Classify using Logistic Regression Model 
%  CLASSIFYX classifies the measurements in X 
%  using the logistic regression model in the file myModel.mat, 
%  and then returns class labels in label.

n = size(X,1);
label = coder.nullcopy(cell(n,1));

CompactMdl = loadLearnerForCoder('myModel');
probability = predict(CompactMdl,X);

index = ~isnan(probability).*((probability<0.5)+1) + isnan(probability)*3;

classInfo = coder.load('ModelParameters');
classNames = classInfo.classNames;

for i = 1:n    
    label{i} = classNames{index(i)};
end
end
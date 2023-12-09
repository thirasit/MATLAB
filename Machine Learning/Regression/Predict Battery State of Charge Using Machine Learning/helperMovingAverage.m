%%% Helper Function
% This code creates the helperMovingAverage helper function.
function newTbl = helperMovingAverage(tbl)

newTbl = tbl(1:100:end,[1:3,end]);
variableNames = ["Voltage","Current","Temperature","SOC"];
newTbl.Properties.VariableNames = variableNames;

n = size(newTbl,1);
newTbl.AverageVoltage = NaN(n,1);
newTbl.AverageCurrent = NaN(n,1);

for i = 1 : n
    newTbl.AverageVoltage(i) = mean(newTbl.Voltage(max(1,i-5):i));
    newTbl.AverageCurrent(i) = mean(newTbl.Current(max(1,i-5):i));
end

newTbl = movevars(newTbl,"SOC",After="AverageCurrent");
end
function y = forwardfill(xs,ts,tq,n)
% Fill n values in the missing gap using the previous nonmissing value
y = NaN(1,numel(tq));
y(1:min(numel(tq),n)) = xs;
end
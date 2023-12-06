%% Helper Function
function helper_plotResiduals(stats)
pwres = stats.pwres;
iwres = stats.iwres;
cwres = stats.cwres;
figure
subplot(2,3,1);
normplot(pwres); title('PWRES')
subplot(2,3,4);
createhistplot(pwres);

subplot(2,3,2);
normplot(cwres); title('CWRES')
subplot(2,3,5);
createhistplot(cwres);

subplot(2,3,3);
normplot(iwres); title('IWRES')
subplot(2,3,6);
createhistplot(iwres); title('IWRES')

    function createhistplot(pwres)
        h = histogram(pwres);
        
        % x is the probability/height for each bin
        x = h.Values/sum(h.Values*h.BinWidth);
        
        % n is the center of each bin
        n = h.BinEdges + (0.5*h.BinWidth);
        n(end) = [];
        
        bar(n,x);
        ylim([0 max(x)*1.05]);
        hold on;
        x2 = -4:0.1:4;
        f2 = normpdf(x2,0,1);
        plot(x2,f2,'r');
    end

end
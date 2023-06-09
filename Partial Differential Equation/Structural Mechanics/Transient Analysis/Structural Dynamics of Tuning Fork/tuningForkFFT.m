function [f,P1] = tuningForkFFT(tipDisp,Fs)
L = numel(tipDisp);
L = L + mod(L,2); % Replace L with the nearest even integer
Y = fft(tipDisp);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
end
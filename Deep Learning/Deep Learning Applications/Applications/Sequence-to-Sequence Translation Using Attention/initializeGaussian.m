function weights = initializeGaussian(sz,mu,sigma)

weights = randn(sz,'single')*sigma + mu;
weights = dlarray(weights);

end
function SSE = fitgaussmin(params,data,x)
%
% function SSE = fitgauss(params,x,y)
%
% Sum-squared error between data and y and gaussian pdf evaluated at values
% in x, with parameters:
% params(1) = mu, the mean
% params(2) = sigma, the standard deviation
%
% Can use with fminsearch to fit, e.g.:
% pars = fminsearch(@fitgauss, guess, [], x, y);

 
mu          = params(1);
sigma       = params(2);
meanflat    = params(3);
heightgauss = params(4);

Est = meanflat.*ones(size(x)) + heightgauss.*normpdf(x,mu,sigma);
SSE = sum( (data - Est).^2 );
function tests = obob_testOBOB_ownft_corrlc()
tests = functiontests({@test_corrlc});
end

function test_corrlc(testCase)
addpath(fullfile(fileparts(mfilename('fullpath')), '../../../'));
cfg = [];
obob_init_ft(cfg);

%%
load data/freq4corrcl

%%
linvec=rand(1,length(freq.trialinfo));
cfg=[];
cfg.method='analytic';
cfg.statistic='obob_statfun_corrlc';
cfg.design=[1:length(freq.trialinfo); linvec];
cfg.ivar=2;
cfg.uvar=1;
cfg.parameter='fourierspctrm';

test=ft_freqstatistics(cfg, freq);

%%
test2=zeros(length(freq.label), length(freq.freq),length(freq.time));
pval2=test2;
anglemat=angle(freq.fourierspctrm);

for ll=1:length(freq.label)
  for ff=1:length(freq.freq)
    for tt=1:length(freq.time)
      [rho pval] = circ_corrcl(anglemat(:,ll,ff,tt), linvec);
      test2(ll,ff,tt)=rho;
      pval2(ll,ff,tt)=pval;
    end %tt
  end %ff
end %ll

%%
testCase.assertEqual(mean(test2(:)), mean(test.rho(:)), 'RelTol', 10*eps);
testCase.assertEqual(mean(pval2(:)), mean(test.prob(:)), 'RelTol', 10*eps);
end

function [rho pval] = circ_corrcl(alpha, x)
%
% [rho pval ts] = circ_corrcc(alpha, x)
%   Correlation coefficient between one circular and one linear random
%   variable.
%
%   Input:
%     alpha   sample of angles in radians
%     x       sample of linear random variable
%
%   Output:
%     rho     correlation coefficient
%     pval    p-value
%
% References:
%     Biostatistical Analysis, J. H. Zar, p. 651
%
% PHB 6/7/2008
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html


if size(alpha,2) > size(alpha,1)
	alpha = alpha';
end

if size(x,2) > size(x,1)
	x = x';
end

if length(alpha)~=length(x)
  error('Input dimensions do not match.')
end

n = length(alpha);

% compute correlation coefficent for sin and cos independently
rxs = corr(x,sin(alpha));
rxc = corr(x,cos(alpha));
rcs = corr(sin(alpha),cos(alpha));

% compute angular-linear correlation (equ. 27.47)
rho = sqrt((rxc^2 + rxs^2 - 2*rxc*rxs*rcs)/(1-rcs^2));

% compute pvalue
pval = 1 - chi2cdf(n*rho^2,2);

end









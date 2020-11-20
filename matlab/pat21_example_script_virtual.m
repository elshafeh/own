% Here he is trying to find maximum gamma power
% reference : http://www.fieldtriptoolbox.org/tutorial/connectivityextended?s[]=virtual&s[]=sensors

load data_cmb.mat 
load hdm.mat 
load source_coh_lft.mat

[maxval, maxpowindx] 	= 	max(source_diff.avg.pow);
% [x,y,z]   				=	source_diff.pos(maxpowindx, :) % in the mni space 

cfg                   	= [];
cfg.covariance        	= 'yes';
cfg.channel           	= 'MEG';
cfg.vartrllength      	= 2;
cfg.covariancewindow  	= 'all';
tlock                 	= ft_timelockanalysis(cfg, data_cmb);

cfg              	= [];
cfg.method       	= 'lcmv';
cfg.vol          	= hdm;
cfg.grid.pos     	= sourcemodel.pos(maxpowindx, :);
cfg.grid.inside  	= true(2,1);
cfg.grid.unit    	= sourcemodel.unit;
cfg.lcmv.keepfilter = 'yes';
source_idx       	= ft_sourceanalysis(cfg, tlock);

beamformer_gam_pow = source_idx.avg.filter;

chansel = ft_channelselection('MEG', data_cmb.label); % find MEG sensor names
chansel = match_str(data_cmb.label, chansel);         % find MEG sensor indices

gam_pow_data = [];
gam_pow_data.label = {'gam_pow_x', 'gam_pow_y', 'gam_pow_z'};
gam_pow_data.time = data_cmb.time;

for i=1:length(data_cmb.trial)
    
  gam_pow_data.trial{i} = beamformer_gam_pow * data_cmb.trial{i}(chansel,:);
  
end

% The virtual channel data just computed has three channels per location. 
% These correspond to the three orientations of the dipole in a single voxel. 
% The interpretation of connectivity is facilitated if we can compute it between plain channels rather than between triplets of channels. 
% Therefore we will project the time-series along the dipole direction that explains most variance. 
% This projection is equivalent to determining the largest (temporal) eigenvector and can 
% be computationally performed using the singular value decomposition (svd). 

visualTimeseries    = cat(2, gam_pow_data.trial{:});
[u1, s1, v1]        = svd(visualTimeseries, 'econ');
[u2, s2, v2]        = svd(motorTimeseries, 'econ');     

% Matrices u1 and u2 contain the spatial decomposition, matrices v1 and v2 the temporal and on the diagonal of matrices s1 and s2 you can find the eigenvalues.
 % We now recompute the virtual channel time-series, but now only for the dipole direction that has the most power.

virtualchanneldata = [];
virtualchanneldata.label = {'visual', 'motor'};
virtualchanneldata.time = data_cmb.time;

for k = 1:length(data_cmb.trial)
    virtualchanneldata.trial{k}(1,:) = u1(:,1)' * beamformer_gam_pow * data_cmb.trial{k}(chansel,:);
end
% This file is part of the obob_ownft distribution, see: https://gitlab.com/obob/obob_ownft/
%
%    obob_ownft is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    obob_ownft is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with obob_ownft. If not, see <http://www.gnu.org/licenses/>.
%
%    Please be aware that we can only offer support to people inside the
%    department of psychophysiology of the university of Salzburg and
%    associates.

clear all

% initialize cimec_ownft with gm2, svs,  and add BCT package before
%% load some data that are in the right format (virtual sensor data)
% the example data contain epochs with threshold visual stimuli and the
% contrast  below is detected vs undetected
data = load('/mnt/obob/staff/pruhnau/svs_testfile/01_LF.mat');             

% select detected and undetected NT trials
cfg = [];
cfg.trials = find(ismember(data.trialinfo, [105 106 205 206 107 108 207 208]));

data = ft_selectdata(cfg, data);

%% tf with fourier
cfg = [];
cfg.output       = 'fourier';
cfg.channel      = 'all';
% chose only a subset to keep system load low
cfg.foi          = 8:2:12;
cfg.toi          = [0:0.1:0.5];

cfg.method       = 'mtmconvol';

cfg.taper        = 'dpss'; 
cfg.tapsmofrq    = 3;
cfg.t_ftimwin    = ones(1,numel(cfg.foi)).*0.5;% need at least one full cycle for smoothing frequency

cfg.keeptrials = 'yes'; %

% if you want to use multi tapers you need to select trials before you do connectivity!
cfg.trials = find(ismember(data.trialinfo, [105 106 205 206]));
data_tf{1}= ft_freqanalysis(cfg,data);

% if you want to use multi tapers you need to select trials before you do connectivity!
cfg.trials = find(ismember(data.trialinfo, [107 108 207 208]));
data_tf{2}= ft_freqanalysis(cfg,data);


%% source connectivity

% do imaginary coherence for each time point (data to large otherwise)
for iC = 1:numel(data_tf)
    for iT = 1:numel(data_tf{iC}.time)
        cfg = [];
        cfg.latency = data_tf{iC}.time(iT);
        
        tmp = ft_selectdata(cfg, data_tf{iC});
        % selectdata is afraid of getting something wrong with the
        % fourierspctrm, thus we have to select it ourselves
        tmp.fourierspctrm =  data_tf{iC}.fourierspctrm(:,:,:,iT);
        
        % get crossspctrm at that time
        tmp=ft_checkdata(tmp, 'cmbrepresentation', 'fullfast');
        
        cfg=[];
        cfg.method='coh';
        cfg.complex='imag';
        sconnT=ft_connectivityanalysis(cfg, tmp);
        
        if iT == 1
            sconn{iC} = sconnT; 
            sconn{iC} = rmfield(sconn{iC}, 'cfg');
        else
            sconn{iC}.cohspctrm(:,:,:,iT) = sconnT.cohspctrm;
            sconn{iC}.time(iT) = sconnT.time;   
        end
        
        clear tmp
    end
end
% abs of imaginary coherence (no direction for now)
sconn{1}.cohspctrm = abs(sconn{1}.cohspctrm);
sconn{2}.cohspctrm = abs(sconn{2}.cohspctrm);

%% get a threshold for that matrix
% 'sensible' density
kden = .3;
N = size(sconn{1}.cohspctrm,1);

% n of edges
K = kden * ((N^2-N)/2);

% here be lazy and take threshold from average (with real data do at least
% freq wise)
mean_con = squeeze(mean(mean(sconn{1}.cohspctrm,3),4));

sorted_data = sort(mean_con(:),1, 'descend');
thresh = sorted_data(ceil(K*2));

%% make an adjacency matrix spectrum
sconn{1}.adjmatspctrm = sconn{1}.cohspctrm > thresh;
sconn{2}.adjmatspctrm = sconn{2}.cohspctrm > thresh;
% double, necessary for some functions
sconn{1}.adjmatspctrm = double(sconn{1}.adjmatspctrm );
sconn{2}.adjmatspctrm = double(sconn{2}.adjmatspctrm );

%% clear everything but sconn
keep sconn
%% now test global measures

measureArray = {'density' 'efficiency' 'clustering' 'smallworld' ...
  'disconnection' 'charpath'};
%% loop thru
for i = 1:numel(measureArray)
  measure = measureArray{i};
  
  cfg = [];
%   cfg.latency = [.6 .7]; % test input values
%   cfg.frequency = [10 12]; % test input values
  cfg.measure = measure;
  gm1 = obob_gm2_global_measure(cfg, sconn{1});
  gm2 = obob_gm2_global_measure(cfg, sconn{2});
  
  gm1.(measure) = squeeze(gm1.(measure));
  gm2.(measure) = squeeze(gm2.(measure));
  
  % one cond
  figure;imagesc(gm1.time, gm1.freq, gm1.(measure));
  title(measure)
  % contrast
  figure;imagesc(gm1.time, gm1.freq, (gm1.(measure) - gm2.(measure)) ./ gm2.(measure));
  title([measure ' 1 vs 2'])
end


%% now local stuff
% first load default grid and mri
load mni_grid_1_5_cm_889pnts
load standard_mri

%% measures
measureArray = {'degrees' 'efficiency' 'clustering' 'betweenness'};

%% loop thru (be aware that this can take quite long!!!)
for i = 1:numel(measureArray)
  measure = measureArray{i};

  cfg = [];
  cfg.measure = measure;
%   cfg.latency = [.4 .8];
%   cfg.frequency = [8 12];
  gm1 = obob_gm2_local_measure(cfg, sconn{1});
  gm2 = obob_gm2_local_measure(cfg, sconn{2});

  % this is the same as measure, but for illustrative purposes (plus check) ...
  param = gm1.measure; 
  
  cfg = [];
  cfg.parameter = param;
  cfg.mri = mri;
  cfg.sourcegrid = template_grid;
  cfg.foilim = [8 12]; % for the example we look at alpha
  cfg.toilim = [.4 .8]; % in poststim

  
  src1 = obob_svs_virtualsens2source(cfg, gm1);
  src2 = obob_svs_virtualsens2source(cfg, gm2);
  
  % put difference in 2
  src2.(param) = (src1.(param) - src2.(param)) ./ src2.(param);
  
  % plot 1 and diff
  cfg = [];
  cfg.funparameter = param;
  cfg.method = 'slice'; % 'ortho' style doesn't work properly in linux and matlab > 2014a
  ft_sourceplot(cfg, src1);
  title(gm1.measure)
  ft_sourceplot(cfg, src2);
  title(['Contrast 1 vs 2 ' gm1.measure])
end


%% check makerandgraph (potentially useful for stats)
cfg = [];
rn1 = obob_gm2_makerandgraph(cfg, sconn{1});

% density should be the same, check!
cfg = [];
cfg.measure = 'density';
gm1 = obob_gm2_global_measure(cfg, sconn{1});
gm2 = obob_gm2_global_measure(cfg, rn1);


% transform to source structure
measure = gm1.measure; 

gm1.(measure) = squeeze(gm1.(measure));
gm2.(measure) = squeeze(gm2.(measure));

% plot single conds
figure;imagesc(gm1.time, gm1.freq, gm1.(measure));
title(measure)
figure;imagesc(gm2.time, gm2.freq, gm2.(measure));
title(measure)

% contrast - this should be 0!!!
figure;imagesc(gm1.time, gm1.freq, (gm1.(measure) - gm2.(measure)) ./ gm2.(measure));
title([measure ' 1 vs 2'])



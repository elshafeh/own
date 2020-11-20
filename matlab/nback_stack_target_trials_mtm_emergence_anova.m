clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    suj_name                        = ['sub' num2str(suj_list(nsuj))];
    i                               = 0;
    
    for nback = [0 1 2]
        
        fname                       = ['/project/3015039.06/hesham/nback/tf/' suj_name '.' num2str(nback) 'back.1t100Hz.1HzStep.avgTrials.nonfill.rearranged.mat'];
        fprintf('loading %s\n',fname);
        load(fname); clear fname;
        
        list_act{1}                 = [-0.6 2];
        list_act{2}                 = [-0.6 2; 1.4 4];
        list_act{3}                 = [-0.6 2; 1.4 4;3.4 6];
        
        for nact = 1:size(list_act{nback+1},1)
            
            cfg                     = [];
            cfg.latency             = list_act{nback+1}(nact,:);
            data                    = ft_selectdata(cfg,freq_comb);
            
            data.time               = -0.6:0.01:2;
            
            cfg                     = [];
            cfg.baseline            = [-0.4 -0.2];
            cfg.baselinetype        = 'relchange';
            data                    = ft_freqbaseline(cfg,data);
            
            i                       = i +1;
            alldata{nsuj,i}         = data; clear data;
            
        end
    end
    
    keep alldata nsuj suj_list
    
end

keep alldata



list_cond                           = {'0Back tar' '1Back 1st' '1Back tar' '2Back 1st' '2Back 2nd' '2Back tar'};

nbsuj                               = size(alldata,1);
[~,neighbours]                      = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t'); clc;

cfg                                 = [];
cfg.method                          = 'ft_statistics_montecarlo';
cfg.statistic                       = 'ft_statfun_depsamplesFmultivariate';
cfg.correctm                        = 'cluster';
cfg.clusteralpha                    = 0.05;
cfg.clusterstatistic                = 'maxsum';
cfg.clusterthreshold                = 'nonparametric_common';
cfg.tail                            = 1; % For a F-statistic, it only make sense to calculate the right tail
cfg.clustertail                     = cfg.tail;
cfg.alpha                           = 0.05;
cfg.computeprob                     = 'yes';
cfg.numrandomization                = 1000;
cfg.neighbours                      = neighbours;
cfg.alpha                           = 0.025;
cfg.numrandomization                = 1000;

cfg.minnbchan                       = 3; % !!
cfg.latency                         = [0 1.5];
cfg.frequency                       = [7 35];

design                              = zeros(2,6*nbsuj);
design(1,1:nbsuj)                   = 1;
design(1,nbsuj+1:2*nbsuj)           = 2;
design(1,nbsuj*2+1:3*nbsuj)         = 3;
design(1,nbsuj*3+1:4*nbsuj)         = 4;
design(1,nbsuj*4+1:5*nbsuj)         = 5;
design(1,nbsuj*5+1:6*nbsuj)         = 6;
design(2,:)                         = repmat(1:nbsuj,1,6);

cfg.design                          = design;
cfg.ivar                            = 1; % condition
cfg.uvar                            = 2; % subject number

stat                                = ft_freqstatistics(cfg, alldata{:,1},alldata{:,2},alldata{:,3},alldata{:,4},alldata{:,5},alldata{:,6});

for nsuj = 1:size(alldata,1)
    for ncond = 1:size(alldata,2)
        cfg                      	= [];
        cfg.channel              	= stat.label;
        cfg.latency                 = stat.time([1 end]);
        newalldata{nsuj,ncond}     	= ft_selectdata(cfg,alldata{nsuj,ncond});
    end
    clc;
end

nrow                                = 4;
ncol                            	= 4;
i                                   = 0;

for ncluster = 1:10
    
    tmp_mat                      	= stat.posclusterslabelmat;
    tmp_mat(tmp_mat~= ncluster)  	= 0;
    
    stoplot                      	= [];
    stoplot.time                 	= stat.time;
    stoplot.freq                 	= stat.freq;
    stoplot.label               	= stat.label;
    stoplot.dimord                	= 'chan_freq_time';
    stoplot.powspctrm           	= squeeze(stat.stat .* stat.mask .* tmp_mat);
    
    i                              	= i + 1;
    subplot(nrow,ncol,i)
    
    cfg                           	= [];
    cfg.layout                  	= 'neuromag306cmb.lay';
    cfg.marker                      = 'off';
    cfg.comment                  	= 'no';
    cfg.colorbar                	= 'no';
    cfg.ylim                     	= 'zeromax';
    cfg.colormap                    = brewermap(256, '*Reds');
    ft_topoplotTFR(cfg,stoplot);
    
    i = i +1;
    subplot(nrow,ncol,i)
    cfg                         = [];
    ft_singleplotTFR(cfg,stoplot);
    title('');
    
end

% for ncluster = 1:5
%     i = i +1;
%     subplot(nrow,ncol,i)
%     h_plotanova(stat,newalldata,1,list_cond)
% end
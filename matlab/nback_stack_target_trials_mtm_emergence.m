clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    suj_name                    = ['sub' num2str(suj_list(nsuj))];
    
    for nback = [0 1 2]
        
        fname                   = ['/project/3015039.06/hesham/nback/tf/' suj_name '.' num2str(nback) 'back.1t100Hz.1HzStep.avgTrials.nonfill.rearranged.mat'];
        fprintf('loading %s\n',fname);
        load(fname); clear fname;
        
        list_act                = [-0.2 2; -0.2 4; -0.2 6];
        
        %         cfg                 = [];
        %         cfg.trials          = find(freq_comb.trialinfo(:,3) == 1);
        %         cfg.avgoverrpt      = 'yes'; % ft_selectdata(cfg,freq_comb);
        %         freq_comb               = ft_freqdescriptives([],freq_comb);
        
        [suj_act,suj_bsl]       = h_prepareBaseline(freq_comb,[-0.6 -0.4],[1 100],list_act(nback+1,:),'no');
        
        alldata{nsuj,nback+1,1} = suj_act; clear suj_act;
        alldata{nsuj,nback+1,2} = suj_bsl; clear suj_bsl;
        
        
    end
end

keep alldata

list_cond                   = {'0Back','1Back','2Back'};

cfg                       	= [];
cfg.statistic            	= 'ft_statfun_depsamplesT';
cfg.method                  = 'montecarlo';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.frequency               = [7 35];
cfg.clusterstatistic        = 'maxsum';
cfg.minnbchan               = 4;
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.uvar                    = 1;
cfg.ivar                    = 2;
nbsuj                       = size(alldata,1);
[design,neighbours]         = h_create_design_neighbours(nbsuj,alldata{1,1},'elekta','t');
cfg.design                  = design;
cfg.neighbours              = neighbours;

for ncond = 1:size(alldata,2)
    stat{ncond}          	= ft_freqstatistics(cfg, alldata{:,ncond,1}, alldata{:,ncond,2});
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}] 	= h_pValSort(stat{ntest});
end

keep alldata list_* stat min_p p_val

close all;

for ntest = 1:length(stat)
    
    list_vline              = [0 0 0; 0 0 2; 0 2 4];
    
    cfg                     = [];
    cfg.layout             	= 'neuromag306cmb.lay';
    cfg.zlim                = [-3 3];
    cfg.colormap         	= brewermap(256,'*RdBu');
    cfg.plimit           	= 0.11;
    cfg.vline               = list_vline(ntest,:);
    cfg.sign                = -1;
    h_plotstat_3d(cfg,stat{ntest});
    
end
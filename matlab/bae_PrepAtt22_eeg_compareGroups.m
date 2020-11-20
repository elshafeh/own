clear ; clc ;

patient_list ;
suj_group{1}    = fp_list_eeg;
suj_group{2}    = cn_list_eeg;

for ngrp = 1:2
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj             = suj_list{sb};
        cond_main       = 'nDT.eeg';
        
        if strcmp(cond_main,'CnD.eeg')
            fname_in        = ['../data/' suj '/field/' suj '.' cond_main '.bpOrder2Filt0.2t20Hz.pe.mat'];
        else
            fname_in        = ['../data/' suj '/field/' suj '.' cond_main '.bpOrder2Filt0.5t20Hz.pe.mat'];
        end
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in);
        
        cfg                         = [];
        cfg.baseline                = [-0.1 0];
        data_pe                     = ft_timelockbaseline(cfg,data_pe);
        
        allsuj_data{ngrp}{sb,1}     = data_pe;
        
        clear data_pe data_gfp*
        
    end
    
    gavg_data{ngrp,1}               = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,1});
    
end

clearvars -except *_data ; clc ; 

nbsuj                   = size(allsuj_data{1},1);
[design,neighbours]     = h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'gfp','t');

cfg                     = [];

cfg.latency             = [-0.1 0.6];

cfg.statistic           = 'indepsamplesT';
cfg.method              = 'montecarlo';    
cfg.correctm            = 'cluster';        
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.design              = [ones(nbsuj) ones(nbsuj)*2];
cfg.ivar                = 1;

cfg.neighbours          = neighbours;
cfg.minnbchan           = 0;

stat                    = ft_timelockstatistics(cfg, allsuj_data{1}{:,1}, allsuj_data{2}{:,1});
[min_p,p_val]           = h_pValSort(stat) ;

for nchan = 1:length(stat.label)
    
    subplot(2,4,nchan)
    
    cfg                     = [];
    cfg.channel             = nchan;
    cfg.p_threshold         = 0.05;
    cfg.lineWidth           = 3;
    cfg.time_limit          = [-0.1 0.6];
    cfg.z_limit             = [-10 10];
    cfg.fontSize            = 18;
    
    h_plotSingleERFstat_selectChannel(cfg,stat,gavg_data{1,1}, gavg_data{2,1});
    title(stat.label{nchan})
    legend({'FPatient','FControl'})
    
end
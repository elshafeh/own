clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list    = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                         = ['yc' num2str(suj_list(sb))];
    
    ext_name2                                   = 'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse.PhaseLockingValueAndFreq';
    fname_in                                    = ['../data/paper_data/' suj '.' ext_name2 '.mat'];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(fname_in)
    
    allsuj_data{sb,1}                           = [];
    allsuj_data{sb,1}.label                     = phase_lock.label;
    allsuj_data{sb,1}.freq                      = phase_lock.freq;
    allsuj_data{sb,1}.time                      = phase_lock.time;
    allsuj_data{sb,1}.dimord                    = phase_lock.dimord;
    allsuj_data{sb,1}.powspctrm                 = phase_lock.rayleigh;
    
    load ../data/yctot/rt/rt_CnD_adapt.mat
    
    allsuj_behav{sb,1}                          = mean(rt_all{sb});
    allsuj_behav{sb,2}                          = median(rt_all{sb});
    
end

clearvars -except allsuj_*

for ntest = 1:size(allsuj_behav,2)
    
    nsuj                                = size(allsuj_data,1);
    [design,neighbours]                 = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t');
    
    cfg                                 = [];
    cfg.latency                         = [0.2 1.2];
    cfg.frequency                       = [7 15];
    cfg.method                          = 'montecarlo';
    cfg.statistic                       = 'ft_statfun_correlationT';
    cfg.neighbours                      = neighbours;
    cfg.minnbchan                       = 0;
    cfg.correctm                        = 'cluster';
    
    cfg.clusterstatistics               = 'maxsum';
    cfg.clusteralpha                    = 0.05;
    cfg.tail                            = 0;
    cfg.clustertail                     = 0;
    cfg.alpha                           = 0.025;
    cfg.numrandomization                = 1000;
    cfg.ivar                            = 1;
    
    cfg.type                            = 'Spearman';
    
    cfg.design(1,1:nsuj)                = [allsuj_behav{:,ntest}];
    
    stat{ntest}                         = ft_freqstatistics(cfg, allsuj_data{:,1});
    
end

clearvars -except allsuj_* stat

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}] = h_pValSort(stat{ntest});
end

clearvars -except allsuj_* stat min_p p_val

i = 0 ;

for ntest = 1:length(stat)
    
    s_to_plot = stat{ntest};
    
    for nchan = 1:length(s_to_plot.label)
        
        s_to_plot.mask      = s_to_plot.prob < 0.11;
        
        i = i + 1;
        
        subplot(2,6,i)
        
        cfg                 = [];
        cfg.channel         = nchan;
        cfg.parameter       = 'stat';
        cfg.maskparameter   = 'mask';
        cfg.maskstyle       = 'outline';
        cfg.zlim            = [-5 5];
        cfg.colorbar        = 'no';
        ft_singleplotTFR(cfg,s_to_plot);
        
        title(s_to_plot.label{nchan})
        
    end
end
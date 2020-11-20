clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list            = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                 = ['yc' num2str(suj_list(sb))] ;
    cond_main                           = 'CnD.MaxAudVizMotor.BigCov.VirtTimeCourse';
    list_cue                            = {'R','NR','L','NL'};
    
    for ncue = 1:length(list_cue)
        
        fname_in                        = ['../data/paper_data/' suj '.' list_cue{ncue} cond_main '.WithEvoked.PhaseLockingValueAndFreq.mat'];
                
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        clear freq ;
        
        data.label                      = phase_lock.label; data.freq = phase_lock.freq; data.time = phase_lock.time; data.dimord = phase_lock.dimord;
        data.powspctrm                  = phase_lock.rayleigh ;
        
        %         cfg                             = [];
        %         cfg.baseline                    = [-0.6 -0.2];
        %         cfg.baselinetype                = 'relchange';
        %         data_bsl                        = ft_freqbaseline(cfg,data);
        
        allsuj_data{sb,ncue}            = data;
        
    end
end

clearvars -except allsuj_*;

nsuj                        = size(allsuj_data,1);
[design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

list_test                   = [1 2; 3 4];

for ntest = 1:size(list_test,1)
    
    cfg                     = [];
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    
    cfg.correctm            = 'cluster';
    cfg.neighbours          = neighbours;
    
    cfg.latency             = [-0.2 2];
    cfg.frequency           = [5 15];
    
    %     cfg.avgoverfreq         = 'yes';
    
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    cfg.minnbchan           = 0;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    stat{ntest}              = ft_freqstatistics(cfg, allsuj_data{:,list_test(ntest,1)} , allsuj_data{:,list_test(ntest,2)});
    
end

clearvars -except allsuj_* stat;

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}]      = h_pValSort(stat{ntest});
end

for ntest = 1:length(stat)
    
    figure;
    i = 0;
    
    for nchan = 1:length(stat{ntest}.label)
        
        stat_to_plot       = stat{ntest};
        stat_to_plot.mask  = stat_to_plot.prob < 0.4;
        
        i = i + 1;
        
        subplot(3,2,i)
        
        cfg                 = [];
        cfg.channel         = nchan;
        cfg.parameter       = 'stat';
        cfg.maskparameter   = 'mask';
        cfg.maskstyle       = 'outline';
        cfg.zlim            = [-5 5];
        
        ft_singleplotTFR(cfg,stat_to_plot);
        
        title(stat_to_plot.label{nchan})
        
        colormap(viridis)
    end
end
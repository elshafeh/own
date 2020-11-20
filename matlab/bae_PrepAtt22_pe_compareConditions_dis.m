clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

patient_list ;
suj_group{1}    = fp_list_meg;
suj_group{2}    = cn_list_meg;

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'1DIS','1fDIS'};
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                                = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                tmp{dis_type}                           = data_pe;
                
                clear data_pe data_gfp
                
            end
            
            allsuj_data{ngrp}{sb,ncue}                  = tmp{1};
            allsuj_data{ngrp}{sb,ncue}.avg              = tmp{1}.avg - tmp{2}.avg ;
            
            cfg                                         = [];
            cfg.baseline                                = [-0.1 0];
            allsuj_data{ngrp}{sb,ncue}                  = ft_timelockbaseline(cfg,allsuj_data{ngrp}{sb,ncue});
            
        end
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub

nbsuj                   = length(allsuj_data{1});
[design,neighbours]     =  h_create_design_neighbours(nbsuj,allsuj_data{1}{1},'meg','t');

cfg                     = [];
cfg.latency             = [-0.1 0.65];
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.minnbchan           = 4;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.neighbours          = neighbours;
cfg.design              = design;
cfg.uvar                = 1;
cfg.ivar                = 2;

ix_test                 = [1 2];

for ngroup = 1:2
    for ntest = 1:size(ix_test,1)
        stat{ngroup,ntest}        = ft_timelockstatistics(cfg, allsuj_data{ngroup}{:,ix_test(ntest,1)}, allsuj_data{ngroup}{:,ix_test(ntest,2)});
    end
end

for ngroup = 1:2
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest),p_val{ngroup,ntest}]           = h_pValSort(stat{ngroup,ntest}) ;
    end
end

for ngroup = 1:2
    for ntest = 1:size(stat,2)
        
        stat{ngroup,ntest}.mask             = stat{ngroup,ntest}.prob < 0.1;
        stat2plot{ngroup,ntest}             = [];
        stat2plot{ngroup,ntest}.avg         = stat{ngroup,ntest}.mask .* stat{ngroup,ntest}.stat;
        stat2plot{ngroup,ntest}.label       = stat{ngroup,ntest}.label;
        stat2plot{ngroup,ntest}.dimord      = stat{ngroup,ntest}.dimord;
        stat2plot{ngroup,ntest}.time        = stat{ngroup,ntest}.time;
        
    end
end

i = 0 ;

for ngroup = 1:2
    
    %     for ncue = 1:2
    %
    %         figure;
    %
    %         cfg         = [];
    %         cfg.xlim    = [0.2 0.3]; %0:0.1:0.3;
    %         cfg.layout  = 'CTF275.lay';
    %         cfg.zlim    = [-60 60];
    %         ft_topoplotER(cfg,gavg_data{ncue});
    %
    %     end
    
    for ntest = 1:size(stat,2)
        
        figure;
        
        %         twin                    = 0.2;
        %         tlist                   = stat{ngroup,ntest}.time(1):twin:stat{ngroup,ntest}.time(end);
        
        %         for t = 1:length(tlist)-1
        %             i = i + 1;
        %             subplot(2,2,i)
        
        cfg         = [];
        %         cfg.xlim    = [tlist(t) tlist(t)+twin];
        cfg.layout = 'CTF275.lay';
        cfg.zlim = [-3 3];
        ft_topoplotER(cfg,stat2plot{ngroup,ntest});
        
        %         end
    end
    
end


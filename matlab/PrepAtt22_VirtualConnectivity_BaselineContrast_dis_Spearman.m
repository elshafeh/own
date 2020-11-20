clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_group = suj_group(3);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        list_ix_dis         = {'DIS1','fDIS1'};
        
        for ndis = 1:length(list_ix_dis)
            
            fname_in          = ['../data/pat22_data/' suj '.' list_ix_dis{ndis} '.AudSchaef.50t120Hz.m200p800msCov.PowSpearCorr.MinEvoked.mat'];
            fprintf('Loading %s\n',fname_in);
            load(fname_in)
            
            allsuj_activation{ngroup}{sb,ndis}      = freq_conn;
            
            clear tmp freq ;
            
        end
    end
end

clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                    = size(allsuj_activation{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'virt','t'); clc;
    
    cfg                     = [];
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    cfg.neighbours          = neighbours;
    
    cfg.correctm            = 'cluster';
    
    cfg.latency             = [0.1 0.55];
    cfg.frequency           = [60 100];
    
    %     cfg.avgovertime         = 'yes';
    cfg.avgoverfreq         = 'yes';
    
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    cfg.minnbchan           = 0;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    stat{ngroup}            = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,1},allsuj_activation{ngroup}{:,2});
    
end

for ngroup = 1:size(stat,1)
    [min_p(ngroup),p_val{ngroup}] = h_pValSort(stat{ngroup});
end

p_limit = 0.3;
i = 0 ;
for ngroup = 1:size(stat,1)
    
    stat_to_plot       = stat{ngroup};
    
    for nchan = 1:length(stat_to_plot.label)
        
        if min(unique(stat_to_plot.prob(nchan,:,:))) < p_limit
            
            stat_to_plot.mask  = stat_to_plot.prob < p_limit;
            
            %             figure;
            
            if size(stat_to_plot.prob,2) == 1
                
                plot(stat_to_plot.time,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
                ylim([-2 2]);
                
            elseif size(stat_to_plot.prob,3) == 1
                
                plot(stat_to_plot.freq,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
                ylim([-2 2]);
                
            else
                
                i = i +1;
                subplot(4,1,i)
                
                cfg                 = [];
                cfg.channel         = nchan;
                cfg.parameter       = 'stat';
                cfg.maskparameter   = 'mask';
                cfg.maskstyle       = 'outline';
                cfg.zlim            = [-5 5];
                ft_singleplotTFR(cfg,stat_to_plot);
                
                
            end
            
            title(stat_to_plot.label{nchan},'FontSize',16)
            colormap(redblue)
            
        end
    end
end
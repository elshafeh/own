clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_group = suj_group(3);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        list_ix_dis         = {'DIS','fDIS'};
        
        for ndis = 1:length(list_ix_dis)
            
            fname_in          = ['../data/pat22_data/' suj '.' list_ix_dis{ndis} '.AudSchaef.50t120Hz.m200p800msCov.plv.MinEvoked.mat'];
            fprintf('Loading %s\n',fname_in);
            load(fname_in)
            
            freq              = [];
            freq.time         = freq_conn.time;
            freq.freq         = freq_conn.freq;
            freq.dimord       = 'chan_freq_time';
            
            freq.powspctrm    = [];
            freq.label        = {};
            
            i                 = 0;
            
            list_chan_seed    =  1:2;
            list_chan_target  =  1:29;
            
            chan_comb         = [];
            
            for nseed = 1:length(list_chan_seed)
                for ntarget = 1:length(list_chan_target)
                    
                    if list_chan_target(ntarget) ~= list_chan_seed(nseed)
                        
                        if ~isempty(chan_comb)
                            chk1                    =  chan_comb(chan_comb(:,1) ==  list_chan_seed(nseed) &  chan_comb(:,2) ==  list_chan_target(ntarget));
                            chk2                    =  chan_comb(chan_comb(:,2) ==  list_chan_seed(nseed) &  chan_comb(:,1) ==  list_chan_target(ntarget));
                        else
                            chk1                    = [];
                            chk2                    = [];
                        end
                        
                        if isempty(chk1) && isempty(chk2)
                            
                            i                       = i + 1;
                            pow                     = freq_conn.powspctrm(list_chan_seed(nseed),list_chan_target(ntarget),:,:);
                            pow                     = squeeze(pow);
                            
                            freq.powspctrm(i,:,:)   = pow;
                            
                            freq.label{i}           = [freq_conn.label{list_chan_seed(nseed)} ' to ' freq_conn.label{list_chan_target(ntarget)}];
                            
                            freq.label{i}(strfind(freq.label{i},'_')) = ' ';
                            
                            chan_comb(i,1)          = list_chan_seed(nseed);
                            chan_comb(i,2)          = list_chan_target(ntarget);
                        end
                    end
                end
            end
            
            cfg.time_start                          = 0;
            cfg.time_end                            = 0.6;
            cfg.time_step                           = 0.02;
            cfg.time_window                         = cfg.time_step;
            freq                                    = h_smoothTime(cfg,freq);
            
            allsuj_activation{ngroup}{sb,ndis}      = freq;
            
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
    
    cfg.latency             = [-0.1 0.3];
    cfg.frequency           = [60 100];
    
    %     cfg.avgovertime         = 'yes';
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
    
    stat{ngroup}            = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,1},allsuj_activation{ngroup}{:,2});
    
end

for ngroup = 1:size(stat,1)
    [min_p(ngroup),p_val{ngroup}] = h_pValSort(stat{ngroup});
end

p_limit = 0.05;

for ngroup = 1:size(stat,1)
    
    stat_to_plot       = stat{ngroup};
    
    for nchan = 1:length(stat_to_plot.label)
        
        if min(unique(stat_to_plot.prob(nchan,:,:))) < p_limit
            
            stat_to_plot.mask  = stat_to_plot.prob < p_limit;
            
            figure;
            
            if size(stat_to_plot.prob,2) == 1
                
                plot(stat_to_plot.time,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.prob(nchan,:,:)));
                ylim([-0.01 0.01]);
                
            elseif size(stat_to_plot.prob,3) == 1
                
                plot(stat_to_plot.freq,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.prob(nchan,:,:)));
                ylim([-0.01 0.01]);
                
            else
                
                cfg                 = [];
                cfg.channel         = nchan;
                cfg.parameter       = 'stat';
                cfg.maskparameter   = 'mask';
                cfg.maskstyle       = 'outline';
                cfg.zlim            = [-5 5];
                ft_singleplotTFR(cfg,stat_to_plot);
                
            end
            
            title(stat_to_plot.label{nchan},'FontSize',14)
            colormap(redblue)
            
            saveas(gcf,['../images/plv_dis/' stat_to_plot.label{nchan} '.png']) ; close all;
            
        end
    end
end
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue            = {'R1','L1','N1'};
        
        for ncue = 1:length(list_ix_cue)
            
            lst_dis = {'fDIS','DIS'};
            
            for cnd_dis = 1:2
                
                suj                 = suj_list{sb};
                ext_virt            = '.broadAud.1t20Hz.m200p800msCov.waveletPOW.1t20Hz.m2000p2000.MinEvokedAvgTrials.mat';
                fname_in            = ['../data/dis_virt_data/' suj '.' list_ix_cue{ncue} lst_dis{cnd_dis} ext_virt];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in)
                
                if isfield(freq,'check_trialinfo')
                    freq = rmfield(freq,'check_trialinfo');
                end
                
                tmp{cnd_dis}        = freq; clear freq ;
                
            end
            
            allsuj_data{ngroup}{sb,ncue}            = tmp{2} ;
            allsuj_data{ngroup}{sb,ncue}.powspctrm  = (tmp{2}.powspctrm - tmp{1}.powspctrm)./tmp{1}.powspctrm; % tmp{2}.powspctrm - tmp{1}.powspctrm ; % 
            
        end
    end
end

clearvars -except allsuj_* list_ix_cue;


for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t'); clc;
    
    cfg                     = [];
    
    cfg.frequency           = [9 11];
    cfg.latency             = [-0.1 0.7];
    
    cfg.avgoverfreq         = 'yes';
    
    cfg.neighbours          = neighbours;
    cfg.minnbchan           = 0;
    
    cfg.clusterstatistic    = 'maxsum';
    cfg.method              = 'montecarlo';
    cfg.statistic           = 'depsamplesT';
    
    cfg.correctm            = 'cluster';
    
    cfg.clusteralpha        = 0.05;
    cfg.alpha               = 0.025;
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.numrandomization    = 1000;
    cfg.design              = design;
    cfg.uvar                = 1;
    cfg.ivar                = 2;
    
    list_compare            = [1 2; 1 3; 2 3];
    
    for ntest = 1:size(list_compare,1)
        
        stat{ngroup,ntest}  = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1)}, allsuj_data{ngroup}{:,list_compare(ntest,2)});
        
        for nchan = 1:length(stat{ngroup,ntest}.label)
            stat{ngroup,ntest}.label{nchan} = [stat{ngroup,ntest}.label{nchan} '.' list_ix_cue{list_compare(ntest,1)} 'v' list_ix_cue{list_compare(ntest,2)}];
        end
        
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        [min_p(ngroup,ntest), p_val{ngroup,ntest}]      = h_pValSort(stat{ngroup,ntest}) ;
    end
end

i= 0 ;

for ngroup = 1:size(stat,1)
    
    for ntest = 1:size(stat,2)
        
        s2plot                             = stat{ngroup,ntest};
        
        for nchan = 1:length(s2plot.label)
            
            i                               = i + 1;
            plimit                          = 0.05;
            s2plot.mask                     = s2plot.prob < plimit;
            
            subplot(2,3,i);
            
            [x_chan,x_freq,x_time]          = size(s2plot.prob);
            
            if x_freq == 1
                
                data_avg1                   = ft_freqgrandaverage([],allsuj_data{ngroup}{:,list_compare(ntest,1)});
                data_avg1                   = h_freq2avg(data_avg1,[7 13],'avg_over_freq');
                data_avg2                   = ft_freqgrandaverage([],allsuj_data{ngroup}{:,list_compare(ntest,2)});
                data_avg2                   = h_freq2avg(data_avg2,[7 13],'avg_over_freq');
                
                plt_cfg                     = [];
                plt_cfg.channel             = nchan;
                plt_cfg.p_threshold         = plimit;
                plt_cfg.lineWidth           = 3;
                plt_cfg.time_limit          = [-0.2 0.7];
                
                if max(max(data_avg1.avg)) > 1
                    plt_cfg.z_limit         = [-3e+23 3e+23];
                else
                    plt_cfg.z_limit         = [-0.5 0.5]; %
                end
                
                plt_cfg.fontSize            = 18;
                h_plotSingleERFstat_selectChannel(plt_cfg,stat{ngroup,ntest},data_avg1,data_avg2);
                
            else
                
                cfg                             = [];
                cfg.channel                     = nchan;
                cfg.parameter                   = 'stat';
                cfg.maskparameter               = 'mask';
                cfg.maskstyle                   = 'outline';
                cfg.colorbar                    = 'no';
                cfg.zlim                        = [-3 3];
                ft_singleplotTFR(cfg,s2plot);
                colormap(redblue)
                
            end
            
            title([s2plot.label{nchan} ' ' num2str(min(unique(s2plot.prob(nchan,:,:))))]);
            
        end
    end
end


% for ncond = 1:3
%
%     data2plot{ncond}                   = ft_freqgrandaverage([],allsuj_data{1}{:,ncond});
%     data2plot{ncond}                   = h_freq2avg(data2plot{ncond},[7 13],'avg_over_freq');
%
% end
%
% for nchan = 1:2
%     subplot(1,2,nchan)
%     cfg             = [];
%     cfg.ylim        = [-0.5 0.5]; % [-3e+23 3e+23]; %
%     cfg.xlim        = [-0.1 1];
%     cfg.channel     = nchan;
%     ft_singleplotER(cfg,data2plot{:});
%     legend(list_ix_cue)
% end

% plot(s2plot.time,squeeze(s2plot.stat(nchan,:,:) .* s2plot.mask(nchan,:,:)));
% ylim([-5 5])
% if min(unique(s2plot.prob(nchan,:,:))) < plimit
%
%     i = i + 1;
%     figure;
%     subplot(2,4,i);
%     s2plot.mask                    = .mask(nchan,:,:);
%     s2plot.stat                    = stat{ngroup,ntest}.stat(nchan,:,:);
%     s2plot.prob                    = stat{ngroup,ntest}.prob(nchan,:,:);
%     s2plot.freq                    = stat{ngroup,ntest}.freq;
%     s2plot.time                    = stat{ngroup,ntest}.time;
%     s2plot.dimord                  = stat{ngroup,ntest}.dimord;
%     s2plot.label                   = stat{ngroup,ntest}.label(nchan);

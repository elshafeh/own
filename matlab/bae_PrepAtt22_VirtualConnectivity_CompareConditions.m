clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:22);
% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        list_ix_cue         = {'RCnD','LCnD','NCnD','NRCnD','NLCnD'};
        list_method         = {'plvMinEvoked100Slct','coh_absimagMinEvoked100Slct'};
        
        for ncue = 1:length(list_ix_cue)
            for nmethod = 1:length(list_method)
                
                fname_in          = ['../data/' suj '/field/' suj '.' list_ix_cue{ncue} '.broadSchaef.' list_method{nmethod} '.mat'];
                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                list_chan_seed    =  [7 8];
                list_chan_target  =  [9:16 24:30];
                
                freq              = [];
                freq.time         = freq_conn.time;
                freq.freq         = freq_conn.freq;
                freq.dimord       = 'chan_freq_time';
                
                freq.powspctrm    = [];
                freq.label        = {};
                
                i                 = 0;
                
                for nseed = 1:length(list_chan_seed)
                    for ntarget = 1:length(list_chan_target)
                        
                        i                       = i + 1;
                        freq.powspctrm(i,:,:)   = freq_conn.powspctrm(list_chan_seed(nseed),list_chan_target(ntarget),:,:);
                        freq.label{i}           = [list_method{nmethod} '.' freq_conn.label{list_chan_seed(nseed)} '.' freq_conn.label{list_chan_target(ntarget)}];
                        
                    end
                end
                
                
                cfg                                         = [];
                cfg.baseline                                = [-0.6 -0.2];
                cfg.baselinetype                            = 'relchange';
                allsuj_data{ngroup}{sb,ncue,nmethod}        = ft_freqbaseline(cfg,freq);

                clear tmp freq ;
                
            end
        end
    end
end

clearvars -except allsuj_* list_* ;

for ngroup = 1:length(allsuj_data)
    
    nsuj                    = size(allsuj_data{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t'); clc;
    
    cfg                     = [];
    
    cfg.latency             = [0.6 1.1];
    cfg.frequency           = [7 15];
    
    cfg.avgovertime         = 'yes';
    
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
    
    list_compare            = [1 2 ; 1 3 ; 2 3; 1 4; 2 5];
    
    for ntest = 1:size(list_compare,1)
        for nmethod = 1:length(list_method)
            
            stat{ngroup,ntest,nmethod}  = ft_freqstatistics(cfg,allsuj_data{ngroup}{:,list_compare(ntest,1),nmethod}, allsuj_data{ngroup}{:,list_compare(ntest,2),nmethod});
            list_test{ntest}            = [list_ix_cue{list_compare(ntest,1)} 'v' list_ix_cue{list_compare(ntest,2)}];
            
        end
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for nmethod = 1:size(stat,3)
            [min_p(ngroup,ntest,nmethod),p_va{ngroup,ntest,nmethod}] = h_pValSort(stat{ngroup,ntest,nmethod});
        end
    end
end

clear i;
i = 0;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for nmethod = 1:size(stat,3)
            
            stat_to_plot       = stat{ngroup,ntest,nmethod};
            stat_to_plot.mask  = stat_to_plot.prob < 0.2;
            
            for nchan = 1:length(stat_to_plot.label)
                
                check              = stat_to_plot.stat(nchan,:,:) .* stat_to_plot.mask(nchan,:,:);
                dcheck             = squeeze(unique(check));
                
                if length(dcheck) > 1
                    
                    i                  = i + 1;
                    figure;
                    
                    %                     plot(stat_to_plot.time,squeeze(check));
                    %                     xlim([stat_to_plot.time(1) stat_to_plot.time(end)]);
                    %                     ylim([-5 5])
                    
                    plot(stat_to_plot.freq,squeeze(check));
                    xlim([stat_to_plot.freq(1) stat_to_plot.freq(end)]);
                    ylim([-5 5])
                    
                    %                     subplot(6,4,i)
                    %                     cfg                 = [];
                    %                     cfg.channel         = nchan;
                    %                     cfg.parameter       = 'stat';
                    %                     cfg.maskparameter   = 'mask';
                    %                     cfg.maskstyle       = 'outline';
                    %                     cfg.zlim            = [-5 5];
                    %                     ft_singleplotTFR(cfg,stat_to_plot);
                    
                    title([list_test{ntest} '.' stat_to_plot.label{nchan}])
                    colormap('jet')
                    
                    
                end
            end
        end
    end
end
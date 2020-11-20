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
        list_ix_cue         = {'CnD'}; %,'RCnD','LCnD','NCnD'};
        list_method         = {'plvMinEvoked100Slct','cohMinEvoked100Slct'};
        
        for ncue = 1:length(list_ix_cue)
            for nmethod = 1:length(list_method)
                
                fname_in          = ['../data/' suj '/field/' suj '.' list_ix_cue{ncue} '.NewAVSchaef.' list_method{nmethod} '.mat'];
                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                for nchan = 1:length(freq_conn.label)
                    uscore = strfind(freq_conn.label{nchan},'_');
                    
                    if ~isempty(uscore)
                        freq_conn.label{nchan}(uscore) = ' ';
                    end
                    
                end
                
                freq              = [];
                freq.time         = freq_conn.time;
                freq.freq         = freq_conn.freq;
                freq.dimord       = 'chan_freq_time';
                
                freq.powspctrm    = [];
                freq.label        = {};
                
                i                 = 0;
                
                list_chan_seed    =  1:4;
                list_chan_target  =  [1:4 5 8 9 14 15 16]; %1:length(freq_conn.label);
                
                conn_done         = [];
                
                fprintf('Rearranging Connectivity for %s\n',suj);
                
                for nseed = 1:length(list_chan_seed)
                    for ntarget = 1:length(list_chan_target)
                        
                        if list_chan_seed(nseed) ~= list_chan_target(ntarget)
                            
                            if ~isempty(conn_done)
                                
                                check1                  = conn_done(conn_done(:,1) == list_chan_seed(nseed) & conn_done(:,2) == list_chan_target(ntarget),:);
                                check2                  = conn_done(conn_done(:,2) == list_chan_seed(nseed) & conn_done(:,1) == list_chan_target(ntarget),:);
                                
                            else
                                
                                check1                  = [];
                                check2                  = [];
                                
                                
                            end
                            
                            if isempty(check1) && isempty(check2)
                                
                                i                       = i + 1;
                                pow                     = freq_conn.powspctrm(list_chan_seed(nseed),list_chan_target(ntarget),:,:);
                                pow                     = squeeze(pow);
                                
                                freq.powspctrm(i,:,:)   = pow;
                                freq.label{i}           = [list_method{nmethod}(1:3) ' ' freq_conn.label{list_chan_seed(nseed)} ' ' freq_conn.label{list_chan_target(ntarget)}];
                                
                                conn_done(i,1)          = list_chan_seed(nseed);
                                conn_done(i,2)          = list_chan_target(ntarget);
                                
                            end
                        end
                    end
                end
                
                [tmp{1},tmp{2}]                                 = h_prepareBaseline(freq,[-0.6 -0.2],[7 40],[-0.2 1.2],'no');
                allsuj_activation{ngroup}{sb,ncue,nmethod}      = tmp{1};
                allsuj_baselineRep{ngroup}{sb,ncue,nmethod}     = tmp{2};
                
                clear tmp freq ;
                
            end
        end
    end
end

clearvars -except allsuj_* list_ix_cue;

for ngroup = 1:length(allsuj_activation)
    
    nsuj                    = size(allsuj_activation{ngroup},1);
    [design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        for nmethod = 1:size(allsuj_activation{ngroup},3)
            
            cfg                     = [];
            cfg.clusterstatistic    = 'maxsum';
            cfg.method              = 'montecarlo';
            cfg.statistic           = 'depsamplesT';
            cfg.neighbours          = neighbours;
            cfg.correctm            = 'fdr';
            
            cfg.latency             = [0.6 1.1];
            cfg.frequency           = [7 15];
            
            cfg.avgovertime         = 'yes';
            %             cfg.avgoverfreq         = 'yes';

            cfg.clusteralpha        = 0.05;
            cfg.alpha               = 0.025;
            cfg.minnbchan           = 0;
            cfg.tail                = 0;
            cfg.clustertail         = 0;
            cfg.numrandomization    = 1000;
            cfg.design              = design;
            cfg.uvar                = 1;
            cfg.ivar                = 2;
            
            stat{ngroup,ncue,nmethod}      = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue,nmethod},allsuj_baselineRep{ngroup}{:,ncue,nmethod});
            
        end
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for nmethod = 1:size(stat,3)
            [min_p(ngroup,ncue,nmethod),p_va{ngroup,ncue,nmethod}] = h_pValSort(stat{ngroup,ncue,nmethod});
        end
    end
end

clear i;
i = 0;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for nmethod = 1:size(stat,3)
            
            plimit             = 0.05;
            
            stat_to_plot       = stat{ngroup,ncue,nmethod};
            stat_to_plot.mask  = stat_to_plot.prob < plimit;
            
            for nchan = 1:length(stat_to_plot.label)
                
                check              = stat_to_plot.stat(nchan,:,:) .* stat_to_plot.mask(nchan,:,:);
                check              = squeeze(unique(check));
                
                if length(check) > 2
                    
                    i                  = i + 1;
                    
                    %                     figure;
                    
                    subplot(5,6,i)
                    
                    %                     cfg                 = [];
                    %                     cfg.channel         = nchan;
                    %                     cfg.parameter       = 'stat';
                    %                     cfg.maskparameter   = 'mask';
                    %                     cfg.maskstyle       = 'outline';
                    %                     cfg.zlim            = [-5 5];
                    %                     ft_singleplotTFR(cfg,stat_to_plot);
                    %                     list_ix_cue         = {'CnD'};
                    
                    cfg                 = [];
                    cfg.channel         = nchan;
                    cfg.p_threshold     = plimit;
                    cfg.lineWidth       = 2;
                    cfg.x_limit         = [7 15];
                    cfg.z_limit         = [0 0.3];
                    cfg.legend          = {'Act','Bsl'};
                    cfg.avgover         = 'time';
                    cfg.dim_list        = [0.6 1.1];
                    
                    h_plotStatAvgOverDimension(cfg,stat{ngroup,ncue,nmethod},ft_freqgrandaverage([],allsuj_activation{ngroup}{:,ncue,nmethod}), ...
                        ft_freqgrandaverage([],allsuj_baselineRep{ngroup}{:,ncue,nmethod}))
                    
                    title([list_ix_cue{ncue} ' ' stat_to_plot.label{nchan} ' ' round(min(squeeze(stat_to_plot.prob(nchan,:,:))),3)])
                    
                    
                end
            end
        end
    end
end
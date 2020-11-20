clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        list_ix_cue         = {'CnD'}; 
        list_method         = {'plvMinEvoked','cohMinEvoked'};
        
        for ncue = 1:length(list_ix_cue)
            for nmethod = 1:length(list_method)
                
                fname_in          = ['../data/' suj '/field/' suj '.' list_ix_cue{ncue} '.NewAveragedAVSchaef.' list_method{nmethod} '.mat'];
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
                
                list_chan_seed    =  [1 2];
                list_chan_target  =  1:length(freq_conn.label);
                
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
                                freq.label{i}           = [list_ix_cue{ncue} ' ' list_method{nmethod}(1:3) ' ' freq_conn.label{list_chan_seed(nseed)} ' ' freq_conn.label{list_chan_target(ntarget)}];
                                
                                conn_done(i,1)          = list_chan_seed(nseed);
                                conn_done(i,2)          = list_chan_target(ntarget);
                                
                            end
                        end
                    end
                end
                
                cfg                                     = [];
                cfg.baseline                            = [-0.6 -0.2];
                cfg.baselinetype                        = 'relchange';
                allsuj_data{ngroup}{sb,ncue,nmethod}    = ft_freqbaseline(cfg,freq) ; clear freq ;
                
            end
        end
    end
end

clearvars -except allsuj_* list_ix_cue;

nsuj                    = size(allsuj_data{1},1);
[~,neighbours]          = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t'); clc;

for ncue = 1:size(allsuj_data{1},2)
    for nmethod = 1:size(allsuj_data{1},3)
        
        cfg                     = [];
        cfg.statistic           = 'indepsamplesT';
        cfg.method              = 'montecarlo';
        
        cfg.correctm            = 'fdr';
        
        cfg.clusterstatistic    = 'maxsum';
        cfg.clusteralpha        = 0.05;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.alpha               = 0.025;
        cfg.numrandomization    = 1000;
        cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.minnbchan           = 0;
        cfg.neighbours          = neighbours;
        
        cfg.frequency           = [7 11];
        cfg.latency             = [0.6 1];
        
        cfg.avgoverfreq         = 'yes';
        
        stat{ncue,nmethod}      = ft_freqstatistics(cfg, allsuj_data{2}{:,ncue,nmethod},allsuj_data{1}{:,ncue,nmethod});
        
    end
end

for ncue = 1:size(stat,1)
    for nmethod = 1:size(stat,2)
        [min_p(ncue,nmethod),p_val{ncue,nmethod}] = h_pValSort(stat{ncue,nmethod});
    end
end

clear i;
i = 0;

for ncue = 1:size(stat,1)
    for nmethod = 1:size(stat,2)
        
        plimit             = 0.05;
        
        stat_to_plot       = stat{ncue,nmethod};
        stat_to_plot.mask  = stat_to_plot.prob < plimit;
        
        for nchan = 1:length(stat_to_plot.label)
            
            check              = stat_to_plot.stat(nchan,:,:) .* stat_to_plot.mask(nchan,:,:);
            check              = squeeze(unique(check));
            
            if length(check) > 2
                
                figure;
                
                [x,y,z]             = size(stat_to_plot.stat);
                
                if y == 1 || z == 1
                    
                    cfg                 = [];
                    cfg.channel         = nchan;
                    cfg.p_threshold     = plimit;
                    cfg.lineWidth       = 2;
                    cfg.x_limit         = [-0.2 1.2];
                    cfg.z_limit         = [-2 2];
                    cfg.legend          = {'Yung','Old'};
                    cfg.avgover         = 'freq';
                    cfg.dim_list        = [7 11];
                    
                    h_plotStatAvgOverDimension(cfg,stat_to_plot,ft_freqgrandaverage([],allsuj_data{2}{:,ncue,nmethod}), ...
                        ft_freqgrandaverage([],allsuj_data{1}{:,ncue,nmethod}))
                    
                    title(stat_to_plot.label{nchan});
                    
                else
                    
                    cfg                 = [];
                    cfg.channel         = nchan;
                    cfg.parameter       = 'stat';
                    cfg.maskparameter   = 'mask';
                    cfg.maskstyle       = 'outline';
                    cfg.zlim            = [-5 5];
                    ft_singleplotTFR(cfg,stat_to_plot);
                    
                end
            end
        end
    end
end
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_ix_cue    = {''};
        
        for cnd = 1:length(list_ix_cue)
            
            ext_file            = 'waveletPOW.1t120Hz.m1000p1000.10Mstep.AvgTrials.MinEvoked.mat';
            suj                 = suj_list{sb};
            dir_data            = '../data/dis_rep4rev/';
            fname_in            = [dir_data suj '.' list_ix_cue{cnd} 'DIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            allsuj_activation{ngroup}{sb,cnd}   = freq; clear freq ;
            
            fname_in            = [dir_data suj '.' list_ix_cue{cnd} 'fDIS.' ext_file];
            
            fprintf('Loading %s\n',fname_in);
            
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            allsuj_baselineRep{ngroup}{sb,cnd}  = freq; clear freq ;
            
        end
    end
end

clearvars -except allsuj_*;

for ngroup = 1:length(allsuj_baselineRep)
    
    nsuj                        = size(allsuj_activation{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_activation{1}{1},'meg','t'); clc;
    
    for ncue = 1:size(allsuj_activation{ngroup},2)
        
        cfg                     = [];
        cfg.clusterstatistic    = 'maxsum';
        
        %         cfg.avgovertime         = 'yes';
        %         cfg.avgoverfreq         = 'yes';
        
        cfg.frequency           = [3 50];
        
        cfg.latency             = [-0.1 0.35];
        
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'depsamplesT';
        cfg.correctm            = 'cluster';
        cfg.neighbours          = neighbours;
        
        cfg.clusteralpha        = 0.001; %  !!!!
        
        cfg.alpha               = 0.025;
        
        cfg.tail                = 0;    %  !!!!!!!!
        cfg.clustertail         = 0;    %  !!!!!!!!
        
        cfg.numrandomization    = 1000;
        cfg.design              = design;
        cfg.uvar                = 1;
        cfg.ivar                = 2;
        
        cfg.minnbchan           = 4;
        stat{ngroup,ncue}       = ft_freqstatistics(cfg, allsuj_activation{ngroup}{:,ncue},allsuj_baselineRep{ngroup}{:,ncue});
        
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_* stat min_p p_val ;

ix = 0;

list_chan{1}    = {'MLP34', 'MLP42', 'MLP43', 'MLP44', 'MLP55', 'MLP56', 'MLT15', 'MLT16'};

list_chan{2}    = {'MLC12', 'MLC13', 'MLC14', 'MLC21', 'MLC22', 'MLF34', 'MLF43', 'MLF44', 'MLF45',...
    'MLF52', 'MLF53', 'MLF54', 'MLF55', 'MLF61', 'MLF62', 'MLF63', 'MLF64', 'MLF65'};

list_chan{3}    = {'MLC14', 'MLC15', 'MLC16', 'MLC23', 'MLC24', 'MLC25', 'MLC31', 'MLC32', 'MLF46', 'MLF55', ... 
    'MLF56', 'MLF64', 'MLF65', 'MLF66', 'MLF67', 'MLT13', 'MRF14', 'MRF24', 'MRF25', 'MRF34', 'MRF35', ...
    'MRF45', 'MRF46', 'MRF55', 'MRF56', 'MRF65', 'MRT11', 'MRT12', 'MRT21', 'MRT22', 'MRT31', 'MRT32'};

list_freq       = [7 13; 20 30; 3 7]; 

list_title      = {' Alpha 8-14Hz','Beta 20-30Hz','Theta 3-7 Hz'};

ngroup  = 1;
ncue    = 1;

for nfreq = [3 1 2]
    
    plimit                                          = 0.05;
    stat2plot                                       = h_plotStat(stat{ngroup,ncue},0.000000000000000000000000000001,0.05);
    zlimit                                          = [1 1 3];
    
    nwS2plot                                        = stat2plot;
    
    if nfreq < 3
        nwS2plot.powspctrm(nwS2plot.powspctrm>0)    = 0;
        subplot_lim                                 = [-2 0];
    else
        nwS2plot.powspctrm(nwS2plot.powspctrm<0)    = 0;
        subplot_lim                                 = [0 1];
    end
    
    nrow                                            = 1;
    ncol                                            = 3;
    
    ix = ix +1 ;
    subplot(nrow,ncol,ix)
    
    cfg                                             = [];
    cfg.layout                                      = 'CTF275.lay';
    cfg.comment                                     = 'no';
    cfg.colorbar                                    = 'no';
    cfg.ylim                                        = list_freq(nfreq,:);
    cfg.zlim                                        = [-zlimit(nfreq) zlimit(nfreq)];
    cfg.marker                                      = 'off';
    %     cfg.highlight                               = 'off';
    %     cfg.highlightchannel                        =  list_chan{nfreq};
    %     cfg.highlightsymbol                         = '.';
    %     cfg.highlightcolor                          = [0 0 0];
    %     cfg.highlightsize                           = 20;
    %     cfg.highlightfontsize                       = 8;
    ft_topoplotER(cfg,nwS2plot);
    
    %     title(list_title{nfreq});
    %
    %     cfg                                         = [];
    %     cfg.channel                                 = list_chan{nfreq};
    %     cfg.avgoverchan                             = 'yes';
    %     nw_data                                     = ft_selectdata(cfg,nwS2plot);
    %
    %     ix = ix +1 ;
    %     subplot(nrow,ncol,ix)
    %     hold on
    %     plot(nw_data.freq,squeeze(mean(nw_data.powspctrm,3)));
    %     xlim([nw_data.freq(1) nw_data.freq(end)])
    %     ylim(subplot_lim)
    %
    %     ix = ix +1 ;
    %     subplot(nrow,ncol,ix)
    %     hold on
    %     plot(nw_data.time,squeeze(mean(nw_data.powspctrm,2)));
    %     xlim([nw_data.time(1) nw_data.time(end)])
    %     ylim(subplot_lim)
    
end
clear ;

suj_list                         = {'sub001','sub003','sub008','sub009','sub010'};

for ns = 1:length(suj_list)
    
    subjectName                     = suj_list{ns};
    
    fname                           = ['../data/' subjectName '/tf/' subjectName '.firstcuelock.mtmconvol.comb.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg                             = [];
    cfg.baseline                    = [-0.4 -0.2];
    cfg.baselinetype                = 'relchange';
    big_freq                        = freq_comb; % ft_freqbaseline(cfg,freq_comb);
    
    list_n                          = [-0.2 1.5; 1.5 3;3 4.5; 4.5 6];
    %     list_n                          = [3 5 ; 8 10; 12 14; 16 21; 23 27];
    
    for n = 1:size(list_n,1)
        
        cfg                         = [];
        cfg.latency                 = list_n(n,:); % [-0.2 6];
        %         cfg.frequency               = list_n(n,:);
        freq                        = ft_selectdata(cfg,big_freq);
        
        pow                         = freq.powspctrm;
        pow(isnan(pow))             = 0;
        freq.powspctrm              = pow;
        
        alldata{ns,n}               = freq; clear pow freq;
        
    end
    
end

clearvars -except alldata



% list_chan                           = {'all'}; % {'M*O*','M*T*','M*P*','M*C*','M*F*'};

i                                   = 0;
nrow                                = 5;
ncol                                = 2;

for n  = 1:size(alldata,2)
    
    i               = i + 1;
    subplot(nrow,ncol,i)
    
    cfg                                 = [];
    cfg.layout                          = 'CTF275_helmet.mat';
    cfg.marker                          = 'off';
    cfg.comment                         = 'no';
    cfg.colormap                        = brewermap(256, '*PuOr'); % PuBuGn % *RdYlBu
    
    cfg.colorbar                        = 'no';
    cfg.zlim                            = 'maxabs'; % maxabs % minzero % zeromax
    
    ft_topoplotTFR(cfg, ft_freqgrandaverage([],alldata{:,n}));
    
    
    cfg                                 = [];
    cfg.plotsingle                      = 'no';
    cfg.channel                         = 'all';
    
    i               = i + 1;
    subplot(nrow,ncol,i)
    
    %     cfg.xlim                        = [alldata{1,1}.time(1) alldata{1,1}.time(end)];
    %     cfg.avg                         = 'freq';
    %     cfg.vline                       = [0 1.5 3 4.5];
    
    cfg.xlim                        = [3 40]; % [alldata{1,n}.freq(1) alldata{1,n}.freq(end)];
    cfg.avg                         = 'time';
    h_plot_mtm(cfg,alldata(:,n));
    
   
end
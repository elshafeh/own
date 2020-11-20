clear ; clc ;

global ft_default
ft_default.spmversion = 'spm12';

[~,allsuj,~]    = xlsread('../../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{2}    = allsuj(2:15,1);
suj_group{1}    = allsuj(2:15,2);

lst_group       = {'Young','Old'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        ext_name                = 'AV.1t20Hz.M.1t40Hz.m800p2000msCov.waveletPOW.1t20Hz.m3000p3000.AvgTrialsMinEvoked';
        list_ix                 = 'CnD';
        
        fname_in                = ['../../data/ageing_data/' suj '.' list_ix '.' ext_name '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                     = [];
        cfg.baseline            = [-0.6 -0.2];
        cfg.baselinetype        = 'relchange';
        freq                    = ft_freqbaseline(cfg,freq);
        
        list_iaf                = ageingrev_infunc_iaf(freq);
        
        allsuj_data{sb,ngroup}  = ageingrev_infunc_adjustiaf(freq,list_iaf,0);
        
        clear freq list_iaf;
        
    end
end

nsubj                   = 14;
[~,neighbours]          = h_create_design_neighbours(nsubj,allsuj_data{1},'virt','t'); clc;

cfg                     = [];
cfg.statistic           = 'indepsamplesT';
cfg.method              = 'montecarlo'; 

cfg.correctm            = 'bonferroni'; 

cfg.clusterstatistic    = 'maxsum';

cfg.clusteralpha        = 0.05;
cfg.tail                = 0; 
cfg.clustertail         = 0;
cfg.alpha               = 0.025; 
cfg.numrandomization    = 1000;

cfg.design              = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.minnbchan           = 0;
cfg.neighbours          = neighbours;

cfg.latency             = [0.6 1];

stat                    = ft_timelockstatistics(cfg,allsuj_data{:,1}, allsuj_data{:,2});

[min_p,p_val]           = h_pValSort(stat);

figure;
i = 0 ;

for nchan = 1:length(stat.label)
    
    i                               = i + 1 ;
    
    plimit                          = 0.05;
    s2plot                          = stat;
    s2plot.mask                     = s2plot.prob < plimit;
    
    subplot_row                     = 3;
    subplot_col                     = 2;
    
    cfg                             = [];
    cfg.channel                     = nchan;
    cfg.p_threshold                 = plimit;
    cfg.lineWidth                   = 2;
    cfg.time_limit                  = [0 1.2];
    cfg.z_limit                     = [-0.35 0.35];
    
    cfg.legend                      = {'Old','Young'};
    
    subplot(subplot_row,subplot_col,i)
    
    h_plotSingleERFstat_selectChannel(cfg,s2plot,ft_timelockgrandaverage([],allsuj_data{:,1}), ...
        ft_timelockgrandaverage([],allsuj_data{:,2}));
    
    title([s2plot.label{nchan}],'FontSize',14)
    
end

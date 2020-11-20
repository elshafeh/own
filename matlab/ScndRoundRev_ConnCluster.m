clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);


for sb = 1:21
    
    suj                     = suj_list{sb};
    list_cond               = {'DIS','fDIS'};
    
    for ncond = 1:length(list_cond)
        
        vrible              = 'mgranger';
        fname               = ['../../data/scnd_round/' suj '.' list_cond{ncond} '.AudTPFC.1t120Hz.m200p800msCov.' vrible '.averaged.mat'];

        fprintf('Loading %20s\n',fname); load(fname);

        if strcmp(vrible,'mpdc')
            data                = mpdc;
            data_matrx          = 5.*log((1+mpdc.pdcspctrm)./(1-mpdc.pdcspctrm));
        else
            data                = mgranger;
            data_matrx          = 5.*log((1+mgranger.grangerspctrm)./(1-mgranger.grangerspctrm));
        end
        
        conn_label          = {};
        
        ilu                 = 0;
        
        conn_matrx           = [];
        
        for seed = 1:length(data.label)
            for target = 1:length(data.label)
                
                if seed ~= target
                    
                    ilu                 = ilu + 1;
                    
                    grng                = squeeze(data_matrx(seed,target,:));
                    
                    conn_label{ilu}     = [data.label{seed} ' t ' data.label{target}]; % ['ch' num2str(seed) 'tch' num2str(target)];
                    conn_matrx(ilu,:)   = grng'; clear grng;
                    
                end
            end
        end
        
        allsuj_data{sb,ncond}           = [];
        allsuj_data{sb,ncond}.avg       = conn_matrx;
        allsuj_data{sb,ncond}.time      = data.freq;
        allsuj_data{sb,ncond}.label     = conn_label;
        allsuj_data{sb,ncond}.dimord    = 'chan_time';
        
        clear conn_*
        
    end
end

clearvars -except allsuj_data;


nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t');

cfg                     = [];
cfg.latency             = [40 110];
cfg.design              = design;
cfg.neighbours          = neighbours;
cfg.statistic           = 'ft_statfun_depsamplesT';
cfg.method              = 'montecarlo';
cfg.correctm            = 'cluster';
cfg.clusteralpha        = 0.05;
cfg.clusterstatistic    = 'maxsum';
cfg.minnbchan           = 0;
cfg.tail                = 0;
cfg.clustertail         = 0;
cfg.alpha               = 0.025;
cfg.numrandomization    = 1000;
cfg.uvar                = 1;
cfg.ivar                = 2;

stat                    = ft_timelockstatistics(cfg, allsuj_data{:,1}, allsuj_data{:,2});

[min_p,p_val]           = h_pValSort(stat);

stat.mask               = stat.prob < 0.1;

i                       = 0;

stat_to_plot            = [];
stat_to_plot.time       = stat.time;
stat_to_plot.label      = stat.label;
stat_to_plot.avg        = stat.stat .* stat.mask;
stat_to_plot.dimord     = 'chan_time';

for nchan = 1:length(stat_to_plot.label)
    
    i                  = i + 1;
    
    subplot(4,3,i)
    cfg                 = [];
    cfg.channel         = nchan;
    cfg.ylim            = [0 5];
    ft_singleplotER(cfg,stat_to_plot);
    
end
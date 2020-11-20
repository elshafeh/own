clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

list_measure    = {'cohimag','wpli_debiased'};
list_cue        = {'RCnD','LCnD','NCnD'};
list_time       = {'m600m200','p600p1000'};

for nmes = 1:length(list_measure)
    for ncue = 1:length(list_cue)
        
        suj_list            = [1:4 8:17] ;
        
        for sb = 1:length(suj_list)
            
            suj             = ['yc' num2str(suj_list(sb))] ;
            
            for ntime = 1:length(list_time)
                
                fname       = ['../data/conn/' suj '.' list_cue{ncue} '.PaperAudVisTD.1t20Hz.m800p2000msCov.' list_measure{nmes} '.' list_time{ntime} '.mat'];
                load(fname);
                fprintf('Loading %s\n',fname);
                
                template    = h_conn2freq(freq_con);
                
                data_mat    = freq_con.connspctrm;
                data_matZ   = data_mat;% .5.*log((1+data_mat)./(1-data_mat));
                
                tmp{ntime}  = data_matZ; clear data_matZ data_mat;
                
            end
            
            allsuj_data{sb,nmes,ncue}               = template;
            allsuj_data{sb,nmes,ncue}.powspctrm     = (tmp{2}-tmp{1}); clear tmp;
            
        end
        
        
        
    end
end

clearvars -except allsuj_data list_*;

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

cfg                     = [];
cfg.neighbours          = neighbours;
cfg.frequency           = [5 15];
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

istat                   = 0;
list_test               = {};

for nmes = 1:size(allsuj_data,2)
    for ntest = 1:size(list_compare,1)
        
        istat               = istat + 1;
        
        ix1                 = list_compare(ntest,1);
        ix2                 = list_compare(ntest,2);
        
        stat{istat}         = ft_freqstatistics(cfg,allsuj_data{:,nmes,ix1}, allsuj_data{:,nmes,ix2});
        list_test{istat}    = [list_measure{nmes} ' ' list_cue{ix1} ' ' list_cue{ix2}];
        
    end
end

clearvars -except allsuj_data list_* stat;

for istat = 1:length(stat)
    
    [list_min_p(istat),list_p_val{istat}]   = h_pValSort(stat{istat});
    
    p_limit         = 0.1;
    
    if list_min_p(istat) < p_limit
        
        figure;
        
        con2plot        = h_stat2conn(stat{istat},p_limit);
        
        cfg             = [];
        cfg.parameter   = 'cohspctrm';
        cfg.zlim        = [-5 5];
        ft_connectivityplot(cfg,con2plot);
        
        title(list_test{istat})
        
    end
end

clearvars -except allsuj_data list_* stat;
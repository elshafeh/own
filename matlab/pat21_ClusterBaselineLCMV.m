clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    ext_comp = 'lcmvSource';
    
    %     lst_time = {'fDIS.p75p140ms','DIS.p75p140ms'};
    %     lst_time = {'fDIS.p150p280ms','DIS.p150p280ms'};
    %     lst_time = {'fDIS.p290p350ms','DIS.p290p350ms'};
    
    %     lst_time = {'nDT.m120m0ms','nDT.p50p169ms'};
    
    %     lst_time = {'nDT.m70m0ms','nDT.p190p260ms'};
    lst_time = {'nDT.m200m0ms','nDT.p300p500ms'};
    
    for ntime = 1:2
        
        source_carr = [];
        
        for prt = 1:3
            
            fname = dir(['../data/source/' suj '.pt' num2str(prt) '.' lst_time{ntime} '.' ext_comp '.mat']);
            
            fname = fname.name;
            fprintf('\nLoading %50s',fname);
            load(['../data/source/' fname]);
            
            source_carr = [source_carr source] ; clear source
            
        end
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        source_avg{sb,ntime}.pow            = nanmean(source_carr,2); clear source_carr ;
        source_avg{sb,ntime}.pos            = source.pos ;
        source_avg{sb,ntime}.dim            = source.dim ;
        
        clear source
        
    end
end

name_test   = lst_time{ntime};

clearvars -except source_avg name_test

cfg                                                     =   [];
cfg.dim                                                 =   source_avg{1,1}.dim;
cfg.method                                              =   'montecarlo';cfg.statistic                                           =   'depsamplesT';cfg.parameter                                           =   'pow';
cfg.correctm                                            =   'cluster';
cfg.clusterstatistic                                    =   'maxsum';cfg.numrandomization                                    =   1000;
cfg.alpha                                               =   0.025;cfg.tail                                                =   0;cfg.clustertail                                         =   0;
cfg.design(1,:)                                         =   [1:14 1:14];
cfg.design(2,:)                                         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                                                =   1;cfg.ivar                                                =   2;

p_val_list                                              = [0.05; 0.01;0.005;0.001;0.0005];

for p = 1:length(p_val_list)
    cfg.clusteralpha                                    = p_val_list(p);             % First Threshold
    stat{p}                                             = ft_sourcestatistics(cfg, source_avg{:,2},source_avg{:,1});
    stat{p}                                             = rmfield(stat{p},'cfg');
end

save(['../data/yctot/stat/' name_test '.lcmv.0p05.0p01.0p005.0p001.0p0005.mat'],'stat');
clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    lst_freq = {'12t14Hz.p400p700', ...
        '8t10Hz.p400p700'};
    
    %     lst_freq = {'8t10Hz','11t15Hz','9t15Hz'};
    
    for cnd_freq = 1:length(lst_freq)
        
        suj = ['yc' num2str(suj_list(sb))];
        
        ext_comp = 'dics';
        
        lst_time = {'fDIS','DIS'};
        %         lst_time = {'m500m200','p300p600'};
        
        for cnd = 1:2
            
            source_carr = [];
            
            for prt = 1:3
                
                fname = dir(['../data/source/' suj '*pt' num2str(prt) '.' lst_time{cnd} '.' lst_freq{cnd_freq} '.' ext_comp '*']);
                
                %                 fname = dir(['../data/source/' suj '*pt' num2str(prt) '.nDT.' lst_freq{cnd_freq} '.' ...
                %                     lst_time{cnd} '.' ext_comp '*']);
                
                fname = fname.name;
                fprintf('\nLoading %50s',fname);
                load(['../data/source/' fname]);
                
                source_carr = [source_carr source] ; clear source
                
            end
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            source_avg{sb,cnd_freq,cnd}.pow            = nanmean(source_carr,2); clear source_carr ;
            source_avg{sb,cnd_freq,cnd}.pos            = source.pos ;
            source_avg{sb,cnd_freq,cnd}.dim            = source.dim ;
            
            clear source
            
        end
        
    end
    
    
    
end

clearvars -except source_avg

for cnd_freq = 1:size(source_avg,2)
    cfg                                                     =   [];
    cfg.dim                                                 =   source_avg{1,1}.dim;
    cfg.method                                              =   'montecarlo';
    cfg.statistic                                           =   'depsamplesT';
    cfg.parameter                                           =   'pow';
    cfg.correctm                                            =   'cluster';
    cfg.clusteralpha                                        =   0.05;             % First Threshold
    cfg.clusterstatistic                                    =   'maxsum';
    cfg.numrandomization                                    =   1000;
    cfg.alpha                                               =   0.025;
    cfg.tail                                                =   0;
    cfg.clustertail                                         =   0;
    cfg.design(1,:)                                         =   [1:14 1:14];
    cfg.design(2,:)                                         =   [ones(1,14) ones(1,14)*2];
    cfg.uvar                                                =   1;
    cfg.ivar                                                =   2;
    stat{cnd_freq}            = ft_sourcestatistics(cfg, source_avg{:,cnd_freq,2}, ...
        source_avg{:,cnd_freq,1});
    stat{cnd_freq}                     = rmfield(stat{cnd_freq},'cfg');
end

clearvars -except stat

for cnd_freq = 1%:length(stat)
    [min_p(cnd_freq),p_val{cnd_freq}]     = h_pValSort(stat{cnd_freq});
    list{cnd_freq}            = FindSigClusters(stat{cnd_freq},0.05);
end

clearvars -except stat min_p p_val source_avg list

for cnd_freq = 1:length(stat)
    
    stat_int{cnd_freq}      = h_interpolate(stat{cnd_freq});
    stat_int{cnd_freq}.mask = stat_int{cnd_freq}.prob < 0.05;
    stat_int{cnd_freq}.stat = stat_int{cnd_freq}.stat .* stat_int{cnd_freq}.mask;
    
    cfg                         = [];
    cfg.method                  = 'slice';
    cfg.funparameter            = 'stat';
    cfg.maskparameter           = 'mask';
    cfg.nslices                 = 16;
    cfg.slicerange              = [70 84];
    cfg.funcolorlim             = [-5 5];
    ft_sourceplot(cfg,stat_int{cnd_freq});clc;
    
    clear source source_int cfg
    
end
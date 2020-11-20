clear ; clc ; close all ; dleiftrip_addpath;

suj_list = [1:4 8:17];

for cnd_freq = 1:3
    
    lst_freq = {'4t6Hz','9t13Hz','30t40Hz'};
    
    for cnd_cue = 1:3
        for sb = 1:length(suj_list)
            
            suj         = ['yc' num2str(suj_list(sb))];
            ext_comp    = 'dics';
            
            lst_time    = {{'m500m200','p100p400'},{'m500m200','p100p400'},...
                {'m400m200','p100p300'}};
            
            %             lst_time    = {{'m1700m1400','p100p400'},{'m1700m1400','p100p400'},...
            %                 {'m1600m1400','p100p300'}};
            
            list_cue    = {'RnDT','LnDT','NnDT'};
            
            source_carr = [];
            
            for prt = 1:3
                for cnd_time = 1:2
                    
                    fname = dir(['../data/source/' suj '.*pt' num2str(prt) '*' ...
                        list_cue{cnd_cue} '*' lst_freq{cnd_freq} '*' ...
                        lst_time{cnd_freq}{cnd_time} '*' ext_comp '*']);
                    
                    fname = fname.name;
                    fprintf('\nLoading %50s',fname);
                    load(['../data/source/' fname]);
                    
                    source_tmp{cnd_time}  = source ; clear source
                    
                end
                avg              = (source_tmp{2} - source_tmp{1}) ./ (source_tmp{1});
                clear source_tmp ; 
                source_carr = [source_carr avg];
                clear avg ;
                
            end
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            source_avg{sb,cnd_freq,cnd_cue}.pow            = nanmean(source_carr,2);
            clear source_carr ;
            source_avg{sb,cnd_freq,cnd_cue}.pos            = source.pos ;
            source_avg{sb,cnd_freq,cnd_cue}.dim            = source.dim ;
            
            clear source ;
        end
        
    end
end

clearvars -except source_avg

cnd_stat = [1 2; 1 3; 2 3];

for cf = 1:3
    for cs = 1:3
        
        cfg                                                     =   [];
        cfg.dim                                                 =   source_avg{1,1}.dim;
        cfg.method                                              =   'montecarlo';
        cfg.statistic                                           =   'depsamplesT';
        cfg.parameter                                           =   'pow';
        cfg.correctm                                            =   'cluster';
        cfg.clusteralpha                                        =   0.025;             % First Threshold
        cfg.clusterstatistic                                    =   'maxsum';
        cfg.numrandomization                                    =   1000;
        cfg.alpha                                               =   0.025;
        cfg.tail                                                =   0;
        cfg.clustertail                                         =   0;
        cfg.design(1,:)                                         =   [1:14 1:14];
        cfg.design(2,:)                                         =   [ones(1,14) ones(1,14)*2];
        cfg.uvar                                                =   1;
        cfg.ivar                                                =   2;
        stat{cf,cs}            = ft_sourcestatistics(cfg, source_avg{:,cf,cnd_stat(cs,1)}, ...
            source_avg{:,cf,cnd_stat(cs,2)});
        stat{cf,cs}                     = rmfield(stat{cf,cs},'cfg');
        [min_p(cf,cs),p_val{cf,cs}]     = h_pValSort(stat{cf,cs});
    end
end

clearvars -except stat min_p p_val source_avg

lst_f = {'theta','alpha','low gamma'};
lst_s = {'RL','RN','LN'};

for cf = 1:3
    for cs = 1:3
        
        p_lim = 0.2;
        
        if min_p(cf,cs) < p_lim
            
            stat_int{cf,cs}      = h_interpolate(stat{cf,cs});
            stat_int{cf,cs}.mask = stat_int{cf,cs}.prob < p_lim;
            stat_int{cf,cs}.stat = stat_int{cf,cs}.stat .* stat_int{cf,cs}.mask;
            
            cfg                         = [];
            cfg.method                  = 'slice';
            cfg.funparameter            = 'stat';
            cfg.maskparameter           = 'mask';
            %         cfg.nslices                 = 16;
            %         cfg.slicerange              = [70 84];
            cfg.funcolorlim             = [-3 3];
            ft_sourceplot(cfg,stat_int{cf,cs});clc;
            title([lst_f{cf} ':' lst_s{cs}])
        end
    end
end

for cf = 1:3
    for cs = 1:3
        p_lim = 0.2;
        if min_p(cf,cs) < p_lim
            list{cf,cs}            = FindSigClusters(stat{cf,cs},p_lim);
        end
    end
end
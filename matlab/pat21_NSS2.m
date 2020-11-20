clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

for cnd_freq = 1:4
    
    lst_freq = {'55t65Hz','35t45Hz','8t14Hz','5t7Hz'};
    %     lst_freq = {'80t90Hz','30t40Hz','3t7Hz','8t12Hz'};
    
    for cnd_cue = 1:3
        
        for sb = 1:length(suj_list)
            
            suj         = ['yc' num2str(suj_list(sb))];
            ext_comp    = 'dics';
            
            lst_time    = {'p100p200','p100p300','p300p700','p300p700'};
            %             lst_time    = {'p200p400','p0p200','p300p600','p300p600'};
            
            list_cue    = {'1','2','3'};
            %             list_cue    = {'R','L','N'};
            list_dis    = {'DIS','fDIS'};
            
            source_carr = [];
            
            for prt = 1:3
                
                for cnd_dis = 1:2
                    
                    fname = dir(['../data/source/' suj '.*pt' num2str(prt) '*' ...
                        '*' list_dis{cnd_dis} list_cue{cnd_cue} '*' lst_freq{cnd_freq} '*' ...
                        lst_time{cnd_freq} '*' ext_comp '*']);
                    
                    %                     fname = dir(['../data/source/' suj '.*pt' num2str(prt) '*' ...
                    %                         list_cue{cnd_cue} list_dis{cnd_dis} '*' lst_freq{cnd_freq} '*' ...
                    %                         lst_time{cnd_freq} '*' ext_comp '*']);
                    
                    fname = fname.name;
                    fprintf('\nLoading %50s',fname);
                    load(['../data/source/' fname]);
                    
                    source_tmp{cnd_dis}  = source ; clear source
                    
                end
                
                avg              = source_tmp{1} - source_tmp{2};
                clear source_tmp ;
                source_carr      = [source_carr avg];
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

for cf = 1:size(source_avg,2)
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

lst_f = {'55t65Hz','35t45Hz','8t14Hz','5t7Hz'};
lst_s = {'1v2','1v3','2v3'};
% lst_s = {'RvL','RvN','LvN'};

close all ;
for cf = 1:size(source_avg,2)
    for cs = 1:3
        
        p_lim = 0.1;
        
        if min_p(cf,cs) < p_lim
            
            %             stat_int{cf,cs}      = h_interpolate(stat{cf,cs});
            stat_int{cf,cs}.mask = stat_int{cf,cs}.prob < p_lim;
            stat_int{cf,cs}.stat = stat_int{cf,cs}.stat .* stat_int{cf,cs}.mask;
            
            cfg                         = [];
            cfg.method                  = 'slice';
            cfg.funparameter            = 'stat';
            cfg.maskparameter           = 'mask';
            cfg.nslices                 = 16;
            cfg.slicerange              = [70 84];
            cfg.funcolorlim             = [-4 4];
            ft_sourceplot(cfg,stat_int{cf,cs});clc;
            title([lst_f{cf} ':' lst_s{cs} ' p = ' num2str(round(min_p(cf,cs),4))])
        end
    end
end

for cf = 1:size(source_avg,2)
    for cs = 1:3
        if min_p(cf,cs) < p_lim
            list{cf,cs} = FindSigClusters(stat{cf,cs},p_lim);
        end
    end
end
for c_cue = 1:3 % conditions
    
    for c_time = 1:3 % time
        
        for c_freq = 1:4 % frequency 
            
            suj_list = [1:4 8:17];
            
            load ../data/yc1/headfield/yc1.VolGrid.1cm.mat
            
            list_cnd    = {'RL','RN','LN'} ;
            ext_comp    = 'bsl';
            list_time   = {{'.m600m200','.m600m200','.m600m200'},{'.p200p600','.p600p1000','.p1400p1800'}};
            list_freq   = {'8t10','7t11','12t14','11t15'} ;
            
            for sb = 1:length(suj_list)
                
                suj = ['yc' num2str(suj_list(sb))];
                
                for idx_cnd = 1:2
                    
                    for pt = 1:3
                        
                        for p_interest = 1:2
                            
                            fname = dir(['../data/' suj '/source/*pt' num2str(pt) '*' list_cnd{c_cue}(idx_cnd) 'CnD*' list_freq{c_freq} '*' list_time{p_interest}{c_time} '*' ext_comp '*']);
                            fname = fname.name;
                            fprintf('Loading %50s\n',fname);
                            load(['../data/' suj '/source/' fname]);
                            
                            tmp{p_interest} = source ; clear source ;
                            
                        end
                        
                        cfg             = [];
                        cfg.parameter   = 'avg.pow';
                        cfg.operation   = '((x1-x2)./x2)*100';
                        source_carr{pt}  = ft_math(cfg,tmp{2},tmp{1});
                        
                        clear tmp
                        
                    end
                    
                    source_avg{sb,idx_cnd}     = ft_sourcegrandaverage([],source_carr{:});
                    source_avg{sb,idx_cnd}.pos = grid.MNI_pos;
                    source_avg{sb,idx_cnd}.cfg = [];
                    
                    clear source_carr
                    
                end
                
            end
            
            clearvars -except source_avg ix iy iz pval_carr stat_carr
            
            cfg                     =   [];
            cfg.inputcoord          =   'mni';
            cfg.dim                 =   source_avg{1,1}.dim;
            cfg.method              =   'montecarlo';
            cfg.statistic           =   'depsamplesT';
            cfg.parameter           =   'pow';cfg.correctm            =   'cluster';
            cfg.clusteralpha        =   0.05;             % First Threshold
            cfg.clusterstatistic    =   'maxsum';
            cfg.numrandomization    =   1000;cfg.alpha               =   0.05;
            cfg.tail                =   0;
            cfg.clustertail         =   0;
            cfg.design(1,:)         =   [1:14 1:14];
            cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
            cfg.uvar                =   1;
            cfg.ivar                =   2;
            stat                    = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;p_val_sort;
            
        end
        
    end
end
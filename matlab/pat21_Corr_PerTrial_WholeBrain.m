clear ; clc ; dleiftrip_addpath ;

ix_f = 0 ;

for ext_freq = {'7t111Hz','11t15Hz'};
    
    for cnd_filt = {'SingleTrial.NewDpss.'};
        
        ix_f = ix_f + 1;
        
        for sb = 1:14
            
            suj_list = [1:4 8:17];
            
            suj = ['yc' num2str(suj_list(sb))];
            
            sourceAppend = [];
            
                list_time = {'m600m200','p700p1100'};
            else
                list_time = {'bsl','actv'};
            end
            
            for prt = 1:3
                
                for cnd = 2 % 1:2
                    
                    fname = dir(['../data/' suj '/source/*.pt' num2str(prt) ...
                        '*.CnD.*' ext_freq{:} '*' list_time{cnd} ...
                        '*' cnd_filt{:} '*mat']);
                    
                    fname = fname.name;
                    
                    fprintf('Loading %50s\n',fname);
                    
                    load(['../data/' suj '/source/' fname]);
                    
                    %                     source_carr{cnd} = source ; clear source ;
                    %                     sourceAppend{cnd} = [ sourceAppend{cnd}  source]; clear source ;
                    
                    sourceAppend = [sourceAppend source ]; clear source ;
                    
                end
                
                %                 relchange = (source_carr{2} - source_carr{1}) ./ source_carr{1};
                
                clear relchange sourc_carr
                
            end
            
            %             tmp = sourceAppend ;
            
            %             sourceAppend = (tmp{2} - tmp{1}) ./ tmp{1} ; clear tmp
            
            load ../data/yctot/rt/rt_CnD_adapt.mat
            
            fprintf('Calculating Correlation\n');
            
            [rho,p]                             = corr(sourceAppend',rt_all{sb} , 'type', 'Spearman');
            
            %             rho_mask                            = p < 0.05 ;
            %             rho                                 = rho .* rho_mask ;
            
            rhoF                                = .5.*log((1+rho)./(1-rho));
            
            source_avg{sb,1,ix_f}.pow                   = rhoF;             % act
            source_avg{sb,2,ix_f}.pow(length(rho),1)    = 0;                % bsl
            
            clear rho rhoF
            
            fprintf('Done\n');
            
            clear sourceAppend v
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            for b = 1:2
                source_avg{sb,b,ix_f}.pos    = source.pos;
                source_avg{sb,b,ix_f}.dim    = source.dim;
                source_avg{sb,b,ix_f}.inside = source.inside;
            end
            
        end
        
        cfg                     =   [];
        cfg.dim                 =   source_avg{1,1}.dim;
        cfg.method              =   'montecarlo';
        cfg.statistic           =   'depsamplesT';
        cfg.parameter           =   'pow';
        cfg.correctm            =   'cluster';
        cfg.clusteralpha        =   0.05;             % First Threshold
        cfg.clusterstatistic    =   'maxsum';
        cfg.numrandomization    =   1000;
        cfg.alpha               =   0.025;
        cfg.tail                =   0;
        cfg.clustertail         =   0;
        nsuj                    =   size(source_avg,1);
        cfg.design(1,:)         =   [1:nsuj 1:nsuj];
        cfg.design(2,:)         =   [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.uvar                =   1;
        cfg.ivar                =   2;
        stat{ix_f}              = ft_sourcestatistics(cfg,source_avg{:,1,ix_f},source_avg{:,2,ix_f});
        
        stat{ix_f}.cfg = [];
        
        [min_p(ix_f),p_val{ix_f}] = h_pValSort(stat{ix_f});
        
        clearvars -except ext_freq stat ix_f stat stat_int source_avg min_p p_val
        
    end
    
    clear cfg
    
end

for ix_f = 1:3
    
    stat_int{ix_f}          = h_interpolate(stat{ix_f});
    stat_int{ix_f}.cfg      = [];
    stat_int{ix_f}.mask     = stat_int{ix_f}.prob < 0.07;
    
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'stat';
    cfg.maskparameter       = 'mask';
    %     cfg.nslices             = 16;
    %     cfg.slicerange          = [70 84];
    cfg.funcolorlim         = [-3 3];
    ft_sourceplot(cfg,stat_int{ix_f});clc;
    
end

for f = 1:3
    vox_list{f} = FindSigClusters(stat{f},0.1);clc;
end

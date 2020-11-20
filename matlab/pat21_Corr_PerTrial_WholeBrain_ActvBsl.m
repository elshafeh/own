clear ; clc ; dleiftrip_addpath;

frq_list  = {'7t9Hz','8t10Hz','10t14Hz','11t15Hz','13t15'};
filt_list = {'pcc.Fixed.'};

for ext_freq = 1:length(frq_list)
    
    for cnd_filt = 1:length(filt_list)
        
        for sb = 1:14
            
            suj_list = [1:4 8:17];
            
            suj = ['yc' num2str(suj_list(sb))];
            
            
            for cnd = 1:2
                
                sourceAppend{cnd} = [];
                
                for prt = 1:3
                    
                    if strcmp(frq_list{ext_freq},'11t15Hz') || strcmp(frq_list{ext_freq},'13t15')
                        list_time =  {'bsl','actv'}; 
                    else
                        list_time = {'m400m200','p900p1100'} ;
                    end
                    
                    
                    fname = dir(['../data/' suj '/source/*.pt' num2str(prt) ...
                        '*.CnD.*' frq_list{ext_freq} '*' list_time{cnd} ...
                        '*' filt_list{cnd_filt} '*mat']);
                    
                    fname = fname.name;
                    
                    fprintf('Loading %50s\n',fname);
                    
                    load(['../data/' suj '/source/' fname]);
                    
                    sourceAppend{cnd} = [ sourceAppend{cnd} source]; clear source ;
                    
                end
                
                load ../data/yctot/rt/rt_CnD_adapt.mat
                fprintf('Calculating Correlation\n');
                
                [rho,p]                             = corr(sourceAppend{cnd}',rt_all{sb} , 'type', 'Spearman');
                
                rho_mask    = p < 0.05 ;
                
                rhoM        = rho .* rho_mask ;
                
                rhoF        = .5.*log((1+rho)./(1-rho));
                rhoMF       = .5.*log((1+rhoM)./(1-rhoM));
                
                source_avg{sb,cnd,ext_freq,cnd_filt,1}.pow      = rhoF;             % act
                source_avg{sb,cnd,ext_freq,cnd_filt,2}.pow      = rhoMF;            % act
                
                clear rho*
                
                fprintf('Done\n');
                
                
                load ../data/template/source_struct_template_MNIpos.mat
                
                for b = 1:2
                    source_avg{sb,cnd,ext_freq,cnd_filt,b}.pos    = source.pos;
                    source_avg{sb,cnd,ext_freq,cnd_filt,b}.dim    = source.dim;
                    source_avg{sb,cnd,ext_freq,cnd_filt,b}.inside = source.inside;
                end
                
                
                
            end
            
            clear sourceAppend v
            
        end
        
    end
    
    clear cfg
    
end

clearvars -except source_avg

for ix_freq = 1:size(source_avg,3)
    for ix_filt = 1:size(source_avg,4)
        for ix_m = 1:size(source_avg,5)
            
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
            stat{ix_freq,ix_filt,ix_m}         =   ft_sourcestatistics(cfg,source_avg{:,2,ix_freq,ix_filt,ix_m},source_avg{:,1,ix_freq,ix_filt,ix_m});
            stat{ix_freq,ix_filt,ix_m}.cfg     =   [];
            
            
        end
    end
end

for ix_freq = 1:size(source_avg,3)
    for ix_filt = 1:size(source_avg,4)
        for ix_m = 1:size(source_avg,5)
            [min_p(ix_freq,ix_filt,ix_m),p_val{ix_freq,ix_filt,ix_m}]   = h_pValSort(stat{ix_freq,ix_filt,ix_m});
        end
    end
end

for ix_freq = 1:size(source_avg,3)
    for ix_filt = 1:size(source_avg,4)
        for ix_m = 1:size(source_avg,5)
            vox_list{ix_freq,ix_filt,ix_m} = FindSigClusters(stat{ix_freq,ix_filt,ix_m},0.07);
        end
    end
end

% frq_list    = {'11t15Hz','13t15'};
% filt_list   = {'pcc.Fixed','pcc.FixedAvg'};
% mask_list   = {'unmasked','masked'};

for ix_freq = 1:size(source_avg,3)
    for ix_filt = 1:size(source_avg,4)
        for ix_m = 1%:size(source_avg,5)
            
            stat_int{ix_freq,ix_filt,ix_m}          = h_interpolate(stat{ix_freq,ix_filt,ix_m});
            stat_int{ix_freq,ix_filt,ix_m}.cfg      = [];
            stat_int{ix_freq,ix_filt,ix_m}.mask     = stat_int{ix_freq,ix_filt,ix_m}.prob < 0.07;
            
            cfg                     = [];
            cfg.method              = 'slice';
            cfg.funparameter        = 'stat';
            cfg.maskparameter       = 'mask';
            %     cfg.nslices             = 16;
            %     cfg.slicerange          = [70 84];
            cfg.funcolorlim         = [-3 3];
            ft_sourceplot(cfg,stat_int{ix_freq,ix_filt,ix_m});clc;
            
            %             title([frq_list{ix_freq} '.' filt_list{ix_filt} '.' mask_list{ix_m}])
        end
    end
end
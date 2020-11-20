clear ; clc ; dleiftrip_addpath;

for ext_freq = 1:5
    
    frq_list  = {'7t9Hz','8t10Hz','10t14Hz','11t15Hz','13t15'};
    filt_list = {'pcc.Fixed.'};
    
    for cnd_filt = 1:length(filt_list)
        
        for sb = 1:14
            
            suj_list = [1:4 8:17];
            
            suj = ['yc' num2str(suj_list(sb))];
            
            sourceAppend = []; 
            
            for prt = 1:3
            
                for cnd = 2
                    
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
                
                    sourceAppend = [sourceAppend source];
                    
                    clear source ;
                    
                end
         
            end
            
            clear tmp
            
            
            load ../data/yctot/rt/rt_CnD_adapt.mat
            
            fprintf('Calculating Correlation\n');
            
            [rho,p]                             = corr(sourceAppend',rt_all{sb} , 'type', 'Spearman');
            
            %             rho_mask                            = p < 0.05 ;
            %             rho                                 = rho .* rho_mask ;
            
            rhoF                                = .5.*log((1+rho)./(1-rho));
            
            source_avg{sb,1,ext_freq}.pow                   = rhoF;             % act
            source_avg{sb,2,ext_freq}.pow(length(rho),1)    = 0;                % bsl
            
            clear rho rhoF
            
            fprintf('Done\n');
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            for b = 1:2
                source_avg{sb,b,ext_freq}.pos    = source.pos;
                source_avg{sb,b,ext_freq}.dim    = source.dim;
                source_avg{sb,b,ext_freq}.inside = source.inside;
            end
            
        end
        
        clear sourceAppend
            
        
            cfg                                                 =   [];
            cfg.dim                                             =   source_avg{1,1,1}.dim;
            cfg.method                                          =   'montecarlo';
            cfg.statistic                                       =   'depsamplesT';
            cfg.parameter                                       =   'pow';
            cfg.correctm                                        =   'cluster';
            cfg.clusteralpha                                    =   0.001;             % First Threshold
            cfg.clusterstatistic                                =   'maxsum';
            cfg.numrandomization                                =   1000;
            cfg.alpha                                           =   0.025;
            cfg.tail                                            =   0;
            cfg.clustertail                                     =   0;
            nsuj                                                =   size(source_avg,1);
            cfg.design(1,:)                                     =   [1:nsuj 1:nsuj];
            cfg.design(2,:)                                     =   [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.uvar                                            =   1;
            cfg.ivar                                            =   2;
            stat{ext_freq}                                      =   ft_sourcestatistics(cfg,source_avg{:,1,ext_freq},source_avg{:,2,ext_freq});
            stat{ext_freq}.cfg                                  =   [];
            [min_p(ext_freq),p_val{ext_freq}]                   =    h_pValSort(stat{ext_freq});   
            
        
        clearvars -except ext_freq stat ix_f stat stat_int source_avg min_p p_val filt_list
        
    end
    
end

clearvars -except source_avg stat min_p p_val ; clc ; 

for ix_f = 1:5
    
    if min_p(ix_f) < 0.1
        
        stat_int{ix_f}          = h_interpolate(stat{ix_f});
        stat_int{ix_f}.cfg      = [];
        stat_int{ix_f}.mask     = stat_int{ix_f}.prob < 0.1;
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'stat';
        cfg.maskparameter       = 'mask';
%         cfg.nslices             = 16;
%         cfg.slicerange          = [70 84];
        cfg.funcolorlim         = [-3 3];
        ft_sourceplot(cfg,stat_int{ix_f});clc;
        
    end
    
end

for ix_f = 1:5
    vox_list{ix_f} = FindSigClusters(stat{ix_f},0.07);
end
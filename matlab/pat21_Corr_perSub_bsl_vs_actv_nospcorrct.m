clear ; clc ; dleiftrip_addpath ;

ix_f = 0 ;

for ext_freq = {'8t10Hz','12t14Hz'};
    
    ix_f = ix_f + 1;
    
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        sourceAppend{1} = [];
        sourceAppend{2} = [];
        
        list_time = {'m600m200','p600p1000'};
        
        for prt = 1:3
            
            for cnd = 1:2
                
                fname = dir(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/' suj '*.pt' num2str(prt) ...
                    '*.CnD.KT.*' ext_freq{:} '*' list_time{cnd} ...
                    '.bsl.5mm.source.mat']);
                
                fname = fname.name;
                fprintf('Loading %50s\n',fname);
                load(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/'  fname]);
                
                sourceAppend{cnd}           = [ sourceAppend{cnd} source]; clear source ;
                
                clear source
                
            end
            
        end
        
        load ../data/yctot/rt_CnD_adapt.mat
        
        fprintf('Calculating Correlation\n');
        
        for cnd = 1:2
            
            [rho,p]                     = corr(sourceAppend{cnd}',rt_all{sb} , 'type', 'Spearman');
            
            %             isig        = find(p>0.01 & ~isnan(p));
            %             rho(isig)   = 0 ;
            
            rhoF        = .5.*log((1+rho)./(1-rho));
            
            source_avg{sb,cnd,ix_f}.pow = rhoF ;
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            source_avg{sb,cnd,ix_f}.pos    = source.pos;
            source_avg{sb,cnd,ix_f}.dim    = source.dim;
            source_avg{sb,cnd,ix_f}.inside = source.inside;
            
        end
        
        clear sourceAppend

        
    end
    
end

load ../data/template/source_struct_template_MNIpos.mat
indx_tot = h_createIndexfieldtrip(source); clear source ;
indx_tot(indx_tot(:,2) > 78 & indx_tot(:,2) < 83,:) = [];
indx_tot(indx_tot(:,2) > 48 & indx_tot(:,2) < 55,:) = [];

for ix_f = 1:2
    for cnd = 1:2
        for sb = 1:14
            source_avg{sb,cnd,ix_f}.pow(indx_tot(:,1)) = 0 ;
        end
    end
end

for ix_f = 1:2
    
    cfg                     =   [];
    cfg.dim                 =   source_avg{1,1,1}.dim;
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
    stat{ix_f}              =   ft_sourcestatistics(cfg,source_avg{:,2,ix_f},source_avg{:,1,ix_f});
    [min_p(ix_f),p_val{ix_f}]   = h_pValSort(stat{ix_f});
    
end

for ix_f = 1:2
    
    stat_int{ix_f}          = h_interpolate(stat{ix_f});
    stat_int{ix_f}.cfg      = [];
    stat_int{ix_f}.mask     = stat_int{ix_f}.prob < 0.2; %min_p(ix_f) + 0.001;
    
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'stat';
    cfg.maskparameter       = 'mask';
    cfg.nslices             = 16;
    cfg.slicerange          = [70 84];
    cfg.funcolorlim         = [-3 3];
    ft_sourceplot(cfg,stat_int{ix_f});clc;
    
end
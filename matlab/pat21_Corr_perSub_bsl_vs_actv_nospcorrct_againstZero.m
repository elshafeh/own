clear ; clc ; dleiftrip_addpath ;

ix_f = 0 ;

for ext_freq = {'8t10Hz','12t14Hz'};
    
    ix_f = ix_f + 1;
    
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        sourceAppend{1}.pow = [];
        sourceAppend{2}.pow = [];
        
        list_time = {'m600m200','p600p1000'};
        
        for prt = 1:3
            
            for cnd = 1:2
                
                fname = dir(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/' suj '*.pt' num2str(prt) ...
                    '*.CnD.KT.*' ext_freq{:} '*' list_time{cnd} ...
                    '.bsl.5mm.source.mat']);
                
                fname = fname.name;
                fprintf('Loading %50s\n',fname);
                load(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/'  fname]);
                
                sourceAppend{cnd}           = [ sourceAppend{cnd}.pow source]; clear source ;
                
                clear source
                
            end
            
        end
        
        load ../data/yctot/rt_CnD_adapt.mat
        
        fprintf('Calculating Correlation\n');
        
        for cnd = 1:2
            
            [rho,p]                     = corr(sourceAppend{cnd}.pow',rt_all{sb} , 'type', 'Spearman');
            
            %             isig        = find(p>0.05 & ~isnan(p));
            %             rho(isig)   = 0 ;
            
            rhoF        = .5.*log((1+rho)./(1-rho));
            
            source_avg{sb,cnd,ix_f}.pow = rhoF ;
            
            load ../data/template/source_struct_template_MNIpos.mat
            
            source_avg{sb,cnd,ix_f}.pos    = source.pos;
            source_avg{sb,cnd,ix_f}.dim    = source.dim;
            source_avg{sb,cnd,ix_f}.inside = source.inside;
            
        end
        
        clear sourceAppend
        
        cfg                     =   [];
        cfg.dim                 =   source_avg{1,1,1}.dim;
        cfg.method              =   'montecarlo';
        cfg.statistic           =   'depsamplesT';
        cfg.parameter           =   'pow';
        cfg.correctm            =   'cluster';
        cfg.clusteralpha        =   0.0001;             % First Threshold
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
        stat{sb,ix_f}           =   ft_sourcestatistics(cfg,source_avg{:,2,ix_f},source_avg{:,1,ix_f});
        
    end
    
end


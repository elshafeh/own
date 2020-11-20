clear ; clc ; dleiftrip_addpath ;

ix_f = 0 ;

for ext_freq = {'12t14Hz'};
    
    ix_f = ix_f + 1;
    
    for sb = 1:14
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        sourceAppend = [];
        list_time = {'m600m200','p600p1000'};
        
        for prt = 1:3
            
            for cnd = 1:2
                
                fname = dir(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/*.pt' num2str(prt) ...
                    '*.CnD.KT.*' ext_freq{:} '*' list_time{cnd} ...
                    '.bsl.5mm.source.mat']);
                
                fname = fname.name;
                
                fprintf('Loading %50s\n',fname);
                
                load(['../../../PAT_MEG/Fieldtripping/data/' suj '/source/' fname]);
                
                source_carr{cnd} = source ; clear source ;
                
            end
            
            relchange = (source_carr{2} - source_carr{1}) ./ source_carr{1};
            
            sourceAppend = [ sourceAppend relchange];
            
            clear relchange sourc_carr
            
        end
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        src2Appnd.pow = sourceAppend ;
        src2Appnd.pos = source.pos ;
        src2Appnd.dim = source.dim ;
        src2Appnd.inside = source.inside ;
        
        clear source sourceAppend
        
        load ../data/yctot/rt/rt_CnD_adapt.mat
        
        cfg                     = [];
        cfg.parameter           = 'pow';
        cfg.method              = 'montecarlo';
        cfg.statistic           = 'ft_statfun_correlationT_FisherZ';
        cfg.correctm            = 'cluster';
        cfg.type                = 'Spearman';
        cfg.computestat         = 'yes';
        cfg.clusterstatistics   = 'maxsum';
        cfg.clusteralpha        = 0.05;
        cfg.tail                = 0;
        cfg.clustertail         = 0;
        cfg.alpha               = 0.025;
        cfg.numrandomization    = 1000;
        cfg.ivar                = 1;
        cfg.design              = rt_all{sb}';
        stat                    = ft_sourcestatistics(cfg, src2Appnd);
        stat.cfg                = [];
        
        %         save(['../data/stat/' suj '.' ext_freq{:} '.mat'],'stat','-v7.3');
        
        stat_carr{sb,ix_f} = stat ; clear stat ;
        
    end
    
end

clearvars -except stat_carr
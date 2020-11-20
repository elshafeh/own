% Coherence on source level data

clear ; clc ;

for sb = 1
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    cnd         = 'CnD';
    
    ext_comp = 'bsl.5mm.source';
    cnd_time = {'.m600m200','.p600p1000'} ;
    cnd_freq = '8t10' ;
    
    for pt = 1:3
        
        for cnd = 1:2
            
            fname = dir(['../data/' suj '/source/*pt' num2str(pt) '*CnD*all.mtmfft*' cnd_freq '*' cnd_time{cnd} '*' ext_comp '*']);
            fname = fname.name;
            fprintf('\nLoading %50s\n',fname);
            load(['../data/' suj '/source/' fname]);
            
            if isstruct(source)
                src_cnd{cnd} = source.avg.pow ; clear source ;
            else
                src_cnd{cnd} = source ; clear source ;
            end
            
        end
        
        src_prt{pt} = (src_cnd{2} - src_cnd{1}) ./ src_cnd{1} ;
        
        clear source_carr
        
    end
    
    source_avg.pow = cat(2,src_prt{:});
    source_avg.pow = mean(source_avg.pow,2);
    
    load ../data/template/source_struct_template_MNIpos.mat
    
    source_avg.pos = source.pos ;
    source_avg.dim = source.dim ;
    
    clear source
    
    %     inter = h_interpolate(source_avg) ;
    %     cfg                     = [];
    %     cfg.method              = 'slice';
    %     cfg.funparameter        = 'pow';
    %     cfg.nslices             = 16;
    %     cfg.slicerange          = [70 84];
    %     ft_sourceplot(cfg,inter);clc;
    
    cfg             = [];
    cfg.method      ='coh';
    cfg.complex     = 'absimag';
    source_conn     = ft_connectivityanalysis(cfg, source_avg);
    
    figure;imagesc(source_conn.cohspctrm);
    
end
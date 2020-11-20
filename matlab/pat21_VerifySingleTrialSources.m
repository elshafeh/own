clear ; clc ;

ix_f = 0 ;

for ext_freq = {'8t10Hz','12t14Hz'};
    
    ix_f = ix_f + 1;
    
    load ../data/template/source_struct_template_MNIpos.mat
    indx_tot = h_createIndexfieldtrip(source); clear source ;
    
    for sb = 1:9
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))];
        
        sourceAppend = [];
        list_time = {'m600m200','p600p1000'};
        
        for prt = 1:3
            
            for cnd = 1:2
                
                fname = dir(['../data/' suj '/source/*.pt' num2str(prt) ...
                    '*.CnD.KT.*' ext_freq{:} '*' list_time{cnd} ...
                    '.bsl.5mm.source.mat']);
                
                fname = fname.name;
                
                fprintf('Loading %50s\n',fname);
                
                load(['../data/' suj '/source/' fname]);
                
                source_carr{cnd} = source ; clear source ;
                
            end
            
            relchange = (source_carr{2} - source_carr{1}) ./ source_carr{1};
            
            sourceAppend = [sourceAppend relchange];
            
            clear relchange sourc_carr
            
        end
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        sr2plot.pow     = mean(sourceAppend,2);
        sr2plot.pos     = source.pos;
        sr2plot.dim     = source.dim;
        
        source_int  = h_interpolate(sr2plot);
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'pow';
        cfg.nslices             = 16;
        cfg.slicerange          = [70 84];
        %         cfg.funcolorlim         = [-0.4 0.4];
        ft_sourceplot(cfg,source_int);
        title([suj ' ' ext_freq{:}]);
        
    end
    
end
clear ; clc ; 

suj = 'yc1' ;

iif = 0 ;

for cond_freq = {'12t14Hz'} % 11t15Hz
    
    for cond_filt = {'Free','pcc.Free','Fixed','pcc.Fixed','FreeAvg','pcc.FreeAvg','FixedAvg','pcc.FixedAvg'}
        
        iif = iif + 1 ;
        
        for prt = 1:3
            
            iit = 0 ; 
            
            for cond_time = {'bsl','actv'}
                
                iit = iit +1 ;
                
                fname = ['../data/' suj '/source/' suj '.pt' num2str(prt) '.CnD.KT.' cond_freq{:} '.' cond_time{:} '.' cond_filt{:} '.mat'];
                load(fname);
                
                source = mean(source,2);
                source_carr{iit} = source ; clear source ; 
                
            end
            
            source_part{prt} = (source_carr{2} - source_carr{1}) ./ source_carr{1} ;
            
            clear source_carr
            
        end
        
        source_avg{1,iif}.pow = mean([source_part{1} source_part{2} source_part{3}],2);
        
        clear source_part
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        source_avg{1,iif}.pos   = source.pos ;
        source_avg{1,iif}.dim   = source.dim ;
    
        clear source
        
    end
    
end

clearvars -except source_avg

for iif = 1:size(source_avg,2)
    
    %     source_int{iif} = h_interpolate(source_avg{iif});
    
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'pow';
    cfg.nslices             = 1;
    cfg.slicerange          = [70 84];
    cfg.funcolorlim         = [-1 1];
    ft_sourceplot(cfg,source_int{iif});clc;
    
end
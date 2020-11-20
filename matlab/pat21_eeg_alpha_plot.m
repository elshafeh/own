clear ; clc ; dleiftrip_addpath ;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    load(['../data/' suj '/source/' suj '.eeg.testpack.mat'])
    
    for t = 2:size(source,1)
        
        for f = 1:size(source,2)
            
            x = source{t,f}.pow;
            y = source{1,f}.pow;
            
            nw_src{sb,t-1,f}.pow = (x-y) ./ y ;
            nw_src{sb,t-1,f}.pos = source{1,1}.pos;
            nw_src{sb,t-1,f}.dim = source{1,1}.dim;
            
            clear x y
            
        end
        
    end
    
    clear source ;
    
end

for t = 1:size(nw_src,2)
    
    for f = 1:size(nw_src,3)
        
        source{t,f}     = ft_sourcegrandaverage([],nw_src{:,t,f});
        source_int{t,f} = h_interpolate(source{t,f});
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'pow';
        cfg.nslices             = 16;
        cfg.slicerange          = [70 84];
        cfg.funcolorlim         = [-0.15 0.15];
        ft_sourceplot(cfg,source_int{t,f});
        
    end
    
end
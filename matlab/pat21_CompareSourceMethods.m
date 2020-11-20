clear ; clc ;

ext = {'source5mmBaselineStatavgF','source5mmBaselineStatFixed','source5mmBaselineStat'};

for a = 1:length(ext)
    
    load(['../data/yctot/stat/' ext{a} '.mat'],'stat');
    
    for cf = 1:2
        for ct = 2
            [min_p(a,cf),p_val{a,cf}] = h_pValSort(stat{cf,ct});
            
            sint = h_interpolate(stat{cf,ct});
            
            sint.mask = sint.prob < 0.05 ;
            
            cfg                     = [];
            cfg.method              = 'slice';
            cfg.funparameter        = 'stat';
            cfg.maskparameter       = 'mask';
            cfg.nslices             = 16;
            cfg.slicerange          = [70 84];
            cfg.funcolorlim         = [-3 3];
            ft_sourceplot(cfg,sint);clc;
            
        end
    end
        
    clear stat;
    
end
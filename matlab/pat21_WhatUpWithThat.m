clear ; clc ;

load ../data/template/source_struct_template_MNIpos.mat;
load ../data/yctot/rt/rt_CnD_adapt.mat ;

template_source = source ; clear source ;

suj_list = [1:4 8:17];

cnd_time = {{'.m600m200','.p700p1100'},{'.m600m200','.p700p1100'},{'.m400m200','.p900p1100'}};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_freq = {'7t11','11t15','7t15'} ;
    
    for cf = 1:3
        for ix = 1:2
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) ...
                    '.CnD.' cnd_freq{cf} 'Hz' ...
                    cnd_time{cf}{ix} '.SingleTrial.NewDpss.mat']);
                
                fname = fname.name;
                fprintf('Loading %50s\n',fname);
                load(['../data/source/' fname]);
                
                source = nanmean(source,2);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            tmp{ix}     = mean([src_carr{1} src_carr{2} src_carr{3}],2);
            
            clear src_carr
            
        end
        
        powpow                       = (tmp{2}-tmp{1})./tmp{1};
        source_avg{sb,cf}.pow        = powpow ; clear powpow ;
        source_avg{sb,cf}.pos        = template_source.pos;
        source_avg{sb,cf}.freq       = template_source.freq;
        source_avg{sb,cf}.dim        = template_source.dim;
        source_avg{sb,cf}.method     = template_source.method;
        
    end
    
end

clearvars -except source_avg rt_all

for cf = 1:3
    
    source                  = ft_sourcegrandaverage([],source_avg{:,cf});
    source_int              = h_interpolate(source);
    
    cfg                     = [];
    cfg.method              = 'slice';
    cfg.funparameter        = 'pow';
    cfg.funcolorlim         = [-0.2 0.2];
    ft_sourceplot(cfg,source_int);clc;
    
end
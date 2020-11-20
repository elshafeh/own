clear ; clc ;

clear ; clc ;

suj_list = [1:4 8:17];

cnd_time = {{'.m600m200','.p200p600'},{'.m600m200','.p600p1000'}};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_freq = {'8t10','12t14'} ;
    
    for cf = 1:2
        
        ct = 2 ;
        
        for ix = 1:2
            
            for cp = 1:3
                
                fname = dir(['../data/' suj '/source/*pt' num2str(cp) '*CnD.all.mtmfft.*' cnd_freq{cf} '*' cnd_time{ct}{ix} '*bsl.5mm.source*']);
                if size(fname,1)==1
                    fname = fname.name;
                end
                fprintf('Loading %50s\n',fname);
                load(['../data/' suj '/source/' fname]);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                src_carr{cp}.pow = source ; clear source ;
                
                load ../data/template/source_struct_template_MNIpos.mat;
                
                src_carr{cp}.pos    = source.pos;
                src_carr{cp}.dim    = source.dim;
                src_carr{cp}.inside = source.inside;
                
            end
            
            source_avg{sb,cf,ix} = ft_sourcegrandaverage([],src_carr{:});
            
            clear src_carr
            
        end
        
        
        clear relchange
        
    end
    
end

clearvars -except source_avg ; clc ;

load ../data/yctot/rt_CnD_adapt.mat

cfg                         = [];
cfg.parameter               = 'pow';
cfg.method                  = 'montecarlo';
cfg.statistic               = 'ft_statfun_correlationT_FisherZ';
cfg.correctm                = 'cluster';
cfg.clusteralpha            = 0.05;
cfg.clusterstatistics       = 'maxsum';
cfg.tail                    = 0;
cfg.clustertail             = 0;
cfg.alpha                   = 0.025;
cfg.numrandomization        = 1000;
cfg.ivar                    = 1;
cfg.type                    = 'Spearman';
cfg.computestat             = 'yes';

for cf = 1:2
    
    for cnd = 1:2
        
        cfg.design(1,1:14)                      = cellfun(@mean,rt_all);
        stat{cf,cnd,1}                          = ft_sourcestatistics(cfg,source_avg{:,cf,cnd}) ;
        [min_p{cf,cnd,1},p_val{cf,cnd,1}]       = h_pValSort(stat{cf,cnd,1});
        
        cfg.design(1,1:14)                      = cellfun(@median,rt_all);
        stat{cf,cnd,2}                          = ft_sourcestatistics(cfg,source_avg{:,cf,cnd}) ;
        [min_p{cf,cnd,2},p_val{cf,cnd,2}]       = h_pValSort(stat{cf,cnd,2});
        
    end
    
end


load ../data/template/source_struct_template_MNIpos.mat;

for cf = 1:2
    
    for mm = 1:2
        
        sourcePOI.pow       = stat{cf,2,mm}.rho;
        sourcePOI.pos       = source.pos;
        sourcePOI.dim       = source.dim;
        sourcePOI.inside    = source.inside;
        
        sourceBSL.pow       = stat{cf,1,mm}.rho;
        sourceBSL.pos       = source.pos;
        sourceBSL.dim       = source.dim;
        sourceBSL.inside    = source.inside;
        
        cfg                     = [];
        cfg.operation           = '(x1-x2) ./ x2';
        cfg.parameter           = 'pow' ;
        src                     = ft_math(cfg,sourcePOI,sourceBSL);
        
        src_int                = h_interpolate(src);
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'pow';
%         cfg.nslices             = 16;
%         cfg.slicerange          = [70 84];
%         cfg.funcolorlim         = [-3 3];
        ft_sourceplot(cfg,src_int);clc;
        
    end
    
end
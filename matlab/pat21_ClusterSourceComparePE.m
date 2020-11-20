clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/template/source_struct_template_MNIpos.mat;

template_source = source ; clear source ;

suj_list = [1:4 8:17];

cnd_cp = {{'fDIS.comp3','DIS.comp3'},{'nDT.comp2','nDT.comp3'}};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(cnd_cp)
        for ix = 1:2
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) '.' cnd_cp{cnd}{ix} '.lcmvSource.mat']);
                
                if size(fname,1)==1
                    fname = fname.name;
                end
                
                fprintf('Loading %50s\n',fname);load(['../data/source/' fname]);
                
                if isstruct(source);source = source.avg.pow;end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            tmp{ix}       = mean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr ;
            
        end
        
        source_avg{sb,cnd}.pow        = (tmp{2}-tmp{1}) ./ tmp{1}; clear tmp ;
        source_avg{sb,cnd}.pos        = template_source.pos;
        source_avg{sb,cnd}.dim        = template_source.dim;
        
    end
end

clearvars -except source_avg ; clc ;

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.025;
cfg.tail                =   0;
cfg.clustertail         =   0;
cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;
cfg.clusteralpha        = 0.05;             % First Threshold

stat                    = ft_sourcestatistics(cfg,source_avg{:,2},source_avg{:,1}) ;
[min_p,p_val]           = h_pValSort(stat);

stat.mask               = stat.prob < 0.05;
source.pos              = stat.pos;source.dim              = stat.dim;
source.pow              = stat.stat .* stat.mask;
ix                      = source.pow;
flag                    = find(~isnan(ix) & ix ~=0);
mn                      = mean(ix(flag));
ix(ix<mn)               = 0;
source.pow              = ix;
source_int              = h_interpolate(source);

cfg                     = [];
cfg.method              = 'slice';
cfg.funparameter        = 'pow';
% cfg.nslices             = 16;
% cfg.slicerange          = [70 84];
cfg.funcolorlim         = [-3 3];
ft_sourceplot(cfg,source_int);clc;
title(num2str(min_p));

vox_list = FindSigClusters(stat,0.05);
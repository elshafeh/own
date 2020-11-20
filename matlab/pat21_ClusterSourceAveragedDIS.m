clear ; clc ; dleiftrip_addpath ;

clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

suj_list        = [1:4 8:17];
cnd_freq        = '70t90Hz';
cnd_ext         = {'DIS','fDIS'};
cnd_time        = {'p100p200','p400p500'}; % 'p200p300','p300p400','p400p500'

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(cnd_ext)
        
        for ix = 1:length(cnd_time)
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) '.' cnd_ext{cnd} '.' cnd_time{ix} '.' cnd_freq '.MinEvokedSource.mat']);
                
                if size(fname,1)==1
                    fname = fname.name;
                end
                
                fprintf('Loading %50s\n',fname);
                load(['../data/source/' fname]);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            tmp(:,ix)           = mean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr
            
        end
        
        source_avg{sb,cnd}.pow        = mean(tmp,2); clear tmp ;
        source_avg{sb,cnd}.pos        = template_source.pos;
        source_avg{sb,cnd}.freq       = template_source.freq;
        source_avg{sb,cnd}.dim        = template_source.dim;
    end
end

clearvars -except source_avg

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

stat                    = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;
[min_p,p_val]           = h_pValSort(stat);

p_lim                   = 0.05; stat.mask               = stat.prob < p_lim;

source.pos              = stat.pos;source.dim  = stat.dim;
source.pow              = stat.stat .* stat.mask; source_int              = h_interpolate(source);

vox_list                = FindSigClusters(stat,0.05); clc ;
cfg                     = [];
cfg.method              = 'slice';
cfg.funparameter        = 'pow';
cfg.nslices             = 16;
cfg.slicerange          = [70 84];
cfg.funcolorlim         = [-5 5];
ft_sourceplot(cfg,source_int);clc;

for iside = 1:3
    
    lst_side = {'left','right','both'}; lst_view = [-95 1;95,11;0 50];
    
    clear source
    
    stat.mask   = stat.prob < 0.05; source.pos    = stat.pos ;
    source.dim   = stat.dim ; source.pow          = stat.stat .* stat.mask;
    
    cfg                     =   [];
    cfg.method              =   'surface'; cfg.funparameter        =   'pow';
    cfg.funcolorlim         =   [-3 3]; cfg.opacitylim          =   [-3 3];
    cfg.opacitymap          =   'rampup';
    cfg.colorbar            =   'off'; cfg.camlight            =   'no';
    cfg.projthresh          =   0.2;
    cfg.projmethod          =   'nearest';
    cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat']; cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    ft_sourceplot(cfg, source); view(lst_view(iside,1),lst_view(iside,2))
end
clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/template/source_struct_template_MNIpos.mat;

template_source = source ; clear source ;
suj_list        = [1:4 8:17];
lst_cnd         = {'V','N'};
cnd_time        = {'.m50m0ms','.p390p440ms'};

% cnd_time        = {'.m70m0ms','.p270p340ms'};
% cnd_time        = {'.m100m0ms','.p110p210ms'};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(lst_cnd)
        for ix = 1:2
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) '.' lst_cnd{cnd} cnd_time{ix} '.lcmvSource.mat']);
                
                if size(fname,1)==1
                    fname = fname.name;
                end
                
                fprintf('Loading %50s\n',fname);
                load(['../data/source/' fname]);
                
                if isstruct(source);
                    source = source.pow;
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            tmp{ix} = mean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr
            
        end
        
        %         source_avg{sb,cnd}.pow = (tmp{2} - tmp{1}) ./ tmp{1};
        source_avg{sb,cnd}.pow = (tmp{2} - tmp{1});

        source_avg{sb,cnd}.pos = template_source.pos ;
        source_avg{sb,cnd}.dim = template_source.dim ;
        clear tmp
    end
end

clearvars -except source_avg ; clc ;

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';cfg.statistic           =   'depsamplesT';cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;cfg.alpha               =   0.025;
cfg.tail                =   0;cfg.clustertail         =   0;cfg.design(1,:)         =   [1:14 1:14];cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;cfg.ivar                =   2;

cfg.clusteralpha        =   0.05;             % First Threshold

stat{1}                 =   ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;
stat{2}                 =   ft_sourcestatistics(cfg,source_avg{:,3},source_avg{:,4}) ;

for n = 1:length(stat)
    [min_p(n),p_val{n}]           = h_pValSort(stat{n});
end

clearvars -except stat min_p p_val source_avg ; 

p_lim                       = 0.11;

for n = 1:length(stat)
    vox_list{n}             = FindSigClusters(stat{n},p_lim); clc ;
end

for n = 1
    stat{n}.mask                = stat{n}.prob < p_lim;
    source.pos                  = stat{n}.pos;
    source.dim                  = stat{n}.dim;
    source.pow                  = stat{n}.stat .* stat{n}.mask;
    source.pow(source.pow == 0,:) = NaN;
    
    for iside = 1:3
        lst_side = {'left','right','both'}; lst_view = [-95 1;95,11;0 50];
        
        cfg                     =   [];
        cfg.method              =   'surface'; cfg.funparameter        =   'pow';
        cfg.funcolorlim         =   [-5 5]; cfg.opacitylim          =   [-3 3];
        cfg.opacitymap          =   'rampup';
        cfg.colorbar            =   'off'; cfg.camlight            =   'no';
        cfg.projthresh          =   0.2;
        cfg.projmethod          =   'nearest';
        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat']; cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source); view(lst_view(iside,1),lst_view(iside,2))
    end
end

%     cfg                     = [];
%     cfg.method              = 'slice';
%     cfg.funparameter        = 'pow';
%     cfg.nslices             = 1;
%     cfg.colorbar            = 'no';
%     cfg.slicerange          = [70 84];
%     cfg.funcolorlim         = [-5 5];
%     ft_sourceplot(cfg,source_int);clc;
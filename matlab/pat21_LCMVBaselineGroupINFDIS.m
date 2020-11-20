clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/template/source_struct_template_MNIpos.mat;

template_source = source ; clear source ;
suj_list        = [1:4 8:17];
lst_cnd         = 'RLN';
lst_dis         = {'comp1','comp3'};
cnd_time        = {'fDIS','DIS'};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for cnd = 1:length(lst_cnd)
        for ds = 1:length(lst_dis)
            for ix = 1:2
                for cp = 1:3
                    
                    fname = dir(['../data/source/' suj '.pt' num2str(cp) '.' lst_cnd(cnd)  cnd_time{ix} '.'  lst_dis{ds}  '.lcmvSource.mat']);
                    
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
                
                tmp{ix} = mean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr
                
            end
            
            tf_dis{ds} = tmp{2} - tmp{1}; clear tmp ;
            
        end
        
        source_avg{sb,cnd}.pow = tf_dis{2} - tf_dis{1} ; %(tf_dis{2} - tf_dis{1}) ./ tf_dis{1} ;   clear tf_dis
        source_avg{sb,cnd}.pos = template_source.pos ;
        source_avg{sb,cnd}.dim = template_source.dim ;
        
        forlater(sb,cnd,1,:) = tf_dis{1};
        forlater(sb,cnd,2,:) = tf_dis{2};

        
    end
end

clearvars -except source_avg forlater stat; clc ;

for sb = 1:14
    new_source_avg{sb,1} = ft_sourcegrandaverage([],source_avg{sb,1},source_avg{sb,2});
    new_source_avg{sb,2} = source_avg{sb,3};  
end

source_avg = new_source_avg ; clearvars -except source_avg ;

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';cfg.correctm            =   'cluster';cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;cfg.alpha               =   0.025;
cfg.tail                =   0;cfg.clustertail         =   0;
cfg.design(1,:)         =   [1:14 1:14];
cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;
cfg.ivar                =   2;
cfg.clusteralpha        = 0.025;             % First Threshold

stat                    = ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ;
[min_p,p_val]           = h_pValSort(stat);

p_lim                   = 0.1; stat.mask               = stat.prob < p_lim;

source.pos              = stat.pos;source.dim  = stat.dim;
source.pow              = stat.stat .* stat.mask; source_int              = h_interpolate(source);

vox_list                = FindSigClusters(stat,p_lim); clc ;

% cfg                     = [];% cfg.method              = 'slice';
% cfg.funparameter        = 'pow';% cfg.nslices             = 1;
% cfg.colorbar            = 'no';% cfg.slicerange          = [70 84];
% cfg.funcolorlim         = [-5 5];% ft_sourceplot(cfg,source_int);clc;

informative     = squeeze(mean(forlater(:,[1 2],:,:),2));
unformative     = squeeze(forlater(:,3,:,:));

infpow          = squeeze(mean(informative(:,2,:),1));
unfpow          = squeeze(mean(unformative(:,2,:),1));

infbsl          = squeeze(mean(informative(:,1,:),1));
unfbsl          = squeeze(mean(unformative(:,1,:),1));

gavg{1}.pow = (infpow - infbsl) ./ infbsl ;
gavg{2}.pow = (unfpow - unfbsl) ./ unfbsl ;
gavg{1}.pos = stat.pos;
gavg{2}.pos = stat.pos;
gavg{1}.dim = stat.dim;
gavg{2}.dim =  stat.dim;

gavg{3} = source;

for cnd = 1:3
    for iside = 1
        lst_side = {'left','right','both'}; lst_view = [-95 1;95,11;0 50];
        
        cfg                     =   [];
        cfg.method              =   'surface'; cfg.funparameter        =   'pow';
        
        cfg.funcolorlim         =   [-3 3]; cfg.opacitylim          =   [-3 3];
        
        cfg.opacitymap          =   'rampup';
        cfg.colorbar            =   'off'; cfg.camlight            =   'no';
        cfg.projthresh          =   0.2;
        cfg.projmethod          =   'nearest';
        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat']; cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        
        ft_sourceplot(cfg, gavg{cnd}); view(lst_view(iside,1),lst_view(iside,2))
        
    end
end
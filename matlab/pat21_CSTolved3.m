clear;clc;

load ../data/template/source_struct_template_MNIpos.mat;

template_source = source ; clear source ;
suj_list        = [1:4 8:17];
cnd_time        = {'CnD.comp1','CnD.comp2'};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for ix = 1:2
        for cp = 1:3
            
            fname = dir(['../data/source/' suj '.pt' num2str(cp) '.' cnd_time{ix} '.lcmvSource.mat']);
            
            if size(fname,1)==1
                fname = fname.name;
            end
            
            fprintf('Loading %50s\n',fname);
            load(['../data/source/' fname]);
            
            tmp                                         = nan(length(source.pow),length(source.time));
            tmp(template_source.inside==1,:)            = cell2mat(source.mom);
            
            nw.pow                                      = tmp;
            nw.time                                     = source.time;
            
            src_carr{cp} = nw ; clear source nw tmp;
            
        end
        
        avg                     = cat(3,src_carr{1}.pow,src_carr{2}.pow,src_carr{3}.pow);
        avg                     = squeeze(nanmean(avg,3));
        
        source_avg{sb,ix}.pow   = avg;
        source_avg{sb,ix}.pos   = template_source.pos;
        source_avg{sb,ix}.dim   = template_source.dim;
        
        source_avg{sb,ix}.time  = src_carr{1}.time;
        
        clear src_carr avg
        
    end
    
    source_avg{sb,1}.time       = source_avg{sb,2}.time;
    
end

clearvars -except source_avg ; clc ;

for cnd = 1:2
    gavg{cnd} = ft_sourcegrandaverage([],source_avg{:,cnd});
end

save('../data/yctot/gavg/CnD_single.mat','gavg','-v7.3');

% cfg                     =   [];
% cfg.dim                 =   source_avg{1,1}.dim;cfg.method              =   'montecarlo';
% cfg.statistic           =   'depsamplesT';cfg.parameter           =   'pow';
% cfg.correctm            =   'cluster';cfg.clusterstatistic    =   'maxsum';
% cfg.numrandomization    =   1000;
% cfg.alpha               =   0.025;
% cfg.tail                =   0;cfg.clustertail         =   0;cfg.design(1,:)         =   [1:14 1:14];cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
% cfg.uvar                =   1;cfg.ivar                =   2;
% cfg.avgovertime         = 'yes';
% cfg.clusteralpha        = 0.05;  % First Threshold
% stat                    = ft_sourcestatistics(cfg,source_avg{:,2},source_avg{:,1}) ;
% stat.cfg                = [];
% 
% [min_p,p_val]           = h_pValSort(stat);
% 
% for iside = 1:2
%     for n = 1:size(stat.prob,2)
%         lst_side                = {'left','right','both'};
%         lst_view                = [-95 1;95,11;0 50];
%         clear source
%         
%         nw_tval                 = squeeze(stat.stat(:,n));
%         nw_prob                 = squeeze(stat.prob(:,n)) ;
%         nw_mask                 = nw_prob < 0.05;
%         
%         source.dim              = stat.dim ;
%         source.pos              = stat.pos ;
%         source.pow              = nw_tval .* nw_mask;
%         
%         cfg                     =   [];
%         cfg.method              =   'surface';
%         cfg.funparameter        =   'pow';
%         cfg.funcolorlim         =   [-5 5];cfg.opacitylim          =   [-5 5];
%         cfg.opacitymap          =   'rampup'; cfg.colorbar            =   'off';
%         cfg.camlight            =   'no'; cfg.projthresh          =   0.2;
%         cfg.projmethod          =   'nearest';
%         cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
%         cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%         ft_sourceplot(cfg, source);
%         view(lst_view(iside,1),lst_view(iside,2))
%     end
% end
% 
% vox_list = FindSigClusters(stat,0.05);
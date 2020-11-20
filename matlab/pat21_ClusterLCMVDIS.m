clear ; clc ; dleiftrip_addpath ;

load ../data/template/source_struct_template_MNIpos.mat;

template_source = source ; clear source ;
suj_list        = [1:4 8:17];
cnd_time        = {{'m120m0ms','p50p169ms'}, ...
    {'m70m0ms','p190p260ms'}, ...
    {'m30m0ms','p270p300ms'}, ...
    {'m60m0ms','p320p380ms'}};

cnd_data        = {'DIS','fDIS'};

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for ntest = 1:length(cnd_time)
        for ix = 1:2
            for ndata = 1:2
                for cp = 1:3
                    
                    fname = dir(['../data/source/' suj '.pt' num2str(cp) '.' cnd_data{ndata} '.' cnd_time{ntest}{ix} '.lcmvSource.mat']);
                    
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
                
                src_data{ndata}                = mean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr
                
            end
            
            source_avg{sb,ntest,ix}.pow        = src_data{1} - src_data{2}; clear src_data
            source_avg{sb,ntest,ix}.pos        = template_source.pos;
            source_avg{sb,ntest,ix}.dim        = template_source.dim;
            
        end
    end
end

clearvars -except source_avg ; clc ;

% for cnd = 1:2
%     gavg{cnd} = ft_sourcegrandaverage([],source_avg{:,1,cnd});
% end
% % save('../data/yctot/gavg/CnD_averaged.mat','gavg','-v7.3');

cfg                     =   [];
cfg.dim                 =   source_avg{1,1}.dim;
cfg.method              =   'montecarlo';
cfg.statistic           =   'depsamplesT';
cfg.parameter           =   'pow';
cfg.correctm            =   'cluster';
cfg.clusterstatistic    =   'maxsum';
cfg.numrandomization    =   1000;
cfg.alpha               =   0.025;
cfg.tail                =   0;cfg.clustertail         =   0;cfg.design(1,:)         =   [1:14 1:14];cfg.design(2,:)         =   [ones(1,14) ones(1,14)*2];
cfg.uvar                =   1;cfg.ivar                =   2;

first_threshold = [0.001 0.01 0.05 0.05];

for ntest = 1:size(source_avg,2)
    cfg.clusteralpha            = first_threshold(ntest);             % First Threshold
    stat{ntest}                 = ft_sourcestatistics(cfg,source_avg{:,ntest,2},source_avg{:,ntest,1}) ;
    stat{ntest}.cfg             = [];
end

for ntest = 1:size(source_avg,2)
    [min_p(ntest),p_val{ntest}] = h_pValSort(stat{ntest});
end

% clearvars -except stat min_p p_val source_avg

plim = 0.05;

for ntest = 1:1:length(stat)
    vox_list{ntest} = FindSigClusters(stat{ntest},plim);
end

limlim = 6;

for ntest = 1:1:length(stat)
    for iside = 1:3
        lst_side                = {'left','right','both'};
        lst_view                = [-95 1;95,11;0 50];
        clear source
        stat{ntest}.mask        = stat{ntest}.prob < plim;
        source.pos              = stat{ntest}.pos ;
        source.dim              = stat{ntest}.dim ;
        source.pow              = stat{ntest}.stat .* stat{ntest}.mask;
        cfg                     =   [];
        cfg.method              =   'surface';cfg.funparameter        =   'pow';
        cfg.funcolorlim         =   [-limlim limlim];cfg.opacitylim          =   [-limlim limlim];
        cfg.opacitymap          =   'rampup';
        cfg.colorbar            =   'off';cfg.camlight            =   'no';
        cfg.projthresh          =   0.2;cfg.projmethod          =   'nearest';
        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source);
        view(lst_view(iside,1),lst_view(iside,2))
        
        saveas(gcf,['../images/dis.component.' num2str(ntest) '.' lst_side{iside} '.png']);
        close all;
        
    end
end
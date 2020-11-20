clear ; clc ; dleiftrip_addpath ; close all;

suj_list = [1:4 8:17];

% ext_time    = {'p50p169ms'}; ext_bsl     = 'm120m0ms';
% ext_time    = {'p190p260ms'}; ext_bsl     = 'm70m0ms';
% ext_time    = {'p300p500ms'}; ext_bsl     = 'm200m0ms';
% ext_time    = {'p390p450ms'}; ext_bsl     = 'm60m0ms';
% ext_time    = {'p110p210ms'}; ext_bsl     = 'm100m0ms';
% ext_time    = {'p110p210ms'}; ext_bsl     = 'm100m0ms';


% ext_time    = {'p200p250ms'}; ext_bsl     = 'm50m0ms';
% ext_time    = {'p290p310ms'};ext_bsl     = 'm20m0ms';
% ext_time    = {'p400p470ms'};ext_bsl     = 'm70m0ms';
% ext_time    = {'p450p500ms'};ext_bsl     = 'm50m0ms';
% ext_time    = {'p430p540ms'};ext_bsl     = 'm110m0ms';

cnd_time    = 0.1;

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    %     lst_cnd2compare = {'VnDT','NnDT'};
    %     lst_cnd2compare = {'RnDT','NnDRT','LnDT','NnDLT'};
    %     lst_cnd2compare = {'RnDT','NnDRT','LnDT','NnDLT'};

    lst_cnd2compare = {'V','N',};
    
    for ncond = 1:length(lst_cnd2compare)
        
        source_avg{sb,ncond}.pow    = zeros(length(template_source.pos),length(cnd_time));
        source_avg{sb,ncond}.pos    = template_source.pos;
        source_avg{sb,ncond}.dim    = template_source.dim;
        source_avg{sb,ncond}.time   = cnd_time;
        
        for ntime = 1:length(ext_time)
            
            src_carr{1} =[]; src_carr{2} =[];
            
            for npart = 1:3
                
                ext_lock    = lst_cnd2compare{ncond};
                
                ext_source  = 'lcmvSource.mat';
                
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_bsl '.' ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{1} = [src_carr{1} source]; clear source ;
                
                fname = dir(['../data/source/' suj '.pt' num2str(npart) '.' ext_lock '.' ext_time{ntime} '.' ext_source]);
                fprintf('Loading %50s\n',fname.name);load(['../data/source/' fname.name]);
                
                src_carr{2} = [src_carr{2} source]; clear source ;
                
            end
            
            bsl                                             = nanmean(src_carr{1},2);
            act                                             = nanmean(src_carr{2},2);
            pow                                             = (act-bsl)./bsl; clear bsl act src_carr;
            %             pow                                             = (act-bsl); clear bsl act src_carr;
            
            source_avg{sb,ncond}.pow(:,ntime)    = pow ; clear pow;
            
        end
    end
end

clearvars -except source_avg ;

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
cfg.clusteralpha        =   0.05;             % First Threshold

stat{1}                 =   ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,2}) ; 
stat{2}                 =   ft_sourcestatistics(cfg,source_avg{:,3},source_avg{:,4}) ;
% stat{3}                 =   ft_sourcestatistics(cfg,source_avg{:,1},source_avg{:,3}) ;
% stat{4}                 =   ft_sourcestatistics(cfg,source_avg{:,5},source_avg{:,6}) ;

for cnd_s = 1:length(stat)
    [min_p(cnd_s),p_val{cnd_s}]           =   h_pValSort(stat{cnd_s});
end

plim                    = 0.05;

for cnd_s = 1:length(stat)
    vox_list{cnd_s} = FindSigClusters(stat{cnd_s},plim);
end

% plot per window
for cnd_s = 1:length(stat)
    if min_p(cnd_s) < plim
        
        t_lim = 0; z_lim = 5;stat{cnd_s}.mask = stat{cnd_s}.prob < plim;
        for ntime           = length(stat{cnd_s}.time):-1:1
            for iside = 1:3
                
                lst_side                = {'left','right','both'};
                lst_view                = [-95 1;95,11;0 50];
                %                 lst_position            = {[50 400 500
                %                 250],[700 400 500 250],[500 50 500 250]};
                
                clear source ;
                source.pos              = stat{cnd_s}.pos ;
                source.dim              = stat{cnd_s}.dim ;
                tpower                  = stat{cnd_s}.stat .* stat{cnd_s}.mask;
                
                source.pow              = squeeze(tpower(:,ntime)) ; clear tpower;
                
                cfg                     =   [];
                cfg.method              =   'surface';
                cfg.funparameter        =   'pow';
                cfg.funcolorlim         =   [-z_lim z_lim];cfg.opacitylim          =   [-z_lim z_lim];
                cfg.opacitymap          =   'rampup';cfg.colorbar            =   'off';
                cfg.camlight            =   'no';
                cfg.projthresh          =   0.2;
                cfg.projmethod          =   'nearest';
                cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                ft_sourceplot(cfg, source);
                view(lst_view(iside,1),lst_view(iside,2))
                %                 set(gcf,'position',lst_position{iside})
                
                clear source
                
            end
        end
        
    end
end
clear ; clc ; dleiftrip_addpath ; close all ;

load ../data/template/source_struct_template_MNIpos.mat;

template_source = source ; clear source ;

suj_list = [1:4 8:17];

pices    = {'m100m0','p0p100','p100p200','p200p300','p300p400','p400p500','p500p600'};

pci_bsl  = 'm1400m1299';
pci_frq  = '80t100Hz';

for t = 1:length(pices)
    cnd_time{t,1}   = pci_bsl;
    cnd_time{t,2}   = pices{t};
    cnd_freq{t}     = pci_frq;
end

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for ntest = 1:length(cnd_freq)
        for ix = 1:2
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) '.nDT.' cnd_time{ntest,ix} '.' cnd_freq{ntest} '.MinEvokedSource.mat']);
                
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
            
            source_avg{sb,ntest,ix}.pow        = mean([src_carr{1} src_carr{2} src_carr{3}],2);
            source_avg{sb,ntest,ix}.pos        = template_source.pos;
            source_avg{sb,ntest,ix}.freq       = template_source.freq;
            source_avg{sb,ntest,ix}.dim        = template_source.dim;
            source_avg{sb,ntest,ix}.method     = template_source.method;
            
            clear src_carr
            
        end
    end
end

clearvars -except source_avg pices; clc ;

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

for ntest = 1:size(source_avg,2)
    stat{ntest}                 = ft_sourcestatistics(cfg,source_avg{:,ntest,2},source_avg{:,ntest,1}) ;
    stat{ntest}.cfg             = [];
end

for ntest = 1:1:length(stat)
    [min_p(ntest),p_val{ntest}] = h_pValSort(stat{ntest});
end

clearvars -except stat min_p p_val source_avg pices ;

t_lim = 0;
z_lim = 5;

for ntest = 1:1:length(stat)
    for iside = 3
        
        lst_side                = {'left','right','both'};
        lst_view                = [-95 1;95,11;0 50];
        
        clear source ;
        
        stat{ntest}.mask        = stat{ntest}.prob < 0.05;
        
        source.pos              = stat{ntest}.pos ;
        source.dim              = stat{ntest}.dim ;
        tpower                  = stat{ntest}.stat .* stat{ntest}.mask;
        %         tpower(tpower<t_lim)    = 0;
        source.pow              = tpower ; clear tpower;
        
        cfg                     =   [];
        cfg.method              =   'surface';
        cfg.funparameter        =   'pow';
        cfg.funcolorlim         =   [-z_lim z_lim];
        cfg.opacitylim          =   [-z_lim z_lim];
        cfg.opacitymap          =   'rampup';
        cfg.colorbar            =   'off';
        cfg.camlight            =   'no';
        cfg.projthresh          =   0.2;
        cfg.projmethod          =   'nearest';
        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source);
        view(lst_view(iside,1),lst_view(iside,2))
        %         title(pices{ntest});
        %         saveFigure(gcf,['/Users/heshamelshafei/Desktop/CnDGamma/60t100Hz/' num2str(iside) '.' pices{ntest} '.png']);
        %         close all;
        
    end
end
%
% % for ntest = 1:length(stat)
% %     p_lim                       = 0.05;
% %     stat{ntest}.mask            = stat{ntest}.prob < p_lim;
% %
% %     source.pos                  = stat{ntest}.pos; source.dim                  = stat{ntest}.dim;
% %     source.pow                  = stat{ntest}.stat .* stat{ntest}.mask; source_int                  = h_interpolate(source);
% %
% %     cfg                         = [];
% %     cfg.method                  = 'slice';
% %     cfg.funparameter            = 'pow';
% %     cfg.nslices                 = 16;
% %     cfg.slicerange              = [70 84];
% %     cfg.funcolorlim             = [-5 5];
% %     ft_sourceplot(cfg,source_int);clc;
% %     title(pices{ntest});
% % end
%
% % for ntest = 1:1:length(stat)
% %     vox_list{ntest} = FindSigClusters(stat{ntest},0.05);
% % end
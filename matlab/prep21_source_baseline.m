clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list    = [1:4 8:17];

cnd_freq    = {'11t15Hz'};

cnd_time    = {'m600m200','p600p1000'}; % {'m400m200','p200p400','p400p600','p600p800','p800p1000'}; % {'m600m200','p600p1000'}; % 

ext_end     = '.NewSource';

for nfreq = 1:length(cnd_freq)
    
    for sb = 1:length(suj_list)
        
        suj = ['yc' num2str(suj_list(sb))];
        
        for ntime = 1:length(cnd_time)
            
            for cp = 1:3
                
                fname = ['../data/paper_data/' suj '.pt' num2str(cp) '.CnD.' cnd_time{ntime} '.' cnd_freq{nfreq}     ...
                    ext_end '.mat'];
                
                fprintf('Loading %50s\n',fname);
                
                load(fname);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                if size(source,2) > 1
                    source = mean(source,2);
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            load ../data/template/template_grid_0.5cm.mat
            
            source_avg{sb,ntime,nfreq}.pow        = nanmean([src_carr{1} src_carr{2} src_carr{3}],2); clear src_carr ;
            source_avg{sb,ntime,nfreq}.pos        = template_grid.pos;
            source_avg{sb,ntime,nfreq}.dim        = template_grid.dim;
            
            clear src_carr
            
        end
    end
end

clearvars -except source_avg cnd_freq cnd_time; clc ;

cfg                                =   [];
cfg.dim                            =   source_avg{1}.dim;
cfg.method                         =   'montecarlo';
cfg.statistic                      =   'depsamplesT';
cfg.parameter                      =   'pow';
cfg.correctm                       =   'cluster';

cfg.clusterstatistic               =   'maxsum';
cfg.numrandomization               =   1000;
cfg.alpha                          =   0.025;

cfg.tail                           =   0; % !!!
cfg.clustertail                    =   0; % !!!

cfg.clusteralpha                   =   0.05;             % First Threshold cluster_alpha; % 

nsuj                               =   length(source_avg);
cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                           =   1;
cfg.ivar                           =   2;

nfreq                              =   1;

for ntime = 2:size(source_avg,2)
    stat{1,ntime-1}                = ft_sourcestatistics(cfg, source_avg{:,ntime,nfreq},source_avg{:,1,nfreq});
end

for ntest = 1:size(stat,2)
    [min_p(1,ntest),p_val{1,ntest}] = h_pValSort(stat{1,ntest});
end

for ntest = 1:size(stat,2)
    for iside = [1 2]
        
        lst_side                      = {'left','right','both'};
        lst_view                      = [-95 1;95 1;0 50];
        
        z_lim                         = 5;
        
        clear source ;
        
        stoplot                       = stat{1,ntest};
        
        stoplot.mask                  = stoplot.prob < 0.05;
        
        source.pos                    = stoplot.pos ;
        source.dim                    = stoplot.dim ;
        tpower                        = stoplot.stat .* stoplot.mask;
        tpower(tpower==0)             = NaN;
        
        source.pow                    = tpower ; clear tpower;
        
        cfg                           =   []; cfg.method                    =   'surface'; cfg.funparameter              =   'pow';
        cfg.funcolorlim               =   [-z_lim z_lim];
        cfg.opacitylim                =   [-z_lim z_lim];
        cfg.opacitymap                =   'rampup'; cfg.colorbar                  =   'off'; cfg.camlight                  =   'no';
        cfg.projmethod                =   'nearest';
        cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
        cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source);
        view(lst_view(iside,:))
        
        title(cnd_time{ntest+1});
        
        %         title(cnd_freq{nfreq});
        %         saveas(gcf,['~/GoogleDrive/PhD/Publications/Papers/alpha2017/eNeuro/prep/source_revised/noncorr_' cnd_time{2} '_' cnd_freq{nfreq} '.' num2str(iside) '.png'])
        %         close all;
        
    end
end

%     s_act = ft_sourcegrandaverage([],source_avg{:,2});
%     s_bsl = ft_sourcegrandaverage([],source_avg{:,1});
%
%     source      = s_act;
%     source.pow  = (s_act.pow - s_bsl.pow) ./ s_bsl.pow;
%
%     z_lim                         = 0.15;
%
%     cfg                           =   [];
%     cfg.method                    =   'surface';
%     cfg.funparameter              =   'pow';
%     cfg.funcolorlim               =   [-z_lim z_lim];
%     cfg.opacitylim                =   [-z_lim z_lim];
%     cfg.opacitymap                =   'rampup';
%     cfg.colorbar                  =   'off';
%     cfg.camlight                  =   'no';
%     cfg.projthresh                =   0.2;
%     cfg.projmethod                =   'nearest';
%     cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
%     cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%     ft_sourceplot(cfg, source);
%     view(lst_view(iside,:))


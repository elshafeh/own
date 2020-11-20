clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list    = [1:4 8:17];

cnd_freq    = {'CnD.7t11Hz','CnD.11t15Hz'};
cnd_time    = {'m600m200','p200p600','p600p1000'};
cnd_end     = {'dpssNew0.1%Source','dpssNew1%Source'};


for sb = 1:length(suj_list)
    for next = 1:length(cnd_end)
        for nfreq = 1:length(cnd_freq)
            
            suj = ['yc' num2str(suj_list(sb))];
            
            for ntime = 1:length(cnd_time)
                
                for cp = 1:3
                    
                    fname = ['../data/revised_paper_source/' suj '.pt' num2str(cp) '.' cnd_freq{nfreq} '.' cnd_time{ntime}  ...
                        '.' cnd_end{next} '.mat'];
                    
                    fprintf('Loading %50s\n',fname);
                    
                    load(fname);
                    
                    if isstruct(source);
                        source = source.avg.pow;
                    end
                    
                    src_carr{cp} = source ; clear source ;
                    
                end
                
                load ../data/template/template_grid_0.5cm.mat
                
                source_avg{sb,ntime,nfreq,next}.pow        = nanmean([src_carr{1} src_carr{2} src_carr{3}],2);
                source_avg{sb,ntime,nfreq,next}.pos        = template_grid.pos;
                source_avg{sb,ntime,nfreq,next}.dim        = template_grid.dim;
                
                clear src_carr
                
            end
        end
    end
end

clearvars -except source_avg cnd_*; clc ;

cfg                                =   [];
cfg.dim                            =   source_avg{1}.dim;
cfg.method                         =   'montecarlo';
cfg.statistic                      =   'depsamplesT';
cfg.parameter                      =   'pow';
cfg.correctm                       =   'cluster';
cfg.clusteralpha                   =   0.05;             % First Threshold

cfg.clusterstatistic               =   'maxsum';
cfg.numrandomization               =   1000;
cfg.alpha                          =   0.025;
cfg.tail                           =   0;
cfg.clustertail                    =   0;
nsuj                               =   length(source_avg);
cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                           =   1;
cfg.ivar                           =   2;

for ntime = 1:length(cnd_time)-1
    for nfreq = 1:length(cnd_freq)
        for next = 1:length(cnd_end)
            
            stat{ntime,nfreq,next}         =   ft_sourcestatistics(cfg, source_avg{:,ntime+1,nfreq,next},source_avg{:,1,nfreq,next});
            
        end
    end
end

for ntime = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for next = 1:size(stat,3)
            for iside = [1 2]
                
                lst_side                        = {'left','right','both'};
                lst_view                        = [-95 1;95 1;0 50];
                
                z_lim                           = 6;
                
                clear source ;
                
                stoplot                         = stat{ntime,nfreq,next};
                
                stoplot.mask                    = stoplot.prob < 0.05;
                
                source.pos                      = stoplot.pos ;
                source.dim                      = stoplot.dim ;
                tpower                          = stoplot.stat .* stoplot.mask;
                tpower(tpower==0)               = NaN;
                
                source.pow                      = tpower ; clear tpower;
                
                cfg                             =   []; cfg.method                    =   'surface'; cfg.funparameter          =   'pow';
                cfg.funcolorlim                 =   [-z_lim z_lim];
                cfg.opacitylim                  =   [-z_lim z_lim];
                cfg.opacitymap                  =   'rampup'; cfg.colorbar            =   'off'; cfg.camlight                  =   'no';
                cfg.projmethod                  =   'nearest';
                cfg.surffile                    =   ['surface_white_' lst_side{iside} '.mat'];
                cfg.surfinflated                =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                ft_sourceplot(cfg, source);
                view(lst_view(iside,:))
                
                fname_1                         = '~/GoogleDrive/PhD/Publications/Papers/alpha2017/eNeuro/prep/source_revised/corr.';
                fname_2                         = [cnd_time{ntime+1} '.' cnd_freq{nfreq} '.' cnd_end{next}];
                
                title(fname_2)
                
                saveas(gcf,[fname_1 fname_2 '.' num2str(iside) '.png'])
                
                close all;
                
            end
        end
    end
end
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_list    = [1:4 8:17];

cnd_freq    = {'20t30Hz','60t100Hz'};
cnd_time    = {'m600m200','p600p1000'}; 
ext_end     = '.dpssNewMinEvoked5%Source';

for nfreq = 1:length(cnd_freq)
    
    for sb = 1:length(suj_list)
        
        suj = ['yc' num2str(suj_list(sb))];
        
        for ntime = 1:length(cnd_time)
            
            for cp = 1:3
                
                if nfreq ==1
                    fname = ['/Volumes/heshamshung/Fieldtripping6Dec2018/data/prep21_thetabeta/' suj '.pt' num2str(cp) '.CnD.' cnd_freq{nfreq}  '.' cnd_time{ntime}      ...
                        ext_end '.mat'];
                else
                    fname = ['/Volumes/heshamshung/Fieldtripping6Dec2018/data/prep21_gamma_dics_data/' suj '.pt' num2str(cp) '.CnD.' cnd_freq{nfreq} '.' cnd_time{ntime}       ...
                        ext_end '.mat'];
                end
                
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

cfg                                 =   [];
cfg.dim                             =   source_avg{1}.dim;
cfg.method                          =   'montecarlo';
cfg.statistic                       =   'depsamplesT';
cfg.parameter                       =   'pow';
cfg.correctm                        =   'fdr';

cfg.clusterstatistic                =   'maxsum';
cfg.numrandomization                =   1000;
cfg.alpha                           =   0.025;

cfg.tail                            =   0; % !!!
cfg.clustertail                     =   0; % !!!

cfg.clusteralpha                    =   0.05;             % First Threshold cluster_alpha; % 

nsuj                                =   length(source_avg);
cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
cfg.uvar                            =   1;
cfg.ivar                            =   2;

nfreq                               =   1;

for nfreq = 1:size(source_avg,3)
    stat{nfreq}                     = ft_sourcestatistics(cfg, source_avg{:,2,nfreq},source_avg{:,1,nfreq});
end

for ntest = 1:length(stat)
    [min_p(ntest),p_val{ntest}] = h_pValSort(stat{ntest});
end

clearvars -except source_avg cnd_freq cnd_time stat min_p p_val;

for ntest = 1:length(stat)
    for iside = [1 2]
        
        lst_side                      = {'left','right','both'};
        lst_view                      = [-95 1;95 1;0 50];
        
        z_lim                         = 5;
        
        clear source ;
        
        stoplot                       = stat{ntest};
        
        stoplot.mask                  = stoplot.prob < 0.005;
        
        source.pos                    = stoplot.pos ;
        source.dim                    = stoplot.dim ;
        tpower                        = stoplot.stat .* stoplot.mask;
        tpower(tpower==0)             = NaN;
        
        source.pow                    =   tpower ; clear tpower;
        
        cfg                           =   []; 
        cfg.method                    =   'surface'; 
        cfg.funparameter              =   'pow';
        cfg.funcolorlim               =   [-z_lim z_lim];
        cfg.opacitylim                =   [-z_lim z_lim];
        cfg.opacitymap                =   'rampup'; 
        cfg.colorbar                  =   'off'; 
        cfg.camlight                  =   'no';
        cfg.projmethod                =   'nearest';
        cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
        cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
        ft_sourceplot(cfg, source);
        view(lst_view(iside,:))
        
        title(cnd_freq{ntest});
        
    end
end
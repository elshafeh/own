clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data_fieldtrip/template/template_grid_1cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'7t11Hz','11t15Hz'};
    list_time   = {'m600m200','p600p1000'};
    list_cue    = {'CnD','RCnD','RNCnD','LCnD','LNCnD'};
    
    
    for ncue = 1:length(list_cue)
        for nfreq = 1:length(list_freq)
            for ntime = 1:length(list_time)
                
                fname_in = ['../data/' suj '/field/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.WholeBrainNetWork.1cm.mat'];

                fprintf('Loading %s\n',fname_in);
                load(fname_in)
                
                source.pow  = source_network;
                source.pos  = template_grid.pos;
                source.dim  = template_grid.dim;

                source_gavg{sb,ncue,nfreq,ntime} = source;
                
                clear flg source
                    
                
                clear source_plv
                
            end
        end
    end
end

clearvars -except source_gavg list_* *_list

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        
        cfg                                =   [];
        cfg.dim                            =   source_gavg{1}.dim;
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
        
        nsuj                               =   size(source_gavg,1);
        
        cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
        cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
        cfg.uvar                           =   1;
        cfg.ivar                           =   2;
        
        stat{ncue,nfreq}                   =   ft_sourcestatistics(cfg, source_gavg{:,ncue,nfreq,2},source_gavg{:,ncue,nfreq,1});
        stat{ncue,nfreq}                   =   rmfield(stat{ncue,nfreq},'cfg');
        
    end
end


for ncue = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        [min_p(ncue,nfreq),p_val{ncue,nfreq}]     = h_pValSort(stat{ncue,nfreq});
    end
end

p_limit = 0.1;

for ncue = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        
        if min_p(ncue,nfreq) < p_limit
            
            for iside = 1:3
                
                lst_side                = {'left','right','both'};
                lst_view                = [-95 1;95,11;0 50];
                
                z_lim                   = 5;
                
                clear source ;
                
                stolplot                = stat{ncue,nfreq};
                stolplot.mask           = stolplot.prob < p_limit;
                
                source.pos              = stolplot.pos ;
                source.dim              = stolplot.dim ;
                tpower                  = stolplot.stat .* stolplot.mask;
                tpower(tpower == 0)     = NaN;
                source.pow              = tpower ; clear tpower;
                
                cfg                     =   [];
                cfg.funcolormap         = 'jet';
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
                view(lst_view(iside,:))
                
            end
            
        end
    end
end


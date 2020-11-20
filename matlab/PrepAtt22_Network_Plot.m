clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); clc ;

load ../data/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'7t11Hz','11t15Hz','7t15Hz'};
    list_time   = {'m700m200','p600p1100'};
    list_mesure = {'plv','powcorr','coh'};
    
    for nfreq = 1:length(list_freq)
        for nmes = 1:length(list_mesure)
            
            list_cue    = {'RCnD','LCnD','NCnD'};
            
            for ncue = 1:length(list_cue)
                for ntime = 1:length(list_time)
                    
                    ext_essai   = '.100SlctMinEvoked0.5cm';
                    fname_in    = ['../data/pat22_data/' suj '.' list_cue{ncue} '.' list_time{ntime} '.' list_freq{nfreq} '.' list_mesure{nmes} 'Network' ext_essai '.mat'];
                    
                    fprintf('Loading %s\n',fname_in);
                    load(fname_in)
                    
                    source_gavg{sb,ncue,nfreq,nmes,ntime}.pow = network_full; %
                    source_gavg{sb,ncue,nfreq,nmes,ntime}.pos = template_grid.pos;
                    source_gavg{sb,ncue,nfreq,nmes,ntime}.dim = template_grid.dim;
                    
                    clear network_full
                    
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list ;

for ncue = 1:size(source_gavg,2)
    for nfreq = 1:size(source_gavg,3)
        for nmes = 1:size(source_gavg,4)
            for ntime = 1:size(source_gavg,5)
                grand_avearge{ncue,nfreq,nmes,ntime}              =   ft_sourcegrandaverage([], source_gavg{:,ncue,nfreq,nmes,ntime});
            end
        end
    end
end

clearvars -except sourc
e_gavg list_* stat grand_avearge

for ncue = 1:size(source_gavg,2)
    for nfreq = 1:size(source_gavg,3)
        for nmes = 1:size(source_gavg,4)
            for ntime = 1:size(source_gavg,5)
                
                for iside = 3
                    
                    
                    lst_side                = {'left','right','both'};
                    lst_view                = [-95 1;95 1;0 50];
                    
                    z_lim                   = 36000;
                    
                    clear source ;
                    
                    source                  = grand_avearge{ncue,nfreq,nmes,ntime};
                    source.pow              = source.pow/10000;
                    
                    cfg                     =   [];
                    cfg.method              =   'surface';
                    cfg.funparameter        =   'pow';
                    %                     cfg.funcolorlim         =   [2 3.5];
                    %                     cfg.opacitylim          =   [2 3.5];
                    cfg.opacitymap          =   'rampup';
                    cfg.colorbar            =   'off';
                    cfg.camlight            =   'no';
                    cfg.projmethod          =   'nearest';
                    cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:))
                    title([list_cue{ncue} '.' list_freq{nfreq} '.' list_mesure{nmes} '.' list_time{ntime}]);
                    
                end
            end
        end
    end
end
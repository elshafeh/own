clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    list_filter             = {'concWindowFilter'};%,'largeWindowFilter'};
    list_time               = {'p650p850ms'}; %,'p850p1050ms','p1000p1200ms'};
    
    ext_bsl                 = 'm250m50ms';
    
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        cond_main           = {'CnD'};
        
        for nfilt = 1:length(list_filter)
            for ntime = 1:length(list_time)
                for ncue = 1:length(cond_main)
                    
                    fname = ['../data/' suj '/field/' suj '.' cond_main{ncue} '.' list_filter{nfilt} '.' ext_bsl '.lcmvSource.mat'];
                    
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source            = source; clear source
                    
                    fname = ['../data/' suj '/field/' suj '.' cond_main{ncue} '.' list_filter{nfilt} '.' list_time{ntime} '.lcmvSource.mat'];
                    
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source            = source; clear source
                    
                    pow                                   = (act_source-bsl_source)./bsl_source;
                    
                    source_avg{ngroup}{sb,ncue,nfilt,ntime}.pow            = pow;
                    source_avg{ngroup}{sb,ncue,nfilt,ntime}.pos            = template_grid.pos ;
                    source_avg{ngroup}{sb,ncue,nfilt,ntime}.dim            = template_grid.dim ;
                    source_avg{ngroup}{sb,ncue,nfilt,ntime}.inside         = template_grid.inside;
                    
                    clear act_source bsl_source pow
                end
                
            end
        end
        
    end
end

clearvars -except source_avg list*;

for ngroup = 1:length(source_avg)
    for ncue = 1:size(source_avg{ngroup},2)
        for nfilt = 1:size(source_avg{ngroup},3)
            for ntime = 1:size(source_avg{ngroup},4)
                
                source_grand_average{ngroup}{ncue,nfilt,ntime} = ft_sourcegrandaverage([],source_avg{ngroup}{:,ncue,nfilt,ntime});
                
            end
        end
    end
end

for ngroup = 1:length(source_avg)
    for ncue = 1:size(source_avg{ngroup},2)
        for nfilt = 1:size(source_avg{ngroup},3)
            for ntime = 1:size(source_avg{ngroup},4)
                
                source = source_grand_average{ngroup}{ncue,nfilt,ntime} ;
                source.pow(isnan(source.pow)) = 0;
                
                for iside = 3
                    
                    z_lim                   = 0.1;
                    
                    lst_side                = {'left','right','both'};
                    lst_view                = [-95 1;95 11;0 50];
                    
                    cfg                     =   [];
                    cfg.method              =   'surface';
                    cfg.funparameter        =   'pow';
                    cfg.funcolorlim         =   [-z_lim z_lim];
                    cfg.opacitylim          =   [-z_lim z_lim];
                    cfg.opacitymap          =   'rampup';
                    cfg.colorbar            =   'off';
                    cfg.camlight            =   'no';
                    cfg.projmethod          =   'nearest';
                    cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                    cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                    
                    ft_sourceplot(cfg, source);
                    view(lst_view(iside,:))
                    
                    title([list_filter{nfilt} '.' list_time{ntime} '.' list_test{ntest}]);
                    
                end
                
            end
        end
    end
end
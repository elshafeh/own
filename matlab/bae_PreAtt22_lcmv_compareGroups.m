clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    list_filter             = {'concWindowFilter','largeWindowFilter'};
    list_time               = {'p550p800ms'};
    
    ext_bsl                 = 'm300m50ms';
    
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        cond_main           = {'VCnD','RCnD','LCnD','NCnD'};
        
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
                    
                    pow                                                     = (act_source-bsl_source)./bsl_source;
                    pow(isnan(pow))                                         = 0;
                    
                    source_avg{ngroup}{sb,ncue,nfilt,ntime}.pow             = pow;
                    source_avg{ngroup}{sb,ncue,nfilt,ntime}.pos             = template_grid.pos ;
                    source_avg{ngroup}{sb,ncue,nfilt,ntime}.dim             = template_grid.dim ;
                    source_avg{ngroup}{sb,ncue,nfilt,ntime}.inside          = template_grid.inside;
                    
                    clear act_source bsl_source pow
                    
                    
                end
                
                list_to_subtract                                                = [1 4; 2 4; 3 4; 2 3];
                index_cue                                                       = 4;
                
                for nadd = 1:length(list_to_subtract)
                    
                    cond1                                                       = source_avg{ngroup}{sb,list_to_subtract(nadd,1),nfilt,ntime}.pow;
                    cond2                                                       = source_avg{ngroup}{sb,list_to_subtract(nadd,2),nfilt,ntime}.pow;
                    
                    pow                                                         = cond1-cond2;
                    pow(isnan(pow))                                             = 0;
                    
                    source_avg{ngroup}{sb,index_cue+nadd,nfilt,ntime}.pow       = pow;
                    source_avg{ngroup}{sb,index_cue+nadd,nfilt,ntime}.pos       = template_grid.pos ;
                    source_avg{ngroup}{sb,index_cue+nadd,nfilt,ntime}.dim       = template_grid.dim;
                    source_avg{ngroup}{sb,index_cue+nadd,nfilt,ntime}.inside    = template_grid.inside;
                    
                end
                
            end
        end
        
    end
end

clearvars -except source_avg list_* ;

list_test                           = 5:8;

for ntest = 1:length(list_test)
    for nfilt = 1:size(source_avg{1},3)
        for ntime = 1:size(source_avg{1},4)
            
            cfg                         =   [];
            cfg.dim                     =  source_avg{1}{1}.dim;
            cfg.method                  =  'montecarlo';
            cfg.statistic               = 'indepsamplesT';
            cfg.parameter               = 'pow';
            cfg.correctm                = 'cluster';
            
            cfg.clusteralpha            = 0.05;             % First Threshold
            
            cfg.clusterstatistic        = 'maxsum';
            cfg.numrandomization        = 1000;
            cfg.alpha                   = 0.025;
            cfg.tail                    = 0;
            cfg.clustertail             = 0;
            
            nsuj                        = size(source_avg{1},1);
            
            cfg.design                  = [ones(1,nsuj) ones(1,nsuj)*2];
            cfg.ivar                    = 1;
            
            stat{ntest,nfilt,ntime}     = ft_sourcestatistics(cfg, source_avg{2}{:,list_test(ntest),nfilt,ntime},source_avg{1}{:,list_test(ntest),nfilt,ntime});
            
            
        end
    end
end

clearvars -except source_avg list_* stat min_p p_val;

for ntest = 1:size(stat,1)
    for nfilt = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            [min_p(ntest,nfilt,ntime),p_val{ntest,nfilt,ntime}]     = h_pValSort(stat{ntest,nfilt,ntime});
        end
    end
end

clearvars -except source_avg list_* stat min_p p_val;

p_limit = 0.05;

list_test                                   = {'VmN','RmN','LmN','RmL'};

for ntest = 1:size(stat,1)
    for nfilt = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            
            stolplot                        = stat{ntest,nfilt,ntime};
            
            stolplot.mask                   = stolplot.prob < p_limit;
            
            source.pos                      = stolplot.pos ;
            source.dim                      = stolplot.dim ;
            tpower                          = stolplot.stat .* stolplot.mask;
            
            tpower(tpower == 0)             = NaN;
            source.pow                      = tpower ; clear tpower;
            
            if nanmin(source.pow) < p_limit
                for iside = 3
                    
                    lst_side                = {'left','right','both'};
                    lst_view                = [-95 1;95,11;0 50];
                    
                    z_lim                   = 5;
                    
                    clear source ;
                    
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
                    view(lst_view(iside,:));
                    
                    title([list_time{ntime} '.' list_test{ntest}]);
                    
                end
            end
        end
    end
end
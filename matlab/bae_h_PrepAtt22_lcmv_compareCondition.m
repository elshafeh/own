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
    for nfilt = 1:size(source_avg{ngroup},3)
        for ntime = 1:size(source_avg{ngroup},4)
            
            ix_test = [1 4; 2 4; 3 4; 2 3];
            
            for ntest = 1:size(ix_test,1)
                
                cfg                                =   [];
                cfg.dim                            =   source_avg{1}{1}.dim;
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
                
                nsuj                               =   size(source_avg{ngroup},1);
                
                cfg.design(1,:)                    =   [1:nsuj 1:nsuj];
                cfg.design(2,:)                    =   [ones(1,nsuj) ones(1,nsuj)*2];
                cfg.uvar                           =   1;
                cfg.ivar                           =   2;
                
                stat{ngroup,nfilt,ntime,ntest}     =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,ix_test(ntest,1),nfilt,ntime},source_avg{ngroup}{:,ix_test(ntest,2),nfilt,ntime});
                stat{ngroup,nfilt,ntime,ntest}     =   rmfield(stat{ngroup,nfilt,ntime,ntest},'cfg');
                
                
            end
        end
    end
end

clearvars -except source_avg stat list*;

for ngroup = 1:size(stat,1)
    for nfilt = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                
                [min_p(ngroup,nfilt,ntime,ntest),p_val{ngroup,nfilt,ntime,ntest}]      = h_pValSort(stat{ngroup,nfilt,ntime,ntest});
                
            end
        end
    end
end

clearvars -except source_avg stat min_p p_val list*;

p_limit = 0.05;

i = 0 ; clear who_seg ,

list_test       = {'VmN','RmN','LmN','RmL'};
list_group      = {'Old','Young'};

for ngroup = 1:size(stat,1)
    for nfilt = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                
                if min_p(ngroup,nfilt,ntime,ntest) < p_limit
                    
                    i = i + 1;
                    
                    who_seg{i,1} = [list_group{ngroup} '.' list_filter{nfilt} '.' list_time{ntime} '.' list_test{ntest}];
                    who_seg{i,2} = min_p(ngroup,nfilt,ntime,ntest);
                    who_seg{i,3} = p_val{ngroup,nfilt,ntime,ntest};
                    
                    who_seg{i,4} = FindSigClusters(stat{ngroup,nfilt,ntime,ntest},p_limit);                    
                    
                end
            end
        end
    end
end


for ngroup = 1:size(stat,1)
    for nfilt = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                for iside = 3
                    
                    if min_p(ngroup,nfilt,ntime,ntest) < p_limit
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95,11;0 50];
                        
                        z_lim                   = 3;
                        
                        clear source ;
                        
                        stolplot                = stat{ngroup,nfilt,ntime,ntest};
                        stolplot.mask           = stolplot.prob < p_limit;
                        
                        source.pos              = stolplot.pos ;
                        source.dim              = stolplot.dim ;
                        tpower                  = stolplot.stat .* stolplot.mask;
                        tpower(tpower == 0)     = NaN;
                        source.pow              = tpower ; clear tpower;
                        
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
                        
                        
                        title([list_group{ngroup} '.' list_filter{nfilt} '.' list_time{ntime} '.' list_test{ntest}]);
                        
                    end
                end
            end
        end
    end
end
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

load ../data/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    lst_freq    = {'60t80Hz'};
    lst_time    = {'p100p200'};
    
    lst_bsl     = 'm300m200'; % m200m100 m300m200
    
    ext_comp    = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        cond_main           = {'nDTR','nDTL'}; 
        
        for nfreq = 1:length(lst_freq)
            for ntime = 1:length(lst_time)
                for cnd_cue = 1:length(cond_main)
                    
                    fname = ['../data/dis_rep4rev/' suj '.' cond_main{cnd_cue} '.' lst_freq{nfreq} '.' lst_bsl '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source            = source; clear source
                    
                    fname = ['../data/dis_rep4rev/' suj '.' cond_main{cnd_cue} '.' lst_freq{nfreq} '.' lst_time{ntime} '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source            = source; clear source
                    
                    pow                                                       = (act_source-bsl_source)./bsl_source;
                    
                    source_avg{ngroup}{sb,cnd_cue,nfreq,ntime}.pow            = pow;
                    source_avg{ngroup}{sb,cnd_cue,nfreq,ntime}.pos            = template_grid.pos ;
                    source_avg{ngroup}{sb,cnd_cue,nfreq,ntime}.dim            = template_grid.dim ;
                    source_avg{ngroup}{sb,cnd_cue,nfreq,ntime}.inside         = template_grid.inside;
                    
                    clear act_source bsl_source pow
                end
                
            end
        end
        
    end
end

clearvars -except source_avg lst*;

for ngroup = 1:length(source_avg)
    for nfreq = 1:size(source_avg{ngroup},3)
        for ntime = 1:size(source_avg{ngroup},4)
            
            ix_test = [1 2];
            
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
                
                stat{ngroup,nfreq,ntime,ntest}     =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,ix_test(ntest,1),nfreq,ntime},source_avg{ngroup}{:,ix_test(ntest,2),nfreq,ntime});
                stat{ngroup,nfreq,ntime,ntest}     =   rmfield(stat{ngroup,nfreq,ntime,ntest},'cfg');
                
                
            end
        end
    end
end

clearvars -except source_avg stat lst*;

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                
                [min_p(ngroup,nfreq,ntime,ntest),p_val{ngroup,nfreq,ntime,ntest}]      = h_pValSort(stat{ngroup,nfreq,ntime,ntest});
                
            end
        end
    end
end

clearvars -except source_avg stat min_p p_val lst*;

p_limit = 0.2;

i = 0 ; clear who_seg ,

list_test   = {'RvL'}; % 'RmNR','LmLN','RL'};

for ngroup = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                for iside = 3
                    
                    if min_p(ngroup,nfreq,ntime,ntest) < p_limit
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95,11;0 50];
                        
                        z_lim                   = 5;
                        
                        clear source ;
                        
                        stolplot                = stat{ngroup,nfreq,ntime,ntest};
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
                        
                        
                        title([lst_freq{nfreq} ' ' lst_time{ntime} ' ' list_test{ntest}]);
                        
                    end
                end
            end
        end
    end
end
clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

load ../data_fieldtrip/template/template_grid_0.5cm.mat

% [~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj = suj_list{sb};
        
        cond_main       = {'V1','R1','L1','N1'}; %
        
        list_freq       = {'p350p650'};
        
        list_time       = {'7t13Hz'};
        
        %         ext_comp        = 'NewBroadAreas.mat';
        
        
        for ntime = 1:length(list_time)
            for nfreq = 1:length(list_freq)
                
                for cnd_cue = 1:length(cond_main)
                    
                    ext_comp = 'dpssFixedCommonDicSourceMinEvoked0.5cm.mat';
                    
                    fname = ['../data/' suj '/field/' suj '.' 'fDIS'  cond_main{cnd_cue}   '.' list_time{ntime} '.' list_freq{nfreq}   '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    bsl_source            = source; clear source
                    
                    fname = ['../data/' suj '/field/' suj '.' 'DIS'   cond_main{cnd_cue} '.' list_time{ntime}  '.' list_freq{nfreq}   '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    act_source                                                = source; clear source ;
                    
                    pow                                                       = act_source-bsl_source; %act_source; % act_source-bsl_source; % (act_source-bsl_source)./bsl_source; %!!!!!!!!!!
                    
                    pow(isnan(pow))                                           = 0;
                    
                    source_avg{ngroup}{sb,cnd_cue,ntime,nfreq}.pow            = pow;
                    source_avg{ngroup}{sb,cnd_cue,ntime,nfreq}.pos            = template_grid.pos ;
                    source_avg{ngroup}{sb,cnd_cue,ntime,nfreq}.dim            = template_grid.dim ;
                    source_avg{ngroup}{sb,cnd_cue,ntime,nfreq}.inside         = template_grid.inside;
                    
                    clear act_source bsl_source pow
                
                end
            end
        end
    end
end

clearvars -except source_avg list*;

for ngroup = 1:length(source_avg)
    
    ix_test                                        =   [3 2]; %[1 4; 2 4; 3 4];
    
    for ntest = 1:size(ix_test,1)
        for ntime = 1:length(list_time)
            for nfreq = 1:length(list_freq)
                
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
                
                stat{ngroup,ntest,ntime,nfreq}     =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,ix_test(ntest,1),ntime,nfreq},source_avg{ngroup}{:,ix_test(ntest,2),ntime,nfreq});
                stat{ngroup,ntest,ntime,nfreq}     =   rmfield(stat{ngroup,ntest,ntime,nfreq},'cfg');
                
            end
        end
    end
    
end

clearvars -except source_avg list* stat;

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for nfreq = 1:size(stat,4)
                [min_p(ngroup,ntest,ntime,nfreq),p_val{ngroup,ntest,ntime,nfreq}]      = h_pValSort(stat{ngroup,ntest,ntime,nfreq});
            end
        end
    end
end

p_limit     = 0.1;

i = 0 ;

clear who_seg ;

list_group = {'AllYoung'};

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for nfreq = 1:size(stat,4)
                if min_p(ngroup,ntest,ntime,nfreq) < p_limit
                    
                    i = i + 1;
                    
                    who_seg{i,1} = [list_group{ngroup} '.' list_time{ntime} '.' list_freq{nfreq}];
                    who_seg{i,2} = min_p(ngroup,ntest,ntime,nfreq);
                    who_seg{i,3} = p_val{ngroup,ntest,ntime,nfreq};
                    
                    who_seg{i,4} = FindSigClusters(stat{ngroup,ntest,ntime,nfreq},p_limit);
                    who_seg{i,5} = FindSigClustersWithCoordinates(stat{ngroup,ntest,ntime,nfreq},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                    
                    
                end
            end
        end
    end
end

for ngroup = 1:size(stat,1)
    for ntest = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for nfreq = 1:size(stat,4)
                if min_p(ngroup,ntest,ntime,nfreq) < p_limit
                    
                    for iside = 3; %[2 2]
                        
                        
                        lst_side                      = {'left','right','both'};
                        lst_view                      = [-95 1;95,11;0 50];
                        
                        z_lim                         = 3; clear source ;
                        
                        s2plot                        = stat{ngroup,ntest,ntime,nfreq};
                        
                        s2plot.mask                   = s2plot.prob < p_limit;
                        
                        source.pos                    = s2plot.pos ;
                        source.dim                    = s2plot.dim ;
                        tpower                        = s2plot.stat .* s2plot.mask;
                        
                        tpower(tpower == 0)           = NaN;
                        
                        source.pow                    = tpower ; clear tpower;
                        
                        cfg                           =   [];
                        cfg.method                    =   'surface';
                        cfg.funparameter              =   'pow';
                        cfg.funcolorlim               =   [-z_lim z_lim];
                        cfg.opacitylim                =   [-z_lim z_lim];
                        cfg.opacitymap                =   'rampup';
                        cfg.colorbar                  =   'off';
                        cfg.camlight                  =   'no';
                        cfg.projthresh                =   0.2;
                        cfg.projmethod                =   'nearest';
                        cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
                        cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                        
                        ft_sourceplot(cfg, source);
                        view(lst_view(iside,:));
                        
                        %                         title([list_time{ntime} '.' list_freq{nfreq}])
                        
                    end
                end
            end
        end
    end
end

% for cond = 1:2
%     grand_average{cond} = ft_sourcegrandaverage([],source_avg{1}{:,cond});
% end
%
% iside = 3;
%
% for cond = 1:2
%
%     source                        = grand_average{cond};
%     source.pow                    = source.pow/1e+20;
%     %     source.pow                    = source.pow .* stat{1}.mask;
%
%     source.pow(source.pow == 0)     = NaN;
%
%     z_lim                         = 1;
%
%     cfg                           =   [];
%     cfg.method                    =   'surface';
%     cfg.funparameter              =   'pow';
%     cfg.funcolorlim               =   [-z_lim z_lim];
%     cfg.opacitylim                =   [-z_lim z_lim];
%     cfg.opacitymap                =   'rampup';
%     cfg.colorbar                  =   'off';
%     cfg.camlight                  =   'no';
%     cfg.projmethod                =   'nearest';
%     cfg.surffile                  =   ['surface_white_' lst_side{iside} '.mat'];
%     cfg.surfinflated              =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
%
%     ft_sourceplot(cfg, source);
%
% end
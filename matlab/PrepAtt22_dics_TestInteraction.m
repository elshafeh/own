clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'old','young'};

load ../data_fieldtrip/template/template_grid_0.5cm.mat

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    lst_freq    = {'7t11Hz','11t15Hz'};
    
    lst_time    = {'p200p600','p600p1000'};
    
    lst_bsl     = 'm600m200';
    
    lst_comp    = {'dpssFixedCommonDicSource.mat','dpssFixedCommonDicSource80Slct0.5cm.mat'};
    
    lst_test    = {};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        cond_main           = {'RCnD','NRCnD','LCnD','NLCnD','NCnD'};
        
        for ncomp = 1:length(lst_comp)
            for nfreq = 1:length(lst_freq)
                for ntime = 1:length(lst_time)
                    for cnd_cue = 1:length(cond_main)
                        
                        
                        fname = ['../data/' suj '/field/' suj '.' cond_main{cnd_cue} '.' lst_freq{nfreq} '.' lst_bsl '.' lst_comp{ncomp}];
                        fprintf('Loading %50s\n',fname);
                        load(fname);
                        
                        bsl_source            = source; clear source
                        
                        fname = ['../data/' suj '/field/' suj '.' cond_main{cnd_cue} '.' lst_freq{nfreq} '.' lst_time{ntime} '.' lst_comp{ncomp}];
                        fprintf('Loading %50s\n',fname);
                        load(fname);
                        
                        act_source                       = source; clear source
                        pow                              = (act_source-bsl_source)./bsl_source;
                        pow(isnan(pow))                  = 0;
                        
                        tmp_carr{cnd_cue}.pow            = pow;
                        tmp_carr{cnd_cue}.pos            = template_grid.pos ;
                        tmp_carr{cnd_cue}.dim            = template_grid.dim ;
                        tmp_carr{cnd_cue}.inside         = template_grid.inside;
                        
                        clear act_source bsl_source pow
                    end
                    
                    ix_test = [1 2; 3 4; 1 3; 1 5; 3 5];
                    
                    for ntest = 1:size(ix_test,1)

                        source_avg{ngroup}{sb,ncomp,nfreq,ntime,ntest}      = tmp_carr{ix_test(ntest,1)};
                        source_avg{ngroup}{sb,ncomp,nfreq,ntime,ntest}.pow  = tmp_carr{ix_test(ntest,1)}.pow - tmp_carr{ix_test(ntest,2)}.pow;
                        
                        source_avg{ngroup}{sb,ncomp,nfreq,ntime,ntest}.pow(isnan(source_avg{ngroup}{sb,ncomp,nfreq,ntime,ntest}.pow)) = 0;
                        
                        lst_test{ntest} = [cond_main{ix_test(ntest,1)} 'v' cond_main{ix_test(ntest,2)}]; 
                        
                    end
                    
                end
            end
        end
    end
end

clearvars -except source_avg lst*;

for ncomp = 1:size(source_avg{1},2)
    for nfreq = 1:size(source_avg{ncomp},3)
        for ntime = 1:size(source_avg{ncomp},4)
            for ntest = 1:size(source_avg{ncomp},5)
                
                cfg                     =  [];
                cfg.dim                 =  source_avg{1}{1}.dim;
                cfg.method              =  'montecarlo';
                cfg.statistic           = 'indepsamplesT';
                cfg.parameter           = 'pow';
                cfg.correctm            = 'cluster';
                cfg.clusteralpha        = 0.05;             % First Threshold
                
                cfg.clusterstatistic    = 'maxsum';
                cfg.numrandomization    = 1000;
                cfg.alpha               = 0.025;
                cfg.tail                = 0;
                cfg.clustertail         = 0;
                
                nsuj                    = length([source_avg{1}{:,ncomp,nfreq,ntime,ntest}]);
                
                cfg.design              = [ones(1,nsuj) ones(1,nsuj)*2];
                cfg.ivar                = 1;
                
                stat{ncomp,nfreq,ntime,ntest}     =   ft_sourcestatistics(cfg, source_avg{2}{:,ncomp,nfreq,ntime,ntest},source_avg{1}{:,ncomp,nfreq,ntime,ntest});
                stat{ncomp,nfreq,ntime,ntest}     =   rmfield(stat{ncomp,nfreq,ntime,ntest},'cfg');
                
                
            end
        end
    end
end

clearvars -except source_avg stat lst*;

for ncomp = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                
                [min_p(ncomp,nfreq,ntime,ntest),p_val{ncomp,nfreq,ntime,ntest}]      = h_pValSort(stat{ncomp,nfreq,ntime,ntest});
                
            end
        end
    end
end

clearvars -except source_avg stat min_p p_val lst*;

p_limit = 0.11;

i = 0 ; clear who_seg ,


for ncomp = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                
                if min_p(ncomp,nfreq,ntime,ntest) < p_limit
                    
                    
                    i = i + 1;
                    
                    who_seg{i,1} = [lst_comp{ncomp} '.' lst_freq{nfreq} '.' lst_time{ntime} '.' lst_test{ntest}];
                    who_seg{i,2} = min_p(ncomp,nfreq,ntime,ntest);
                    who_seg{i,3} = p_val{ncomp,nfreq,ntime,ntest};
                    
                    who_seg{i,4} = FindSigClusters(stat{ncomp,nfreq,ntime,ntest},p_limit);
                    who_seg{i,5} = FindSigClustersWithCoordinates(stat{ncomp,nfreq,ntime,ntest},p_limit,'../data_fieldtrip/doc/FrontalCoordinates.csv',0.5);
                    
                    
                end
            end
        end
    end
end

for ncomp = 1:size(stat,1)
    for nfreq = 1:size(stat,2)
        for ntime = 1:size(stat,3)
            for ntest = 1:size(stat,4)
                for iside = 3
                    
                    if min_p(ncomp,nfreq,ntime,ntest) < p_limit
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95,11;0 50];
                        
                        z_lim                   = 5;
                        
                        clear source ;
                        
                        stolplot                = stat{ncomp,nfreq,ntime,ntest};
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
                        title([lst_comp{ncomp} '.' lst_freq{nfreq} '.' lst_time{ntime} '.' lst_test{ntest}]);
                        
                        %                         list_ix_group = {'old','young'};
                        %                         list_ix_freq  = {'low','high'};
                        %                         list_ix_test  = {'RvNR','LvNL','RvL','NRvNL','RvN','LvN'};
                        %                         title([list_ix_group{ngroup} '.' list_ix_freq{nfreq} '.' list_ix_test{ntest}]);
                        %
                        %                         title([lst_group{ncomp} '.' lst_freq{nfreq} '.' lst_time{ntime} '.' list_test{ntest}]);
                        
                    end
                end
            end
        end
    end
end
clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); clc ;

load ../data/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'60t100Hz.MinEvoked'};
    list_time   = {'fDIS.p100p300','DIS.p100p300'};
    
    load ../data/index/FrontalRegionsCombined.mat;
    list_mesure = {'plvConn.dpssFrontCombinedZBefore'};
    
    list_roi = {};
    
    for xi = 1:length(list_H)
        for yi = 1:length(list_mesure)
            list_roi{end+1} = [list_H{xi} '.' list_mesure{yi}];
        end
    end
    
    load ../data/index/Prep21RAudAlphaConnIndex.mat;
    list_mesure = {'plvConn.dpssAudRprep21ZBefore'};
    
    for xi = 1:length(list_H)
        for yi = 1:length(list_mesure)
            list_roi{end+1} = [list_H{xi} '.' list_mesure{yi}];
        end
    end
    
    load ../data/index/Prep21RAudAlphaConnIndex1Max.mat;
    list_mesure = {'plvConn.dpssPrep21RAudAlphaConnIndex1Max'};
    
    for xi = 1:length(list_H)
        for yi = 1:length(list_mesure)
            list_roi{end+1} = [list_H{xi} '.' list_mesure{yi}];
        end
    end
    
    load ../data/index/Prep21RAudAlphaConnIndex5Max.mat;
    list_mesure = {'plvConn.dpssPrep21RAudAlphaConnIndex5Max'};
    
    for xi = 1:length(list_H)
        for yi = 1:length(list_mesure)
            list_roi{end+1} = [list_H{xi} '.' list_mesure{yi}];
        end
    end
    
    list_mesure = {'mat'};
    list_cue    = {''};
    x_choose    = [];
    x_no_choose = [];
    
    for xi = 1:length(list_roi)
        
        ru1 = strfind(list_roi{xi},'Sup');
        ru2 = strfind(list_roi{xi},'Cin');
        
        if isempty(ru1) && isempty(ru2)
           x_choose    = [x_choose xi];
        else
           x_no_choose = [x_no_choose xi];
        end
    end
    
    list_roi    = list_roi(x_choose);
    
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                list_cue    = {'V','N'};
                
                for ncue = 1:length(list_cue)
                    
                    for ntime = 1:length(list_time)
                        
                        dir_data                                        = '../data/dis_Newfrontal_conn/';
                        
                        fname_in                                        = [dir_data suj '.' list_cue{ncue} ...
                            list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
                        
                        if exist(fname_in)
                            
                            fprintf('Loading %s\n',fname_in);
                            load(fname_in)
                            
                        else
                            
                            dir_data                                    = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/'];
                            fname_in                                    = [dir_data suj '.' list_cue{ncue} ...
                                list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
                            
                            fprintf('Loading %s\n',fname_in);
                            load(fname_in)
                            
                            dir_data                                    = '../data/dis_Newfrontal_conn/';
                            fname_out                                   = [dir_data suj '.' list_cue{ncue} ...
                                list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
                            
                            copyfile(fname_in,fname_out);
                            
                        end
                        
                        
                        tmp{ntime}          = source ; % source_ztransform; % source_ztransform   = .5.*log((1+source)./(1-source)); clear source ;
                        
                        clear source
                        
                    end
                    
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.pow = (tmp{2}-tmp{1})./tmp{1}; % tmp{2}; % tmp{2}-tmp{1} ;
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.pos = template_grid.pos;
                    source_gavg{sb,ncue,nfreq,nroi,nmes}.dim = template_grid.dim;
                    
                    clear tmp
                    
                end
                
                %                 list_to_subtract                = [1 3; 2 3];
                %                 index_cue                       = 3;
                %
                %                 for nadd = 1:length(list_to_subtract)
                %
                %                     source_gavg{sb,index_cue+nadd,nfreq,nroi,nmes}  = source_gavg{sb,list_to_subtract(nadd,1),nfreq,nroi,nmes} ;
                %
                %                     pow                                             = source_gavg{sb,list_to_subtract(nadd,1),nfreq,nroi,nmes}.pow - ...
                %                         source_gavg{sb,list_to_subtract(nadd,2),nfreq,nroi,nmes}.pow ;
                %
                %                     source_gavg{sb,index_cue+nadd,nfreq,nroi,nmes}.pow = pow; clear pow;
                %
                %                     list_cue{index_cue+nadd}                        = [list_cue{list_to_subtract(nadd,1)} 'm' list_cue{list_to_subtract(nadd,2)}];
                %                 end
                
            end
        end
    end
end

clearvars -except source_gavg list_* *_list ;

for nfreq = 1:length(list_freq)
    for nroi = 1:length(list_roi)
        for nmes = 1:length(list_mesure)
            
            ix_test                                = [1 2];
            list_test                              = {};
            
            for ntest = 1:size(ix_test,1)
                
                cfg                                =   [];
                cfg.dim                            =   source_gavg{1}.dim;
                cfg.method                         =   'montecarlo';
                cfg.statistic                      =   'depsamplesT';
                cfg.parameter                      =   'pow';
                
                cfg.correctm                       =   'cluster';
                
                cfg.clusteralpha                   =   0.01;             % First Threshold
                
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
                
                stat{nfreq,nroi,ntest,nmes}        =   ft_sourcestatistics(cfg, source_gavg{:,ix_test(ntest,1),nfreq,nroi,nmes},source_gavg{:,ix_test(ntest,2),nfreq,nroi,nmes});
                
                test_name                          = [list_cue{ix_test(ntest,1)} 'v' list_cue{ix_test(ntest,2)}];
                list_test                          = [list_test test_name];
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            for nmes = 1:size(stat,4)
                [min_p(nfreq,nroi,ntest,nmes),p_val{nfreq,nroi,ntest,nmes}]     = h_pValSort(stat{nfreq,nroi,ntest,nmes});
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val

p_limit     = 0.2;
who_seg     = {};
i           = 0;

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            for nmes = 1:size(stat,4)
                
                for iside = [1 2]
                    
                    if min_p(nfreq,nroi,ntest,nmes) < p_limit
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-95 1;95 1;0 50];
                        
                        z_lim                   = p_limit;
                        
                        clear source ;
                        
                        stolplot                = stat{nfreq,nroi,ntest,nmes};
                        stolplot.mask           = stolplot.prob < p_limit;
                        
                        source.pos              = stolplot.pos ;
                        source.dim              = stolplot.dim ;
                        
                        stolplot.stat(stolplot.stat <0)     = -1;
                        stolplot.stat(stolplot.stat >0)     = 1;
                        
                        tpower                  = stolplot.prob .* stolplot.mask .*stolplot.stat;
                        
                        tpower(tpower == 0)     = NaN;
                        source.pow              = tpower ; clear tpower;
                        
                        cfg                     =   [];
                        cfg.method              =   'surface';
                        cfg.funparameter        =   'pow';
                        cfg.funcolorlim         =   [-z_lim z_lim];
                        cfg.opacitylim          =   [-z_lim z_lim];
                        cfg.opacitymap          =   'rampup';
                        cfg.colorbar            =   'on';
                        cfg.camlight            =   'no';
                        cfg.projmethod          =   'nearest';
                        cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat'];
                        cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
                        
                        ft_sourceplot(cfg, source);
                        view(lst_view(iside,:))
                        title([list_freq{nfreq} '.' list_test{ntest} '.' list_roi{nroi} '.' list_mesure{nmes} '.' num2str(min_p(nfreq,nroi,ntest,nmes))]);
                        
                    end
                end
            end
        end
    end
end

for nfreq = 1:size(stat,1)
    for nroi = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            for nmes = 1:size(stat,4)
                
                if min_p(nfreq,nroi,ntest,nmes) < p_limit
                    
                    i = i + 1;
                    
                    who_seg{i,1} = FindSigClusters(stat{nfreq,nroi,ntest,nmes},p_limit);
                    who_seg{i,2} = [list_freq{nfreq} '.' list_test{ntest} '.' list_roi{nroi} '.' list_mesure{nmes}];
                    who_seg{i,3} = min_p(nfreq,nroi,ntest,nmes);
                    %                     who_seg{i,4} = FindSigClustersWithCoordinates(stat{nfreq,nroi,ntest,nmes},p_limit,'../documents/FrontalCoordinates.csv',0.5);
                    
                end
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val list_test who_seg p_limit
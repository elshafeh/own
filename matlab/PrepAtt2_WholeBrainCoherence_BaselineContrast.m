clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/template/template_grid_0.5cm.mat

for sb = 1:21
    
    suj         = ['yc' num2str(sb)] ;
    
    list_freq   = {'60t100Hz.MinEvoked'};
    list_time   = {'fDIS.p100p300','DIS.p100p300'};
    
    %     load ../data/index/FrontalRegionsCombined.mat;
    %     list_roi    = list_H;
    
    list_roi    ={'FrontalInfTriL','FrontalInfTriR'};
    
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
    
    list_mesure = {'plvConn.dpssFrontCombinedZBefore.mat'};
    list_cue    = {''};

    for ncue = 1:length(list_cue)
        for nfreq = 1:length(list_freq)
            for nroi = 1:length(list_roi)
                for nmes = 1:length(list_mesure)
                    for ntime = 1:length(list_time)
                        
                        dir_data                                        = '../data/dis_Newfrontal_conn/';
                        fname_in                                        = [dir_data suj '.' list_cue{ncue} list_time{ntime} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
                        
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
                        
                        fprintf('Loading %s\n',fname_in);
                        load(fname_in)
                        
                        source_ztransform                               = source ; % .5.*log((1+source)./(1-source)); clear source ;
                        
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.pow  = source_ztransform;
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.pos  = template_grid.pos;
                        source_gavg{sb,ncue,nfreq,nroi,nmes,ntime}.dim  = template_grid.dim;
                        
                        clear  source
                        
                    end
                end
            end
        end
    end
end

clearvars -except source_gavg list_* *_list

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                cfg                                 =   [];
                cfg.dim                             =   source_gavg{1}.dim;
                cfg.method                          =   'montecarlo';
                cfg.statistic                       =   'depsamplesT';
                cfg.parameter                       =   'pow';
                
                cfg.correctm                        =   'cluster';
                
                cfg.clusteralpha                    =   0.05;             % First Threshold (paper = 0.001)
                
                cfg.clusterstatistic                =   'maxsum';
                cfg.numrandomization                =   1000;
                cfg.alpha                           =   0.025;
                cfg.tail                            =   0;
                cfg.clustertail                     =   0;
                
                nsuj                                =   size(source_gavg,1);
                 
                cfg.design(1,:)                     =   [1:nsuj 1:nsuj];
                cfg.design(2,:)                     =   [ones(1,nsuj) ones(1,nsuj)*2];
                cfg.uvar                            =   1;
                cfg.ivar                            =   2;
                
                stat{ncue,nfreq,nroi,nmes}          =   ft_sourcestatistics(cfg, source_gavg{:,ncue,nfreq,nroi,nmes,2},source_gavg{:,ncue,nfreq,nroi,nmes,1});
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat 

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                [min_p(ncue,nfreq,nroi,nmes),p_val{ncue,nfreq,nroi,nmes}]     = h_pValSort(stat{ncue,nfreq,nroi,nmes});
                
            end
        end
    end
end

clearvars -except source_gavg list_* stat min_p p_val

p_limit = 0.05;

% i = 0 ; clear new_reg_list ;
%
% for ncue = 1:length(list_cue)
%     for nfreq = 1:length(list_freq)
%         for nroi = 1:length(list_roi)
%             for nmes = 1:length(list_mesure)
%                 if min_p(ncue,nfreq,nroi,nmes) < p_limit
%
%                     i = i + 1;
%
%                     stolplot          = stat{ncue,nfreq,nroi,nmes};
%
%                     new_reg_list{i,1} = FindSigClustersWithCoordinates(stolplot,p_limit,'../documents/FrontalCoordinates.csv',0.5);
%                     new_reg_list{i,2} = [list_cue{ncue} '.' list_freq{nfreq} '.' list_roi{nroi} '.' list_mesure{nmes}];
%                     new_reg_list{i,3} = min_p(ncue,nfreq,nroi,nmes);
%                     new_reg_list{i,4} = FindSigClusters(stolplot,p_limit);
%
%                 end
%             end
%         end
%     end
% end

clearvars -except source_gavg list_* stat min_p p_val new_reg_list p_limit

for ncue = 1:length(list_cue)
    for nfreq = 1:length(list_freq)
        for nroi = 1:length(list_roi)
            for nmes = 1:length(list_mesure)
                
                if min_p(ncue,nfreq,nroi,nmes) < p_limit
                    
                    for iside = [1 2]
                        
                        lst_side                = {'left','right','both'};
                        lst_view                = [-128 3;128 3;-89 5; 89 5]; % [-95 1;95,1 ;0 50];
                        
                        z_lim                   = 5;
                        
                        clear source ;
                        
                        stolplot                = stat{ncue,nfreq,nroi,nmes};
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
                        
                        title(list_roi{nroi});
                        
                        fname_out               = '~/GoogleDrive/PhD/Publications/Papers/distractor2018/cortex2018/_prep/';
                        fname_out               = [fname_out '0.05gamma_conn_' list_roi{nroi} '.' num2str(iside) '.png'];
                        %                         saveas(gcf,fname_out);
                        %                         close all;
                        
                    end
                end
            end
        end
    end
end

% close all;
% stat_gamma_con  = stat{1}; clearvars -except stat_* ; save ../data/stat/prep22_gamma_con.mat;
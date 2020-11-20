clear ; clc ; addpath(genpath('../fieldtrip-20151124/')); close all ;

for ntest = 1:2

    list_freq   = {'60t100Hz'};
    list_time   = {{'fDIS.p100p300','DIS.p100p300'}};

    for sb = 1:14

        suj_list = [1:4 8:17];

        suj         = ['yc' num2str(suj_list(sb))];


        sourceAppend{1} = [];   % before
        sourceAppend{2} = [];   % after
        %         sourceAppend{3} = [] ;  % non-corrected

        tmp{1} = [];
        tmp{2} = [];

        for prt = 1:3
            for ix = 1:2

                filt_ext    = 'SingleTrial.NewDpss';

                fname       = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) ...
                    '.CnD.' list_freq{ntest} '.' list_time{ntest}{ix} ...
                    '.' filt_ext '.mat'];

                fprintf('Loading %50s\n',fname);

                load(fname);

                source_carr{ix} = source ;

                tmp{ix}         = [tmp{ix} source] ;

                %                 if ix == 2
                %                     sourceAppend{3} = [sourceAppend{3} source];
                %                 end

                clear source ;

            end

            sourceAppend{1} = [sourceAppend{1} (source_carr{2}-source_carr{1})./source_carr{1}];

            clear source_carr

        end

        sourceAppend{2} = (tmp{2} - tmp{1}) ./ tmp{1} ;

        clear tmp

        for cnd_bsl = 1:length(sourceAppend)

            load ../data/yctot/rt/rt_CnD_adapt.mat

            fprintf('Calculating Correlation\n');

            [rho,p]                                                 = corr(sourceAppend{cnd_bsl}',rt_all{sb} , 'type', 'Spearman');
            rho(isnan(rho))                                         = 0;
            rhoM                                                    = rho;
            rhoF                                                    = 0.5 .* (log((1+rhoM)./(1-rhoM)));

            source_avg{sb,ntest,cnd_bsl,1}.pow                      = rhoF;             % act
            source_avg{sb,ntest,cnd_bsl,2}.pow(length(rho),1)       = 0;                % bsl

            clear rho rhoF

            fprintf('Done\n');

            load ../data/template/source_struct_template_MNIpos.mat

            for cnd_rho = 1:2
                source_avg{sb,ntest,cnd_bsl,cnd_rho}.pos    = source.pos;
                source_avg{sb,ntest,cnd_bsl,cnd_rho}.dim    = source.dim;
            end

            clear source

        end

        clear sourceAppend

    end

end

clearvars -except source_avg

for ntest = 1:2
    for cnd_bsl = 1:2
        cfg                                                     =   [];
        cfg.dim                                                 =   source_avg{1,1}.dim;
        cfg.method                                              =   'montecarlo'; cfg.statistic =   'depsamplesT'; cfg.parameter =   'pow';
        cfg.correctm                                            =   'cluster';
        cfg.clusteralpha                                        =   0.05;             % First Threshold
        cfg.clusterstatistic                                    =   'maxsum';
        cfg.numrandomization                                    =   1000;cfg.alpha  =   0.025;  cfg.tail  =   0;
        cfg.clustertail                                         =   0; cfg.design(1,:) =   [1:14 1:14]; cfg.design(2,:)                                         =   [ones(1,14) ones(1,14)*2];
        cfg.uvar                                                =   1; cfg.ivar =   2;
        
        stat{ntest,cnd_bsl}                                     =   ft_sourcestatistics(cfg,source_avg{:,ntest,cnd_bsl,1}, ...
            source_avg{:,ntest,cnd_bsl,2});
        
        stat{ntest,cnd_bsl}.cfg                                 =   [];
    end
end

% load /Volumes/Pat22Backup/meg21_fieldtrip_data_backup/data/yctot/stat/CorrSingAgZeroCorr.mat
% load /Volumes/Pat22Backup/meg21_fieldtrip_data_backup/data/yctot/stat/source_actv_againstZero_statCorr.mat

for n_x = 1:size(stat,1)
    for n_y = 1:size(stat,2)
        [min_p(n_x,n_y),p_val{n_x,n_y}]     = h_pValSort(stat{n_x,n_y});
    end
end

close all;

for n_x = 1%:size(stat,1)
    for n_y = 1%:size(stat,2)
        for iside = [1 2]
            
            lst_side                                    = {'left','right','both'};
            
            %             lst_view                                    = [-95 1;95 1;0 50];
            lst_view                                    = [-32 53;32 53;0 50];

            z_lim                                       = 5;
            
            clear source ;
            
            stoplot                                     = stat{n_x,n_y};
            
            stoplot.mask                                = stoplot.prob < 0.1;
            
            source.pos                                  = stoplot.pos ;
            source.dim                                  = stoplot.dim ;
            tpower                                      = stoplot.stat .* stoplot.mask;
            
            tpower(tpower == 0)                         = NaN;
            source.pow                                  = tpower ; clear tpower;
            
            cfg                                         =   [];
            %             cfg.funcolormap                             = 'jet';
            cfg.method                                  =   'surface';
            cfg.funparameter                            =   'pow';
            cfg.funcolorlim                             =   [-z_lim z_lim];
            cfg.opacitylim                              =   [-z_lim z_lim];
            cfg.opacitymap                              =   'rampup';
            cfg.colorbar                                =   'off';
            cfg.camlight                                =   'no';
            cfg.projmethod                              =   'nearest';
            
            %             cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
            %             cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
            
            cfg.surffile                                =   ['surface_white_' lst_side{iside} '.mat'];
            cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '.mat'];
            
            %             cfg.surffile                                =   ['surface_pial_' lst_side{iside} '.mat'];
            %             cfg.surfinflated                            =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
            
            ft_sourceplot(cfg, source);
            view(lst_view(iside,:))
            
        end
    end
end
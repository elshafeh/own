clear ; clc ; dleiftrip_addpath; close all;

for ntest = 1:2
    
    list_freq   = {'10t16Hz','10t16Hz'};
    list_time   = {{'m500m200','p900p1200'},{'m600m300','p900p1200'}};
    
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
                
                fname = dir(['../data/source/' suj '.pt' num2str(prt) ...
                    '.CnD.' list_freq{ntest} '.' list_time{ntest}{ix} ...
                    '.' filt_ext '.mat']);
                
                fname = fname.name;
                
                fprintf('Loading %50s\n',fname);
                
                load(['../data/source/' fname]);
                
                source_carr{ix} = source ;
                
                tmp{ix} = [tmp{ix} source] ;
                
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
            
            [rho,p]         = corr(sourceAppend{cnd_bsl}',rt_all{sb} , 'type', 'Spearman');
            rho(isnan(rho)) = 0;
            rhoM            = rho;
            rhoF            = 0.5 .* (log((1+rhoM)./(1-rhoM)));
            
            source_avg{sb,ntest,cnd_bsl,1}.pow                   = rhoF;             % act
            source_avg{sb,ntest,cnd_bsl,2}.pow(length(rho),1)    = 0;                % bsl
            
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

for ntest = 1:2
    for cnd_bsl = 1:2
        [min_p(ntest,cnd_bsl),p_val{ntest,cnd_bsl}]                  =   h_pValSort(stat{ntest,cnd_bsl});
        vox_list{ntest,cnd_bsl}                                      =   FindSigClusters(stat{ntest,cnd_bsl},0.2);
    end
end

clearvars -except stat vox_list min_p p_val source_avg

lst_test = {'10t16Hz','10t16Hz'};
lst_bsl     = {'before','after'};

for ntest = 1:2
    for cnd_bsl = 1:2
        
        p_lim =0.1 ;
        
        stat_int{ntest,cnd_bsl}          = h_interpolate(stat{ntest,cnd_bsl});
        stat_int{ntest,cnd_bsl}.cfg      = [];
        stat_int{ntest,cnd_bsl}.mask     = stat_int{ntest,cnd_bsl}.prob < p_lim;
        
        cfg                     = [];
        cfg.method              = 'slice';
        cfg.funparameter        = 'stat';
        cfg.maskparameter       = 'mask';
        cfg.colorbar            = 'no';
        cfg.funcolorlim         = [-4 4];
        ft_sourceplot(cfg,stat_int{ntest,cnd_bsl});clc;
        title([lst_test{ntest} ' ' lst_bsl{cnd_bsl} ' ' num2str(min_p(ntest,cnd_bsl))])
        
    end
end

for ntest = 2
    for cnd_bsl = 1
        stat{ntest,cnd_bsl}.mask = stat{1,1}.prob < 0.05;
        source.pos = stat{ntest,cnd_bsl}.pos ;
        source.dim = stat{ntest,cnd_bsl}.dim ;
        source.pow = stat{ntest,cnd_bsl}.stat .* stat{1,1}.mask;
        cfg                     =   [];
        cfg.method              =   'surface';
        cfg.funparameter        =   'pow';
        cfg.funcolorlim         =   [-4 4];
        cfg.opacitylim          =   [-4 4];
        cfg.opacitymap          =   'rampup';
        cfg.colorbar            =   'off';
        cfg.camlight            =   'no';
        cfg.projthresh          =   0.2;
        cfg.projmethod          =   'nearest';
        
        ll = {'right','left'};
        lst_view = [30 50;-30 50];
        
        for side = 1:2
            cfg.surffile            =   ['surface_white_' ll{side} '.mat'];
            cfg.surfinflated        =   ['surface_inflated_' ll{side} '_caret.mat'];
            ft_sourceplot(cfg, source);
            view(lst_view(side,1),lst_view(side,2))
        end
    end
end
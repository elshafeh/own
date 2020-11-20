clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% lst_group       = {'old','young'};

load ../data/template/template_grid_0.5cm.mat

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list    = suj_group{ngroup};
    
    lst_freq    = {'60t100Hz'};
    
    lst_time    = {'p100p300'};
    
    ext_comp    ='wPCCMinEvokeddpssSource0.5cm.mat'; %  ; % 'wPCCSource0.5cm.mat'; % 
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        
        list_ix_cue         = 0:2;
        list_ix_tar         = 1:4;
        list_ix_dis         = 1:2;
        
        [~,~,~,~,strl_rt]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        lst_cond_main       = {'DIS'};
        
        for nfreq = 1:length(lst_freq)
            for ntime = 1:length(lst_time)
                for cnd_cue = 1:length(lst_cond_main)
                    
                    
                    fname = ['../data/dis_pcc_data/' suj '.' lst_cond_main{cnd_cue} '.' lst_freq{nfreq} '.' lst_time{ntime} '.' ext_comp];
                    fprintf('Loading %50s\n',fname);
                    load(fname);
                    
                    pow             = source; clear source
                    
                    fprintf('Calculating Correlation\n');
                    
                    [rho,p]         = corr(pow',strl_rt , 'type', 'Spearman');
                    rho(isnan(rho)) = 0;
                    rhoM            = rho;
                    rhoF            = 0.5 .* (log((1+rhoM)./(1-rhoM)));
                    
                    val_carr{1}     = rhoF;     % act
                    val_carr{2}     = rhoF;     % bsl
                    val_carr{2}(:)  = 0;
                    
                    for nbsl = 1:2
                        
                        source_avg{ngroup}{sb,cnd_cue,nfreq,ntime,nbsl}.pow       = val_carr{nbsl};
                        source_avg{ngroup}{sb,cnd_cue,nfreq,ntime,nbsl}.pos       = template_grid.pos ;
                        source_avg{ngroup}{sb,cnd_cue,nfreq,ntime,nbsl}.dim       = template_grid.dim ;
                        source_avg{ngroup}{sb,cnd_cue,nfreq,ntime,nbsl}.inside    = template_grid.inside;
                        
                    end
                    
                    clear val_carr rh* bsl_source act_source pow
                end
                
            end
        end
    end
end

clearvars -except source_avg lst_*;

for ngroup = 1:length(source_avg)
    for nfreq = 1:length(lst_freq)
        for ntime = 1:length(lst_time)
            for cnd_cue = 1:length(lst_cond_main)
                
                cfg                                =   [];
                cfg.dim                            =   source_avg{ngroup}{1}.dim;
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
                
                stat{ngroup,nfreq,ntime,cnd_cue}   =   ft_sourcestatistics(cfg, source_avg{ngroup}{:,cnd_cue,nfreq,ntime,1},source_avg{ngroup}{:,cnd_cue,nfreq,ntime,2});
                stat{ngroup,nfreq,ntime,cnd_cue}   =   rmfield(stat{ngroup,nfreq,ntime,cnd_cue},'cfg');
                
            end
        end
    end
end

clearvars -except source_avg lst_* stat ;

p_limit = 0.3;

i = 0 ; clear who_seg ,

for ngroup = 1:length(source_avg)
    for nfreq = 1:length(lst_freq)
        for ntime = 1:length(lst_time)
            for cnd_cue = 1:length(lst_cond_main)
                
                stoplot             = stat{ngroup,nfreq,ntime,cnd_cue};
                
                [min_p,p_val]       = h_pValSort(stoplot);
                
                if min_p < p_limit
                    
                    i = i + 1;
                    
                    who_seg{i,1} = [lst_freq{nfreq} '.' lst_time{ntime} '.' lst_cond_main{cnd_cue}];
                    who_seg{i,2} = min_p;
                    who_seg{i,3} = p_val;
                    
                    who_seg{i,4} = FindSigClusters(stoplot,p_limit);
                    who_seg{i,5} = FindSigClustersWithCoordinates(stoplot,p_limit,'../documents/FrontalCoordinates.csv',0.5);
                    
                end
            end
        end
    end
end

for ngroup = 1:length(source_avg)
    for nfreq = 1:length(lst_freq)
        for ntime = 1:length(lst_time)
            for cnd_cue = 1:length(lst_cond_main)
                
                stoplot                     = stat{ngroup,nfreq,ntime,cnd_cue};
                [min_p,p_val]               = h_pValSort(stoplot);
                
                if min_p < p_limit
                    
                    z_lim                   = 5;
                    
                    clear source ;
                    
                    stoplot.mask           = stoplot.prob < p_limit;
                    
                    source.pos              = stoplot.pos ;
                    source.dim              = stoplot.dim ;
                    tpower                  = stoplot.stat .* stoplot.mask;
                    tpower(tpower == 0)     = NaN;
                    source.pow              = tpower ; clear tpower;
                    
                    cfg                     =   [];
                    cfg.funcolormap         =   'jet';
                    cfg.method              =   'surface';
                    cfg.funparameter        =   'pow';
                    cfg.funcolorlim         =   [-z_lim z_lim];
                    cfg.opacitylim          =   [-z_lim z_lim];
                    cfg.opacitymap          =   'rampup';
                    cfg.colorbar            =   'off';
                    cfg.camlight            =   'no';
                    %                     cfg.projthresh          =   0.2;
                    cfg.projmethod          =   'nearest';
                    cfg.surffile            =   'surface_white_both.mat';
                    cfg.surfinflated        =   'surface_inflated_both_caret.mat';
                    
                    ft_sourceplot(cfg, source);
                    
                    title([lst_freq{nfreq} '.' lst_time{ntime} '.' lst_cond_main{cnd_cue}])
                    
                end
                
            end
        end
    end
end
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

for sb = 1:21
    
    suj                = ['yc' num2str(sb)];
    
    list_ix_cue        = {0};
    list_ix_tar        = {1:4};
    list_ix_dis        = {0};
    
    lst_cnd             = {'CnD'};
    lst_mth             = {'PLV.optimisedPACMinEvoked100Slct'};
    lst_chn             = {'aud_L','aud_R','occ_L','occ_R'};
    lst_tme             = {'m1000m200','p200p1000'};
    
    for ncue = 1:length(lst_cnd)
        for nmethod = 1:length(lst_mth)
            for nchan = 1:length(lst_chn)
                for ntime = 1:length(lst_tme)
                    
                    fname   = ['../data/pat22_data/' suj '.' lst_cnd{ncue} '.NewAVBroad.' lst_tme{ntime} '.' lst_chn{nchan} '.' lst_mth{nmethod} '.mat'];
                    
                    fprintf('Loading %30s\n',fname);
                    load(fname);
                    
                    time_temp{ntime}.powspctrm(1,:,:)                 = seymour_pac.mpac_norm;
                    time_temp{ntime}.freq                             = seymour_pac.amp_freq_vec;
                    time_temp{ntime}.time                             = seymour_pac.pha_freq_vec;
                    time_temp{ntime}.label                            = lst_chn(nchan);
                    time_temp{ntime}.dimord                           = 'chan_freq_time';
                    
                    clear seymour_pac
                    
                end
                
                chan_temp{nchan}               = time_temp{2};
                chan_temp{nchan}.powspctrm     = (time_temp{2}.powspctrm - time_temp{1}.powspctrm)./time_temp{1}.powspctrm;
                
                clear time_temp;
                
            end
            
            
            cfg = []; cfg.parameter = 'powspctrm' ; cfg.appenddim = 'chan';
            allsuj_data{sb,ncue,nmethod} = ft_appendfreq(cfg,chan_temp{:});
            
            clear chan_temp;
            
        end
        
        [allsuj_behav{sb,ncue,1},allsuj_behav{sb,ncue,2},allsuj_behav{sb,ncue,3},~] =  h_behav_eval(suj,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue}); clc ;
        
    end
    
    
end

clearvars -except allsuj_data allsuj_behav lst_* ; clc ;

nsuj                    = size(allsuj_data,1);
[design,neighbours]     = h_create_design_neighbours(nsuj,allsuj_data{1},'virt','t'); clc;

for ncue = 1:size(allsuj_data,2)
    for nmethod  =1:size(allsuj_data,3)
        for ntest = 1:size(allsuj_behav,3)
            
            cfg                                 = [];
            cfg.method                          = 'montecarlo';
            cfg.statistic                       = 'ft_statfun_correlationT';
            cfg.neighbours                      =  neighbours;
            cfg.correctm                        = 'fdr';
            
            cfg.frequency                       = [60 100];
            cfg.latency                         = [7 15];
            
            cfg.clusterstatistics               = 'maxsum';
            cfg.clusteralpha                    = 0.05;
            cfg.tail                            = 0;
            cfg.clustertail                     = 0;
            cfg.alpha                           = 0.025;
            cfg.numrandomization                = 1000;
            cfg.ivar                            = 1;
            cfg.type                            = 'Spearman';
            
            nsuj                                = size(allsuj_behav,1);
            
            cfg.design(1,1:nsuj)                = [allsuj_behav{:,ncue,ntest}];
            
            
            stat{ncue,nmethod,ntest}            = ft_freqstatistics(cfg, allsuj_data{:,ncue,nmethod});
            
        end
    end
end

clearvars -except allsuj_data allsuj_behav stat ; clc ; close all;

lst_behav                    = {'medianRT','meanRT','perCorrect'};

for ncue = 1:size(stat,1)
    for nmethod  =1:size(stat,2)
        for ntest = 1:size(stat,3)
            [min_p(ncue,nmethod,ntest),p_val{ncue,nmethod,ntest}] = h_pValSort(stat{ncue,nmethod,ntest});
        end
    end
end

for ncue = 1:size(stat,1)
    for nmethod  =1:size(stat,2)
        
        i = 0;
        figure;
        
        for nchan = 1:length(stat{ncue,nmethod}.label)
            for ntest = 1:size(stat,3)
                
                
                s_to_plot       = stat{ncue,nmethod,ntest};
                s_to_plot.mask  = s_to_plot.prob < 0.05;
                
                i = i + 1;
                subplot(4,3,i)
                
                cfg                 = [];
                cfg.channel         = nchan;
                cfg.parameter       = 'stat'; cfg.maskparameter   = 'mask'; cfg.maskstyle       = 'outline';
                cfg.zlim            = [-5 5];
                ft_singleplotTFR(cfg,s_to_plot);
                colormap(redblue)
                
                title([stat{ncue,nmethod}.label{nchan} ' ' lst_behav{ntest}]);
                
            end
        end
    end
end

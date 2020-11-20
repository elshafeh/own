clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat
% suj_group      = suj_group(1:2);

suj_group{1}                                        = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                         = suj_list{sb};
        cond_main                                   = 'CnD';
        
        ext_name                                    = 'prep21.maxAVMsepVoxel5per.50t120Hz.m800p2000msCov.waveletPOW.50t120Hz.m2000p2000.MinEvokedAvgTrials';
        
        list_ix                                     = {''};
        
        for ncue = 1:length(list_ix)
            
            fname_in                                = ['../data/paper_data/' suj '.' list_ix{ncue} cond_main '.' ext_name '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            if isfield(freq,'check_trialinfo')
                freq = rmfield(freq,'check_trialinfo');
            end
            
            cfg                                     = [];
            cfg.baseline                            = [-0.4 -0.2];
            cfg.baselinetype                        = 'relchange';
            freq                                    = ft_freqbaseline(cfg,freq);
            
            allsuj_data{ngroup}{sb,ncue}            = freq;
            
            load ../data/yctot/rt/rt_CnD_adapt.mat
            
            %             [~,~,perc_corr,~,~]                     = h_new_behav_eval(suj,0:2,0,1:4); clc ;
            %             [med_inf,mean_inf,~,~,~]                = h_new_behav_eval(suj,[1 2],0,1:4); clc ;
            %             [med_unf,mean_unf,~,~,~]                = h_new_behav_eval(suj,0,0,1:4); clc ;
            
            
            allsuj_behav{ngroup}{sb,ncue,1}         = mean(rt_all{sb});
            allsuj_behav{ngroup}{sb,ncue,2}         = median(rt_all{sb});

        end
    end
end

clearvars -except allsuj_data allsuj_behav lst_group list_ix

for ngroup = 1:length(allsuj_data)
    for ncue = 1:size(allsuj_data{ngroup},2)
        for ntest = 1:size(allsuj_behav{ngroup},3)
            
            
            nsuj                                = size(allsuj_data{ngroup},1);
            [design,neighbours]                 = h_create_design_neighbours(nsuj,allsuj_data{ngroup}{1},'virt','t');
            
            cfg                                 = [];
            cfg.latency                         = [0.6 1];
            cfg.frequency                       = [60 100];
            
            cfg.avgoverfreq                     = 'yes';
            
            cfg.method                          = 'montecarlo';
            cfg.statistic                       = 'ft_statfun_correlationT';
            cfg.neighbours                      = neighbours;
            cfg.minnbchan                       = 0;
            cfg.correctm                        = 'cluster';
            
            cfg.clusterstatistics               = 'maxsum';
            cfg.clusteralpha                    = 0.05;
            cfg.tail                            = 0;
            cfg.clustertail                     = 0;
            cfg.alpha                           = 0.025;
            cfg.numrandomization                = 1000;
            cfg.ivar                            = 1;
            
            cfg.type                            = 'Spearman';
            
            nsuj                                = size(allsuj_behav{ngroup},1);
            cfg.design(1,1:nsuj)                = [allsuj_behav{ngroup}{:,ncue,ntest}];
            
            stat{ngroup,ncue,ntest}             = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,ncue});
            
        end
    end
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            [min_p(ngroup,ncue,ntest),p_val{ngroup,ncue,ntest}] = h_pValSort(stat{ngroup,ncue,ntest});
        end
    end
end

close all;
    
%     figure;
i = 0 ;

for ngroup = 1:size(stat,1)

    
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            s_to_plot = stat{ngroup,ncue,ntest};
            
            for nchan = 1:length(s_to_plot.label)
                
                s_to_plot.mask      = s_to_plot.prob < 0.2;
                
                i = i + 1;
                
                subplot(2,2,i)
                
                cfg                 = [];
                cfg.channel         = nchan;
                cfg.parameter       = 'stat';
                cfg.maskparameter   = 'mask';
                cfg.maskstyle       = 'outline';
                cfg.zlim            = [-5 5];
                cfg.colorbar        = 'no';
                ft_singleplotTFR(cfg,s_to_plot);
                
                title([list_ix{ncue} 'CnD ' s_to_plot.label{nchan}])
                
            end
        end
    end
end
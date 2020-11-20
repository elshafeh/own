clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_list,~]      = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_list(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        list_dis = {'DIS','fDIS'};
        list_cue = {''};
        
        for ncue = 1:length(list_cue)
            
            for ndis = 1:2
                
                suj                 = suj_list{sb};
                fname_in            = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.' list_cue{ncue} list_dis{ndis} '.broadAudSchTPJMniPF.1t110Hz.m200p800msCov.waveletPOW.25t120Hz.m200p600.MinEvokedAvgTrials.mat'];
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in)
                
                tmp{ndis}   = freq; clear freq
                
            end
            
            freq                            = tmp{1};
            freq.powspctrm                  = tmp{1}.powspctrm - tmp{2}.powspctrm;
            
            allsuj_avg{ngroup}{sb,ncue}     = freq ; clear freq ;
            
        end
        
        list_ix_cue                 = 0:2;
        list_ix_tar                 = 1:4;
        list_ix_dis                 = 1;
        [dis1_median,dis1_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_dis                 = 2;
        [dis2_median,dis2_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);

        list_ix_dis                 = 0;
        [dis0_median,dis0_mean,~,~] = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_cue                 = [1 2];
        list_ix_tar                 = 1:4;
        list_ix_dis                 = 0;
        [inf_median,inf_mean,~,~]   = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_cue                 = 0;
        [unf_median,unf_mean,~,~]   = h_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        allsuj_behav{ngroup}{sb,1}  = dis2_median - dis1_median;
        allsuj_behav{ngroup}{sb,2}  = unf_median - inf_median;
        allsuj_behav{ngroup}{sb,3}  = dis0_median - dis1_median;
        
        clear dis1_median dis1_mean dis2_median dis2_mean inf_median inf_mean unf_median unf_mean
        
        list_ix_cue                 = 0:2;
        list_ix_tar                 = 1:4;
        list_ix_dis                 = 1;
        [dis1_median,dis1_mean,~,~] = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_dis                 = 2;
        [dis2_median,dis2_mean,~,~] = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_dis                 = 0;
        [dis0_median,dis0_mean,~,~] = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_cue                 = [1 2];
        list_ix_tar                 = 1:4;
        list_ix_dis                 = 0;
        [inf_median,inf_mean,~,~]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        list_ix_cue                 = 0;
        [unf_median,unf_mean,~,~]   = h_new_behav_eval(suj,list_ix_cue,list_ix_dis,list_ix_tar);
        
        allsuj_behav{ngroup}{sb,4}  = dis2_median - dis1_median;
        allsuj_behav{ngroup}{sb,5}  = unf_median - inf_median;
        allsuj_behav{ngroup}{sb,6}  = dis0_median - dis1_median;
        
        clear dis1_median dis1_mean dis2_median dis2_mean inf_median inf_mean unf_median unf_mean
        
    end
end

clearvars -except allsuj_avg allsuj_behav ;

for ngroup = 1:length(allsuj_avg)
    
    nsuj               = size(allsuj_avg{ngroup},1);
    [~,neighbours]     = h_create_design_neighbours(nsuj,allsuj_avg{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_avg{ngroup},2)
        for ntest = 1:size(allsuj_behav{ngroup},2)
            
            cfg                                 = [];
            
            cfg.latency                         = [0 0.35];
            
            cfg.frequency                       = [50 110];
            
            cfg.method                          = 'montecarlo';
            cfg.statistic                       = 'ft_statfun_correlationT';
            
            cfg.correctm                        = 'cluster';
            
            cfg.clusterstatistics               = 'maxsum';
            cfg.clusteralpha                    = 0.05;
            cfg.tail                            = 0;
            cfg.clustertail                     = 0;
            cfg.alpha                           = 0.025;
            cfg.numrandomization                = 1000;
            cfg.ivar                            = 1;
            
            cfg.neighbours                      = neighbours;
            cfg.minnbchan                       = 0;
            
            cfg.type                            = 'Spearman';
            
            cfg.design(1,1:nsuj)                = [allsuj_behav{ngroup}{:,ntest}];
            
            stat{ngroup,ncue,ntest}             = ft_freqstatistics(cfg, allsuj_avg{ngroup}{:,ncue});
            
        end
    end
end

clearvars -except allsuj_avg allsuj_behav stat min_p p_val list_ix

list_behav          = {'medianCapture','medianTD','medianArousal','NEWmedianCapture','NEWmedianTD','NEWmedianArousal'};
list_cue            = {'DIS'};
i = 0;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            
            stat_to_plot                = stat{ngroup,ncue,ntest};
            [min_p,p_val]               = h_pValSort(stat_to_plot);
            p_limit                     = 0.2;
            
            if min_p < p_limit
                
                figure;
                
                for nchan = 1:length(stat_to_plot.label)
                    
                    subplot(4,3,nchan)
                    
                    stat_to_plot.mask           = stat_to_plot.prob < p_limit;
                    
                    [x_ax,y_ax,z_ax]  = size(stat_to_plot.stat);
                    
                    if y_ax == 1
                        
                        plot(stat_to_plot.time,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
                        ylim([-3 3]);
                        xlim([stat_to_plot.time(1) stat_to_plot.time(end)])
                        
                    elseif z_ax == 1
                        
                        plot(stat_to_plot.freq,squeeze(stat_to_plot.mask(nchan,:,:) .* stat_to_plot.stat(nchan,:,:)));
                        ylim([-3 3]);
                        xlim([stat_to_plot.freq(1) stat_to_plot.freq(end)])
                        
                    else
                        
                        cfg                             = [];
                        cfg.channel                     = nchan;
                        cfg.parameter                   = 'stat';
                        cfg.colorbar                    = 'no';
                        cfg.maskparameter               = 'mask';
                        cfg.maskstyle                   = 'outline';
                        cfg.zlim                        = [-2 2];
                        ft_singleplotTFR(cfg,stat_to_plot);
                        
                        title([stat_to_plot.label{nchan} ' ' list_behav{ntest} ' ' num2str(min_p)]);
                        
                    end
                end
            end
        end
    end
end
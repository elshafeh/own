clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        lst_dis = {'DIS','fDIS'};
        lst_cue = {'','1','2'};
        
        for ncue = 1:length(lst_cue)
            
            for cnd_dis = 1:2
                
                suj                 = suj_list{sb};
                fname_in            = ['../data/' suj '/field/' suj '.' lst_cue{ncue} lst_dis{cnd_dis} '.AudBroadSchaefFront.50t120Hz.m200p800msCov.waveletPOW.50t120Hz.m1000p1000.AvgTrialsMinEvoked10MStep.mat'];
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in)
                
                if isfield(freq,'check_trialinfo')
                    freq = rmfield(freq,'check_trialinfo');
                end
                
                %                 freq           = ft_freqdescriptives([],freq);
                
                tmp{cnd_dis}   = freq; clear freq
                
            end
            
            freq                            = tmp{1};
            freq.powspctrm                  = tmp{1}.powspctrm - tmp{2}.powspctrm;
            
            cfg.freq_start                  = 60;
            cfg.freq_end                    = 90;
            cfg.freq_step                   = 10;
            cfg.freq_window                 = 10;
            freq                            = h_smoothFreq(cfg,freq);
            
            cfg.time_start                  = 0;
            cfg.time_end                    = 0.6;
            cfg.time_step                   = 0.05;
            cfg.time_window                 = 0.05;
            freq                            = h_smoothTime(cfg,freq);

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
        
        allsuj_behav{ngroup}{sb,4}  = dis2_mean - dis1_mean;
        allsuj_behav{ngroup}{sb,5}  = unf_mean - inf_mean;
        allsuj_behav{ngroup}{sb,6}  = dis0_mean - dis1_mean;
        
    end
end

clearvars -except allsuj_avg allsuj_behav ;

for ngroup = 1:length(allsuj_avg)
    
    nsuj               = size(allsuj_avg{ngroup},1);
    [~,neighbours]     = h_create_design_neighbours(nsuj,allsuj_avg{1}{1},'virt','t'); clc;
    
    for ncue = 1:size(allsuj_avg{ngroup},2)
        for ntest = 1:size(allsuj_behav{ngroup},2)
            
            cfg                                 = [];
            
            if ncue == 2
                cfg.latency                         = [0 0.6];
            else
                cfg.latency                         =  [0 0.35];
            end
            
            cfg.frequency                       = [60 100];
            
            %             cfg.avgovertime                     = 'yes';
            %             cfg.avgoverfreq                     = 'yes';

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

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            [min_p(ngroup,ncue,ntest), p_val{ngroup,ncue,ntest}]      = h_pValSort(stat{ngroup,ncue,ntest}) ;
        end
    end
end

clearvars -except allsuj_avg allsuj_behav stat min_p p_val list_ix

lst_behav                           = {'medianCapture','medianTD','medianArousal','meanCapture','meanTD','meanArousal'};
lst_cue                             = {'DIS','DIS1','DIS2'};
i = 0;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        for ntest = 1:size(stat,3)
            for nchan = 1:length(stat{ngroup,ncue,ntest}.label)
                
                %             subplot(size(stat,2),size(stat,3),i)
                %             cfg             = [];
                %             cfg.ylim        = [-3 3]; %y axes limits
                %             cfg.linewidth   = 2;
                %             cfg.p_threshold = 0.11; %to handle the mask
                %             h_plotStatAvgOverDimension(cfg,stat{ngroup,nchan,ntest})
                
                
                plimit                          = 0.2;
                s2plot                          = stat{ngroup,ncue,ntest};
                s2plot.mask                     = s2plot.prob < plimit;
                ylim([-5 5]);
                
                if min(unique(s2plot.prob(nchan,:,:))) < plimit
                    
                    i = i + 1;
                    
                    %                     subplot(2,4,i);
                    
                    figure;
                    %                     plot(s2plot.time,squeeze(s2plot.stat(nchan,:,:) .* s2plot.mask(nchan,:,:)));
                    %                     plot(s2plot.freq,squeeze(s2plot.stat(nchan,:,:) .* s2plot.mask(nchan,:,:)));
                    %                     ylim([-5 5])
                    
                    cfg                             = [];
                    cfg.channel                     = nchan;
                    cfg.parameter                   = 'stat';
                    cfg.maskparameter               = 'mask';
                    cfg.maskstyle                   = 'outline';
                    cfg.colorbar                    = 'no';
                    cfg.zlim                        = [-3 3];
                    ft_singleplotTFR(cfg,s2plot);
                    colormap(redblue)
                    
                    title([lst_cue{ncue} ' ' s2plot.label(nchan) ' ' lst_behav{ntest} ' ' min(unique(s2plot.prob(nchan,:,:)))]);
                    
                end
            end
        end
    end
end

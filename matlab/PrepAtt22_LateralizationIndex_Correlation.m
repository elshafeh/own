clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_group       = suj_group(1:2);

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        cond_main               = 'CnD';
        
        ext_name2               = 'BroadAVM.waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked80Slct';
        
        fname_in                = ['../data/pat22_data/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        load(['../data/pat22_data/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        [~,~,strl_rt]      = h_new_behav_eval(suj);
        strl_rt            = strl_rt(sort([trial_array{:}]));
        
        freq               = rmfield(freq,'cumtapcnt');
        
        list_ix_cue        = {0,1,2};
        list_ix_tar        = {1:4,1:4,1:4};
        list_ix_dis        = {0,0,0};
        list_ix            = {'N','L','R'};
        
        for ncue = 1:length(list_ix_cue)
                        
            cfg                         = [];
            cfg.trials                  = h_chooseTrial(freq,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
            new_freq                    = ft_selectdata(cfg,freq);
            
            new_strl_rt                 = strl_rt(cfg.trials);
            
            audL                        = new_freq.powspctrm(:,5,:,:);
            audR                        = new_freq.powspctrm(:,6,:,:);
            lIdx                        = (audR-audL) ./ ((audR+audL)/2);
            
            time_window                 = 0.1;
            time_list                   = 0.5:time_window:1.1;
            freq_window                 = 0 ;
            freq_list                   = 5:15 ;
            
            allsuj_data{ngroup}{sb,ncue,1}.powspctrm    = [];
            allsuj_data{ngroup}{sb,ncue,1}.dimord       = 'chan_freq_time';
            
            allsuj_data{ngroup}{sb,ncue,1}.freq         = freq_list;
            allsuj_data{ngroup}{sb,ncue,1}.time         = time_list;
            allsuj_data{ngroup}{sb,ncue,1}.label        = {[list_ix{ncue} ' lat index']};
            
            for nfreq = 1:length(freq_list)
                for ntime = 1:length(time_list)
                    
                    lmt1    = find(round(new_freq.time,3) == round(time_list(ntime),3));
                    lmt2    = find(round(new_freq.time,3) == round(time_list(ntime) + time_window,3));
                    
                    lmf1    = find(round(new_freq.freq) == round(freq_list(nfreq)));
                    lmf2    = find(round(new_freq.freq) == round(freq_list(nfreq)+freq_window));
                    
                    data    = squeeze(lIdx(:,:,lmf1:lmf2,lmt1:lmt2));
                    data    = squeeze(mean(data,2));
                    
                    [rho,p] = corr(data,new_strl_rt , 'type', 'Spearman');
                    
                    rhoF    = .5.*log((1+rho)./(1-rho));
                    
                    allsuj_data{ngroup}{sb,ncue,1}.powspctrm(:,nfreq,ntime) = rhoF ;
                    
                end
            end
            
            allsuj_data{ngroup}{sb,ncue,2}               = allsuj_data{ngroup}{sb,ncue,1};
            allsuj_data{ngroup}{sb,ncue,2}.powspctrm(:)  = 0;
            
        end
    end
end

clearvars -except allsuj_data list_ix

freq_lim                        = [7 15];
time_lim                        = [0.6 1.1];

for ngroup = 1:length(allsuj_data)
    
    nsuj                        = size(allsuj_data{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t'); clc;
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';
    cfg.method                  = 'montecarlo';
    cfg.statistic               = 'depsamplesT';
    cfg.correctm                = 'cluster';
    cfg.neighbours              = neighbours;
    cfg.clusteralpha            = 0.05;
    cfg.alpha                   = 0.025;
    cfg.minnbchan               = 0;
    cfg.tail                    = 0;
    cfg.clustertail             = 0;
    cfg.numrandomization        = 1000;
    cfg.design                  = design;
    cfg.uvar                    = 1;
    cfg.ivar                    = 2;
    
    cfg.frequency               = freq_lim;
    cfg.latency                 = time_lim;
    
    for ncue = 1:size(allsuj_data{ngroup},2)
        stat{ngroup,ncue}            = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,ncue,1},allsuj_data{ngroup}{:,ncue,2});
    end
    
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

subplot_row                     = 2 ;
subplot_col                     = 3 ;
plimit                          = 0.1;

i         = 0;
for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        
        for nchan = 1:length(stat{ngroup,ncue}.label)
            
            i                               = i + 1 ;
            
            s2plot                          = stat{ngroup,ncue};
            s2plot.mask                     = s2plot.prob < plimit;
            
            
            subplot(subplot_row,subplot_col,i)
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.parameter                   = 'stat';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.colorbar                    = 'no';
            
            cfg.zlim                        = [-5 5];
            ft_singleplotTFR(cfg,s2plot);
            
            colormap(redblue)
            
            title([s2plot.label{nchan}])
            
            %             pow_to_plot                     = s2plot.mask .* s2plot.stat;
            %
            %             avrg_lim                        = [-2 2];
            %
            %             i                               = i + 1 ;
            %             subplot(subplot_row,subplot_col,i)
            %             plot(s2plot.freq,squeeze(mean(pow_to_plot(nchan,:,:),3))); xlim(freq_lim); ylim(avrg_lim);
            %             title('Av Time')
            %
            %             i                               = i + 1 ;
            %             subplot(subplot_row,subplot_col,i)
            %             plot(s2plot.time,squeeze(mean(pow_to_plot(nchan,:,:),2))); xlim(time_lim); ylim(avrg_lim);
            %             title('Av Freq')
            
        end
    end
end
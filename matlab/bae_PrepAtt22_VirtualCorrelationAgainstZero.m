clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

lst_group       = {'old','young'};

for ngroup = 1:length(lst_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        
        ext_name2               = 'broadAreas.1t20Hz.m800p2000msCov.waveletPOW.1t19Hz.m3000p3000.KeepTrialsMinEvoked10MStep80SlctSorted';
        
        fname_in                = ['../data/' suj '/field/' suj '.' cond_main '.' ext_name2 '.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
                
        lmt1            = find(round(freq.time,3) == round(-0.6,3));
        lmt2            = find(round(freq.time,3) == round(-0.2,3));
        
        bsl             = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
        bsl             = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
        
        freq.powspctrm  = freq.powspctrm ./ bsl ; clear bsl ;
        
        load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        [~,~,strl_rt]       = h_new_behav_eval(suj);
        strl_rt             = strl_rt(sort([trial_array{:}]));
        
        for ix_cue          = 1
            
            ix_trial                                    = 1:length(strl_rt);
            new_strl_rt                                 = strl_rt(ix_trial);
            
            time_window                                 = 0.1;
            time_list                                   = 0:time_window:1.1;
            freq_window                                 = 0 ;
            freq_list                                   = 5:15 ;
            
            allsuj_data{ngroup}{sb,ix_cue,1}.powspctrm  = [];
            allsuj_data{ngroup}{sb,ix_cue,1}.dimord     = 'chan_freq_time';
            
            allsuj_data{ngroup}{sb,ix_cue,1}.freq       = freq_list;
            allsuj_data{ngroup}{sb,ix_cue,1}.time       = time_list;
            allsuj_data{ngroup}{sb,ix_cue,1}.label      = freq.label;
            
            fprintf('Calculating Correlation for %s\n',suj)
            
            for nfreq = 1:length(freq_list)
                for ntime = 1:length(time_list)
                    
                    lmt1    = find(round(freq.time,3) == round(time_list(ntime),3));
                    lmt2    = find(round(freq.time,3) == round(time_list(ntime) + time_window,3));
                    
                    lmf1    = find(round(freq.freq) == round(freq_list(nfreq)));
                    lmf2    = find(round(freq.freq) == round(freq_list(nfreq)+freq_window));
                    
                    data    = squeeze(freq.powspctrm(ix_trial,:,lmf1:lmf2,lmt1:lmt2));
                    data    = mean(data,3);
                    
                    [rho,p] = corr(data,new_strl_rt , 'type', 'Spearman');
                    
                    mask    = p<0.05;
                    %                     rho     = mask .* rho ; %% !!!!
                    
                    rhoF    = .5.*log((1+rho)./(1-rho));
                    
                    allsuj_data{ngroup}{sb,ix_cue,1}.powspctrm(:,nfreq,ntime) = rho ; clear rho p data ;
                    
                end
            end
            
            allsuj_data{ngroup}{sb,ix_cue,2}               = allsuj_data{ngroup}{sb,1};
            allsuj_data{ngroup}{sb,ix_cue,2}.powspctrm(:)  = 0;
            
        end
        
    end
end

clearvars -except allsuj_data ;

freq_lim                        = [5 15];
time_lim                        = [0.5 1.1];

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

clearvars -except allsuj_data stat min_p p_val *_lim;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        figure;
        i         = 0;
        
        for nchan = 1:length(stat{ngroup,ncue}.label)
            
            i                               = i + 1 ;
            
            plimit                          = 0.3;
            s2plot                          = stat{ngroup,ncue};
            s2plot.mask                     = s2plot.prob < plimit;
            
            subplot_row                     = 4 ;
            subplot_col                     = 3 ;
            
            subplot(subplot_row,subplot_col,i)
            
            cfg                             = [];
            cfg.channel                     = nchan;
            cfg.parameter                   = 'stat';
            cfg.maskparameter               = 'mask';
            cfg.maskstyle                   = 'outline';
            cfg.colorbar                    = 'no';
            
            cfg.zlim                        = [-2 2];
            ft_singleplotTFR(cfg,s2plot);
            
            title([s2plot.label{nchan}])
            
            pow_to_plot                     = s2plot.mask .* s2plot.stat;
            
            avrg_lim                        = [-2 2];
            
            i                               = i + 1 ;
            subplot(subplot_row,subplot_col,i)
            plot(s2plot.freq,squeeze(mean(pow_to_plot(nchan,:,:),3))); xlim(freq_lim); ylim(avrg_lim);
            title('Av Time')
            
            i                               = i + 1 ;
            subplot(subplot_row,subplot_col,i)
            plot(s2plot.time,squeeze(mean(pow_to_plot(nchan,:,:),2))); xlim(time_lim); ylim(avrg_lim);
            title('Av Freq')
            
        end
    end
end
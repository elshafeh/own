clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_group{1}       = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};


for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                     = suj_list{sb};
        
        cond_main               = 'CnD';
        ext_name2               = 'MaxAudVizMotor.BigCov.VirtTimeCourse.waveletPOW.1t20Hz.m3000p3000.KeepTrialsMinEvoked';
        list_ix                 = {'N','L','R',''};
        
        for ncue          = 1:4
            
            fname_in                = ['../data/paper_data/' suj '.' list_ix{ncue} cond_main '.' ext_name2 '.mat'];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            lmt1            = find(round(freq.time,3) == round(-0.6,3)); % baseline period
            lmt2            = find(round(freq.time,3) == round(-0.2,3)); % baseline period
            
            bsl             = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
            bsl             = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
            
            freq.powspctrm  = freq.powspctrm ./ bsl ; clear bsl ;
            
            
            %             ix_trial                                    = h_chooseTrial(freq,0:2,0,1:4);
            %             new_strl_rt                                 = strl_rt(ix_trial);
            %
            %             time_window                                 = 0.1;
            %             time_list                                   = 0.5:time_window:1.1;
            %             freq_window                                 = 0 ;
            %             freq_list                                   = 7:15 ;
            
            allsuj_data{ngroup}{sb,ncue,1}.powspctrm  = [];
            allsuj_data{ngroup}{sb,ncue,1}.dimord     = 'chan_freq_time';
            
            allsuj_data{ngroup}{sb,ncue,1}.freq       = freq.freq ; %freq_list;
            allsuj_data{ngroup}{sb,ncue,1}.time       = freq.time ; %time_list;
            allsuj_data{ngroup}{sb,ncue,1}.label      = freq.label;
            
            fprintf('Calculating Correlation for %s\n',suj)
            
            for nfreq = 1:length(freq.freq)
                for ntime = 1:length(freq.time)
                    
                    %                     lmt1    = find(round(freq.time,3) == round(time_list(ntime),3));
                    %                     lmt2    = find(round(freq.time,3) == round(time_list(ntime) + time_window,3));
                    %
                    %                     lmf1    = find(round(freq.freq) == round(freq_list(nfreq)));
                    %                     lmf2    = find(round(freq.freq) == round(freq_list(nfreq)+freq_window));
                    %
                    %                     data    = squeeze(freq.powspctrm(:,:,lmf1:lmf2,lmt1:lmt2));
                    
                    data    = squeeze(freq.powspctrm(:,:,nfreq,ntime));
                    %                     data    = mean(data,3);
                    
                    load ../data/yctot/rt/rt_cond_classified.mat
                    
                    if ncue < 4
                        new_strl_rt  = rt_classified{sb,ncue};
                    else
                        new_strl_rt  = rt_all{sb};
                    end
                    
                    [rho,p] = corr(data,new_strl_rt , 'type', 'Spearman');
                    
                    %                     mask    = p<0.05;
                    %                     rho     = mask .* rho ; %% !!!!
                    
                    rhoF    = .5.*log((1+rho)./(1-rho));
                    
                    allsuj_data{ngroup}{sb,ncue,1}.powspctrm(:,nfreq,ntime) = rhoF ; % !!!
                    clear rho p data ;
                    
                end
            end
        end
    end
end

clearvars -except allsuj_data ;

freq_lim                        = [7 15];
time_lim                        = [0.6 1];
list_test                       = [2 1; 3 1; 3 2];

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
    
    for ncue = 1:size(list_test,1)
        stat{ngroup,ncue}            = ft_freqstatistics(cfg, allsuj_data{ngroup}{:,list_test(ncue,1),1},allsuj_data{ngroup}{:,list_test(ncue,2),1});
    end
    
end

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        [min_p(ngroup,ncue), p_val{ngroup,ncue}]  = h_pValSort(stat{ngroup,ncue}) ;
    end
end

clearvars -except allsuj_data stat min_p p_val *_lim list_test;

subplot_row                     = 3 ;
subplot_col                     = 2 ;
plimit                          = 0.05;

for ngroup = 1:size(stat,1)
    
    figure;
    i         = 0;
    
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
            %             cfg.colorbar                    = 'no';
            
            cfg.zlim                        = [-5 5];
            ft_singleplotTFR(cfg,s2plot);
            
            colormap(redblue)
            
            list_cue = {'L versus N','R versus N','R versus N'};

            title([s2plot.label{nchan} list_cue{ncue}])
            
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
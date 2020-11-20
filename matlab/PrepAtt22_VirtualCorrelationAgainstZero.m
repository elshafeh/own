clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

suj_group{1}       = {'yc1','yc2','yc3','yc4','yc8','yc9','yc10','yc11','yc12','yc13','yc14','yc15','yc16','yc17'};

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    for sb = 1:length(suj_list)
        
        suj                                             = suj_list{sb};
        
        cond_main                                       = 'CnD';
        
        ext_nam1                                        = 'prep21.maxAVMsepVoxel5per.50t120Hz.m800p2000msCov';
        ext_nam2                                        = 'waveletPOW.50t120Hz.m2000p2000.MinEvokedKeepTrials.mat';
        
        ext_name                                        = [ext_nam1 '.' ext_nam2];
        list_ix                                         = {''};
        
        for ncue = 1:length(list_ix)
            
            fname_in                                    = ['../data/paper_data/' suj '.' list_ix{ncue} cond_main '.' ext_name];
            fprintf('\nLoading %50s \n',fname_in);
            load(fname_in)
            
            %             freq                                        = h_transform_freq(freq,{[1:5 11:15],[6:10 16:20]},{'Left AcX','Right AcX'});
            
            lmt1                                        = find(round(freq.time,3) == round(-0.4,3)); % baseline period
            lmt2                                        = find(round(freq.time,3) == round(-0.2,3)); % baseline period
            
            bsl                                         = mean(freq.powspctrm(:,:,:,lmt1:lmt2),4);
            bsl                                         = repmat(bsl,[1 1 1 size(freq.powspctrm,4)]);
            
            freq.powspctrm                              = freq.powspctrm ./ bsl ; clear bsl ;
            
            cfg                                         = [];
            cfg.latency                                 = [0.2 2];
            cfg.avgoverfreq                             = 'yes';
            cfg.frequency                               = [60 100];
            freq                                        = ft_selectdata(cfg,freq);
            
            allsuj_data{ngroup}{sb,ncue,1}.powspctrm    = [];
            allsuj_data{ngroup}{sb,ncue,1}.dimord       = 'chan_freq_time';
            
            allsuj_data{ngroup}{sb,ncue,1}.freq         = freq.freq ; %freq_list;
            allsuj_data{ngroup}{sb,ncue,1}.time         = freq.time ; %time_list;
            allsuj_data{ngroup}{sb,ncue,1}.label        = freq.label;
            
            load ../data/yctot/rt/rt_CnD_adapt.mat ; new_strl_rt = rt_all{sb} ; % [~,~,~,~,new_strl_rt]                       = h_new_behav_eval(suj,0:2,0,1:4); clc ;
            
            
            ft_progress('init','text',['Calculating Correlation for' suj ]);
            
            tot_no_test                                 = length(freq.freq) * length(freq.time);
            ntest                                       = 0;
            
            for nfreq = 1:length(freq.freq)
                for ntime = 1:length(freq.time)
                    
                    ntest   = ntest+1;
                    
                    ft_progress(ntest/tot_no_test, 'Performing test %d from %d\n', ntest, tot_no_test);
                    
                    data    = squeeze(freq.powspctrm(:,:,nfreq,ntime));
                    
                    [rho,p] = corr(data,new_strl_rt , 'type', 'Spearman');
                    
                    rhoF    = .5.*log((1+rho)./(1-rho));
                    
                    allsuj_data{ngroup}{sb,ncue,1}.powspctrm(:,nfreq,ntime) = rhoF ; % !!!
                    
                end
            end
            
            allsuj_data{ngroup}{sb,ncue,2}               = allsuj_data{ngroup}{sb,1};
            allsuj_data{ngroup}{sb,ncue,2}.powspctrm(:)  = 0;
            
        end
        
    end
end

clearvars -except allsuj_data ;

freq_lim                        = [50 110];
time_lim                        = [0.2 1];

for ngroup = 1:length(allsuj_data)
    
    nsuj                        = size(allsuj_data{ngroup},1);
    [design,neighbours]         = h_create_design_neighbours(nsuj,allsuj_data{1}{1},'virt','t'); clc;
    
    cfg                         = [];
    cfg.clusterstatistic        = 'maxsum';
    cfg.method                  = 'montecarlo';
    cfg.statistic               = 'depsamplesT';
    
    cfg.correctm                = 'cluster';
    
    %     cfg.avgoverfreq             = 'yes';
    %     cfg.avgovertime             = 'yes';

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
    
    %     cfg.frequency               = freq_lim;
    %     cfg.latency                 = time_lim;
    
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

figure;
i               = 0 ;
p_limit         = 0.4;

for ngroup = 1:size(stat,1)
    for ncue = 1:size(stat,2)
        
        stoplot             = stat{ngroup,ncue};
        
        for nchan = 1:length(stoplot.label)
            
            i                   = i + 1;
            
            stoplot.mask        = stoplot.prob < p_limit;
            
            subplot(2,1,i)
            
            [x_ax,y_ax,z_ax]    = size(stoplot.stat);
            
            if y_ax == 1
                
                plot(stoplot.time,squeeze(stoplot.mask(nchan,:,:) .* stoplot.stat(nchan,:,:)));
                ylim([-3 3]);
                xlim([stoplot.time(1) stoplot.time(end)])
                
            elseif z_ax == 1
                
                plot(stoplot.freq,squeeze(stoplot.mask(nchan,:,:) .* stoplot.stat(nchan,:,:)));
                ylim([-3 3]);
                xlim([stoplot.freq(1) stoplot.freq(end)])
                
            else
                
                cfg                             = [];
                cfg.channel                     = nchan;
                cfg.parameter                   = 'stat';
                cfg.colorbar                    = 'no';
                cfg.maskparameter               = 'mask';
                cfg.maskstyle                   = 'outline';
                cfg.zlim                        = [-2 2];
                ft_singleplotTFR(cfg,stoplot);
                
            end
            
            title(stoplot.label{nchan});
            
        end
    end
end
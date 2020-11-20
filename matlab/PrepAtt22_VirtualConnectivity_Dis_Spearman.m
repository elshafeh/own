clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_list = suj_group{3};

for sb = 1:length(suj_list)
    
    suj                             = suj_list{sb};
    
    fprintf('Loading Virtual Data For %s\n',suj)
    
    for cond_main = {'DIS','fDIS'}
        
        ext_virt                    = 'AudSchaef.50t120Hz.m200p800msCov';
        
        load(['../data/pat22_data/' suj '.' cond_main{:} '.' ext_virt '.mat']);
        
        cfg                         = [];
        cfg.trials                  = h_chooseTrial(virtsens,0:2,1,1:4);
        virtsens                    = ft_selectdata(cfg,virtsens);
        
        new_data                    = h_removeEvoked(virtsens);
        
        cfg                         = [];
        cfg.method                  = 'wavelet';
        cfg.output                  = 'pow';
        cfg.keeptrials              = 'yes';
        cfg.width                   = 7;
        cfg.gwidth                  = 4;
        cfg.toi                     = -1:0.01:1;
        cfg.foi                     = 50:110;
        freq                        = ft_freqanalysis(cfg,new_data);
        
        cfg                         = [];
        cfg.freq_start              = 60;
        cfg.freq_step               = 5;
        cfg.freq_end                = 100-cfg.freq_step;
        cfg.freq_window             = cfg.freq_step;
        freq                        = h_smoothFreq(cfg,freq);
        
        cfg                         = [];
        cfg.time_start              = 0;
        cfg.time_end                = 0.6;
        cfg.time_step               = 0.02;
        cfg.time_window             = cfg.time_step;
        freq                        = h_smoothTime(cfg,freq);
        
        fprintf('Calculating Connectivity For %s\n',[suj ' ' cond_main{:}]);
        
        freq_conn.powspctrm    = [];
        freq_conn.label        = {};
        
        i                 = 0;
        
        list_chan_seed    =  1:29;
        list_chan_target  =  1:29;
        
        chan_comb         = [];
        
        for nseed = 1:length(list_chan_seed)
            for ntarget = 1:length(list_chan_target)
                
                if list_chan_target(ntarget) ~= list_chan_seed(nseed)
                    
                    if ~isempty(chan_comb)
                        chk1                    =  chan_comb(chan_comb(:,1) ==  list_chan_seed(nseed) &  chan_comb(:,2) ==  list_chan_target(ntarget));
                        chk2                    =  chan_comb(chan_comb(:,2) ==  list_chan_seed(nseed) &  chan_comb(:,1) ==  list_chan_target(ntarget));
                    else
                        chk1                    = [];
                        chk2                    = [];
                    end
                    
                    if isempty(chk1) && isempty(chk2)
                        
                        i                       = i + 1;
                        data1                   = squeeze(freq.powspctrm(:,list_chan_seed(nseed),:,:));
                        data2                   = squeeze(freq.powspctrm(:,list_chan_target(ntarget),:,:));
                        
                        freq_conn.label{i}                                      = [freq.label{list_chan_seed(nseed)} ' to ' freq.label{list_chan_target(ntarget)}];
                        freq_conn.label{i}(strfind(freq_conn.label{i},'_'))     = ' ';
                        
                        fprintf('Calculating Connectivity For %s\n',[suj ' ' freq_conn.label{i}]);

                        for nfreq = 1:size(data1,2)
                            for ntime = 1:size(data1,3)
                                
                                new_data1               = squeeze(data1(:,nfreq,ntime));
                                new_data2               = squeeze(data2(:,nfreq,ntime));
                                
                                [rho,p]                 = corr(new_data1,new_data2, 'type', 'Spearman');
                                rhoF                    = 0.5 .* (log((1+rho)./(1-rho)));
                                
                                freq_conn.powspctrm(i,nfreq,ntime) = rhoF;
                                
                            end
                        end
                        
                        
                        chan_comb(i,1)          = list_chan_seed(nseed);
                        chan_comb(i,2)          = list_chan_target(ntarget);
                        
                    end
                end
            end
        end
        
        freq_conn.time      = freq.time;
        freq_conn.freq      = freq.freq;
        freq_conn.dimord    = freq.dimord;

        fprintf('Saving Connectivity For %s\n',[suj ' ' cond_main{:}]);
        
        save(['../data/pat22_data/' suj '.' cond_main{:} '1.' ext_virt '.PowSpearCorr.MinEvoked.mat'],'freq_conn','-v7.3');
        
        clear freq_conn ;
        
        clc;
        
    end
end
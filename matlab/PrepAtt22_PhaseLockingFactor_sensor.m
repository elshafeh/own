clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

list_cond                       = {'DIS','fDIS'};

for ncue = 1:length(list_cond)
    for sb = 1:21
        
        suj                             = ['yc' num2str(sb)];
        fname_in                    = ['../data/' suj '/field/' suj '.' list_cond{ncue} '.mat'];
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cfg                         = [];
        cfg.channel                 = {'MLC17', 'MLC25', 'MLF67', 'MLP44', 'MLP45', 'MLP56', 'MLP57', 'MLT14', 'MLT15', ...
            'MLT25', 'MRC17', 'MRF66', 'MRF67', 'MRP57', 'MRT13', 'MRT14', 'MRT23', 'MRT24'};
        cfg.method                  = 'wavelet';
        cfg.output                  = 'fourier';
        cfg.toi                     = -0.3:0.01:0.6;
        cfg.foi                     = 5:120;
        cfg.keeptrials              = 'yes';
        freq                        = ft_freqanalysis(cfg, data_elan);
        
        name_ext_tfr            = [cfg.method upper(cfg.output)];
        name_ext_time           = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
        name_ext_freq           = [num2str(round(cfg.foi(1))) 't' num2str(round(cfg.foi(end))) 'Hz'];
        
        if strcmp(cfg.keeptrials,'yes')
            name_ext_trials = 'KeepTrials';
        else
            name_ext_trials = 'AvgTrials';
        end
        
        angles_raw                  = angle(freq.fourierspctrm);
        angles_avg                  = squeeze(mean(angles_raw,1));
        angles_abs                  = abs(angles_avg);
        
        tmpdat                      = freq.fourierspctrm;
        tmpdat                      = tmpdat./abs(tmpdat);
        itc                         = squeeze(abs(mean(tmpdat))); % this will give the itc
        
        clear freq_*
        
        freq_plf.label               = freq.label ;
        freq_plf.freq                = freq.freq ;
        freq_plf.time                = freq.time ;
        freq_plf.dimord              = 'chan_freq_time';
        freq_plf.powspctrm           = angles_abs ;
        
        freq_itc                     = freq_plf;
        freq_itc.powspctrm           = itc;
        
        cfg                          = [];
        cfg.channel                  = 'all';
        cfg.avgoverchan              = 'yes';
        freq_plf                     = ft_selectdata(cfg,freq_plf);
        freq_itc                     = ft_selectdata(cfg,freq_itc);
        
        freq_plf                     = rmfield(freq_plf,'cfg');
        freq_itc                     = rmfield(freq_itc,'cfg');
        
        freq_plf.label               = {'plf'};
        freq_itc.label               = {'itc'};
        
        fname_out                    = ['../data/' suj '/field/' suj '.' list_cond{ncue} '.' name_ext_tfr '.' name_ext_freq '.' name_ext_time '.' name_ext_trials '.Ang.ITC.mat'];
        fprintf('Saving %s\n',fname_out);
        
        save(fname_out,'freq_plf','freq_itc','-v7.3');
        
    end
end
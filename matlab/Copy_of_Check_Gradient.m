clear ; clc ;
addpath(genpath('../../../fieldtrip-20151124/'));

% suj_list = {'oc14','yc33','yc32','yc30','yc29','yc31','yc19'};
suj_list = {'yc30'};

for sb = 1:length(suj_list)
    
    
    suj                 = suj_list{sb};
    blocksArray         = PrepAtt2_funk_createDsBlocksCellArray(suj);
    
    fOUT                = ['../data/' suj '/res/' suj '.DsJumpLog.txt'];
    fid                 = fopen(fOUT,'a+');
    direc_ds_list       = dir(['../rawdata/' suj '/']);
    
    i                   = 0 ;
    
    for nbloc = 1:length(direc_ds_list)
        
        if length(direc_ds_list(nbloc).name) > 2
            if strcmp(direc_ds_list(nbloc).name(end-1:end),'ds')
                if i < 10
                    
                    i = i + 1;
                    
                    dirDsIn                 = ['../rawdata/' suj '/' direc_ds_list(nbloc).name];
                    
                    cfg                     =   [];
                    cfg.dataset             =   dirDsIn ;
                    cfg.trialdef.eventtype  =   'UPPT001';
                    cfg.trialdef.eventvalue =   [101 103 202 204 1 2 3 4];
                    cfg.trialdef.prestim    =   3;
                    cfg.trialdef.poststim   =   3;
                    cfg                     =   ft_definetrial(cfg);
                    
                    cfg.channel             = 'all';
                    data{i}                 = ft_preprocessing(cfg);
                    
                    cfg                     = [];
                    cfg.gradient            = 'G3BR';
                    data_denoise{i}         = ft_denoise_synthetic(cfg, data{i});clc;
                end
            end
        end
        
    end
    
    data_apend          = ft_appenddata([],data{:}); clear data ;
    data_denoise_append = ft_appenddata([],data_denoise{:}); clear data_denoise ;
    
    %     cfg                         = [];
    %     cfg.channel                 = 'MEG';
    %     cfg.latency                 = [0 1];
    %     for_ica                     = ft_selectdata(cfg,data_apend);
    %     for_ica_denoise             = ft_selectdata(cfg,data_denoise_append);
    %
    %     cfg                         = [];
    %     cfg.bpfilt                  = 'yes';
    %     cfg.bpfreq                  = [20 30];
    %     for_ica                     = ft_preprocessing(cfg,for_ica);
    %     for_ica_denoise             = ft_preprocessing(cfg,for_ica_denoise);
    %
    %     cfg                         = [];
    %     cfg.method                  = 'runica';
    %     comp                        = ft_componentanalysis(cfg,for_ica);
    %     comp_denoise                = ft_componentanalysis(cfg,for_ica_denoise);
    %
    %     cfg                         = [];
    %     cfg.component               = 1:10;
    %     cfg.layout                  = 'CTF275.lay';
    %     cfg.marker                  = 'off';
    %     ft_topoplotIC(cfg.comp);figure;
    %     ft_topoplotIC(cfg.comp_denoise);figure;

    %     cfg.bpfilt          = 'yes';
    %     cfg.bpfreq          = [0.1 40];
    %     avg                 = ft_preprocessing(cfg,avg);
    
    cfg                 = [];
    cfg.method          = 'mtmfft';
    cfg.output          = 'pow';
    cfg.channel         = 'MEG';
    cfg.foi             = 1:1:100;
    cfg.tapsmofrq       = 1;
    cfg.taper           = 'hanning';
    freq                = ft_freqanalysis(cfg,data_apend);
    freq_denoise        = ft_freqanalysis(cfg,data_denoise_append);
    
    new_freq                    = freq;
    new_freq.time               = new_freq.freq;
    new_freq.dimord             = 'chan_time';
    new_freq.avg                = new_freq.powspctrm;
    new_freq                    = rmfield(new_freq,'powspctrm');
    new_freq                    = rmfield(new_freq,'freq');
    new_freq                    = rmfield(new_freq,'cfg');
    
    new_freq_denoise            = freq_denoise;
    new_freq_denoise.time       = new_freq_denoise.freq;
    new_freq_denoise.dimord     = 'chan_time';
    new_freq_denoise.avg        = new_freq_denoise.powspctrm;
    new_freq_denoise            = rmfield(new_freq_denoise,'powspctrm');
    new_freq_denoise            = rmfield(new_freq_denoise,'freq');
    new_freq_denoise            = rmfield(new_freq_denoise,'cfg');
    
    group{1}                    = {'MLT22', 'MLT23', 'MLT33', 'MLT42'};
    group{2}                    = {'MRT22', 'MRT23', 'MRT33', 'MRT42'};
    group{3}                    = {'MLO34', 'MLT27', 'MLT37', 'MLT47'};
    group{4}                    = {'MRO24', 'MRO34', 'MRO44', 'MRT47'};
    
    cfg                         = [];
    cfg.layout                  = 'CTF275.lay';
    cfg.highlight               = 'on';
    cfg.highlightchannel        = [group{1} group{2} group{3} group{4}];
    cfg.highlightsymbol         = '.';
    cfg.marker                  = 'off';
    cfg.highlightcolor          = [0 0 0];
    cfg.highlightsize           = 30;
    ft_topoplotER(cfg,new_freq)
    
    figure;
    %
    %     for g = 1:length(group)
    %
    %         cfg             = [];
    %         cfg.channel     = group{g};
    %         cfg.avgoverchan = 'yes';
    %         slct            = ft_selectdata(cfg,new_freq);
    %         slct_denoise    = ft_selectdata(cfg,new_freq_denoise);
    %         subplot(2,2,g)
    %         hold on
    %         plot(slct.time,slct.avg,'LineWidth',2);
    %         plot(slct_denoise.time,slct_denoise.avg,'LineWidth',2);
    %         legend({'1st order','3rd order'})
    %
    %     end
    
    %     cfg=[];cfg.layout           = 'CTF275.lay';
    %     ft_topoplotER(cfg,new_freq)
    %
    %     cfg                         = [];
    %     cfg.channel                 = 'MEG';
    %     avg                         = ft_selectdata(cfg,data_apend);
    %     avg_denoise                 = ft_selectdata(cfg,data_denoise_append);
    
    %     cfg                 = [];
    %     cfg.bpfilt          = 'yes';
    %     cfg.bpfreq          = [0.1 40];
    %     avg                 = ft_preprocessing(cfg,avg);
    %     avg_denoise         = ft_preprocessing(cfg,avg_denoise);
    %
    %     avg                 = ft_timelockanalysis([],avg);
    %     avg_denoise         = ft_timelockanalysis([],avg_denoise);
    %
    %     cfg                 = [];
    %     cfg.method          = 'amplitude';
    %     avg                 = ft_globalmeanfield(cfg,avg);
    %     avg_denoise         = ft_globalmeanfield(cfg,avg_denoise);
    
end
clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list                    = [1:4 8:17];
    suj                         = ['yc' num2str(suj_list(sb))];
    ext_essai                   = 'CnD.RamaBigCov';
    
    fname_in                    = [suj '.' ext_essai];
    
    fprintf('\nLoading %50s \n',fname_in);
    load(['../data/pe/' fname_in '.mat'])
    
    cfg                         = [];
    cfg.method                  = 'wavelet';
    cfg.output                  = 'fourier';
    cfg.toi                     = -3:0.05:3;
    cfg.foi                     = 5:15;
    cfg.keeptrials              = 'yes';
    freq                        = ft_freqanalysis(cfg, virtsens);
    
    ext_time                    = ['m' num2str(abs(cfg.toi(1))*1000) 'p' num2str(abs(cfg.toi(end))*1000)];
    ext_freq                    = [num2str(cfg.foi(1)) 't' num2str(cfg.foi(end)) 'Hz'];
    
    fname_out                   = ['../data/tfr/' suj '.' ext_essai '.' cfg.method upper(cfg.output) '.' ext_freq '.' ext_time '.mat'];
    fprintf('\nSaving %50s \n\n',fname_out);
    save(fname_out,'freq','-v7.3');
    
    group={[5:8 88:91]};
    
    grp_lst = {'AuditoryPlusIPS'};
    
    for j = 1:length(grp_lst)
        
        cfg                     = [];
        cfg.channel             = group{j};
        cfg.latency             = [-2 2];
        new_freq                = ft_selectdata(cfg,freq);
        
        cfg                     = [];
        cfg.method              = 'coh';
        freq_coh                = ft_connectivityanalysis(cfg, new_freq);
        
        cfg                     = [];
        cfg.method              = 'coh';
        cfg.complex             = 'imag';
        freq_coh_imag           = ft_connectivityanalysis(cfg, new_freq);
        freq_coh_imag.cohspctrm = abs(freq_coh_imag.cohspctrm);
        
        cfg                     = [];
        cfg.method              = 'plv';
        freq_plv                = ft_connectivityanalysis(cfg, new_freq);
        
        freq_coh.powspctrm      = freq_coh.cohspctrm;
        freq_coh                = rmfield(freq_coh,'cohspctrm');
        
        freq_coh_imag.powspctrm = freq_coh_imag.cohspctrm;
        freq_coh_imag           = rmfield(freq_coh_imag,'cohspctrm');
        
        freq_plv.powspctrm      = freq_plv.plvspctrm;
        freq_plv                = rmfield(freq_plv,'plvspctrm');
        
        suj_coh{1}              = freq_coh;
        suj_coh{2}              = freq_coh_imag;
        suj_coh{3}              = freq_plv;
        
        clear new_freq
        
        fname_out               = ['../data/tfr/' suj '.' ext_essai '.' grp_lst{j} '.CohCohImagPLV.mat'];
        
        fprintf('\nSaving %50s \n\n',fname_out);
        save(fname_out,'suj_coh','-v7.3');
        
        clear freq_*
        
    end
    
    clear freq virtsens
    
end
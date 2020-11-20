clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list        = [1:4 8:17];
    suj             = ['yc' num2str(suj_list(sb))];
    ext_essai       = 'CnD.SomaGammaNoAVG.CoV.m800p2000ms.freq.1t120Hz';
    
    fname_in = [suj '.' ext_essai];
    fprintf('\nLoading %50s \n',fname_in);
    load(['../data/pe/' fname_in '.mat'])
    
    virtsens        = h_SomaPrepare(virtsens);
    tlist           = [-0.6 -0.2; 0.2 0.6; 0.6 1];
    
    for t = 1:3
        
        group={{33 34 57 58 87}};
        
        grp_lst = {'IPSFEF'};
        
        for j = 1:length(grp_lst)
            
            cfg             = [];
            cfg.channel     = cell2mat([31	32	75	76 group{j}]);
            cfg.latency     = tlist(t,:);
            data            = ft_selectdata(cfg,virtsens);
            
            cfg                     = [];
            cfg.output              = 'fourier';
            cfg.method              = 'mtmfft';
            cfg.taper               = 'hanning';
            cfg.foilim              = [1 120];
            cfg.tapsmofrq           = 2.5;
            cfg.keeptrials          = 'yes';
            freq                    = ft_freqanalysis(cfg,data);
            
            cfg                     = [];
            cfg.method              = 'coh';
            freq_coh                = ft_connectivityanalysis(cfg, freq);
            
            cfg                     = [];
            cfg.method              = 'coh';
            cfg.complex             = 'imag';
            freq_coh_imag           = ft_connectivityanalysis(cfg, freq);
            freq_coh_imag.cohspctrm = abs(freq_coh_imag.cohspctrm);
            
            cfg                     = [];
            cfg.method              = 'plv';
            freq_plv                = ft_connectivityanalysis(cfg, freq);
            freq_plv.cohspctrm      = freq_plv.plvspctrm;
            freq_plv                = rmfield(freq_plv,'plvspctrm');
            
            suj_coh{1}              = freq_coh;
            suj_coh{2}              = freq_coh_imag;
            suj_coh{3}              = freq_plv;
            
            clear freq data
            
            fname_out               = ['../data/tfr/' suj '.Soma.CohCohImagPLV.AuditoryWith' grp_lst{j} '.Bloc' num2str(t) '.mat'];
            
            fprintf('\nSaving %50s \n\n',fname_out);
            save(fname_out,'suj_coh','-v7.3');
            
            clear freq_coh freq_coh_imag freq_plv
            
        end
        
    end
    
    clear virtsens
    
end
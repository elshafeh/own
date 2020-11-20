clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    ext_lock    = 'CnD';
    
    for n_prt = 1:3
        
        load(['../data/headfield/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.5mm.mat']);
        fname_in = [suj '.pt' num2str(n_prt) '.' ext_lock];
        fprintf('Loading %50s\n',fname_in);
        load(['../data/elan/' fname_in '.mat'])
        
        data_elan    = ft_timelockanalysis([],data_elan);
        
        % create common filter
        
        cfg                     = [];
        cfg.toilim              = [-0.3 1.4];
        poi                     = ft_redefinetrial(cfg, data_elan);
        
        ext_filt_time           = ['m' num2str(abs(cfg.toilim(1))*1000) 'p' num2str(abs(cfg.toilim(2))*1000)];
        
        cfg                     = [];
        cfg.method              = 'mtmfft';
        cfg.foi                 = 5;
        cfg.tapsmofrq           = 4;
        cfg.output              = 'powandcsd';
        cfg.taper               = 'hanning';
        freq                    = ft_freqanalysis(cfg,poi);
        
        ext_filt_freq           = [num2str(cfg.foi-cfg.tapsmofrq) 't' num2str(cfg.foi+cfg.tapsmofrq) 'Hz'];
        
        cfg                     = [];
        cfg.method              = 'dics';
        cfg.frequency           = freq.freq;cfg.grid                = leadfield;
        cfg.headmodel           = vol;
        cfg.dics.keepfilter     = 'yes';cfg.dics.fixedori       = 'yes';
        cfg.dics.projectnoise   = 'yes';cfg.dics.lambda         = '5%';
        source                  = ft_sourceanalysis(cfg, freq); clear freq poi;
        
        com_filter              = source.avg.filter; clear source
        
        fprintf('Saving Filter\n');
        
        nfilterout = ['../data/filter/' suj '.pt' num2str(n_prt) '.' ext_lock '.' ext_filt_time '.' ext_filt_freq '.EvokedHanningCommonFilter.mat'];
        save(nfilterout,'com_filter','-v7.3');

        tlist = [-0.7 0.1 0.6];
        flist = [5 5 5];
        fpad  = 2;
        twin  = 0.5;
        tpad  = 0;
        
        for ntest = 1:length(tlist)
            
            cfg                     = [];
            cfg.toilim              = [tlist(ntest)-tpad tlist(ntest)+tpad+twin];
            poi                     = ft_redefinetrial(cfg, data_elan);
            
            cfg                     = [];
            cfg.method              = 'mtmfft';
            cfg.foi                 = flist(ntest);
            cfg.tapsmofrq           = fpad;
            cfg.output              = 'powandcsd';
            cfg.taper               = 'hanning';
            freq                    = ft_freqanalysis(cfg,poi);
            
            if tlist(ntest) < 0
                ext_ext= 'm';
            else
                ext_ext='p';
            end
            
            ext_time        = [ext_ext num2str(abs(tlist(ntest)*1000)) ext_ext num2str(abs((tlist(ntest)+twin)*1000))];
            ext_freq        = [num2str(flist(ntest)-cfg.tapsmofrq) 't' num2str(flist(ntest)+cfg.tapsmofrq) 'Hz'];
            
            cfg                     = [];
            cfg.method              = 'dics';
            cfg.frequency           = freq.freq;
            cfg.grid                = leadfield;
            cfg.grid.filter         = com_filter ;
            cfg.headmodel           = vol;
            cfg.dics.fixedori       = 'yes';
            cfg.dics.projectnoise   = 'yes';
            cfg.dics.lambda         = '5%';
            source                  = ft_sourceanalysis(cfg, freq);
            source                  = source.avg.pow;
            
            clear freq poi
            ext_name = [suj '.pt' num2str(n_prt) '.' ext_lock '.' ext_time '.' ext_freq '.EvokedHanningSource.mat'];
            fprintf('Saving Source\n');
            save(['../data/source/' ext_name],'source','-v7.3');
            clear source ext_name
            
        end
        
        clear leadfield com_filter data_elan
    end
    clear vol grid
end
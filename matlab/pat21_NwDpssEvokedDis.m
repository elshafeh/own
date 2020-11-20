clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    ext_lock    = {'DIS','fDIS'};
    
    for n_prt = 1:3
        
        for d = 1:length(ext_lock)
            
            load(['../data/headfield/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.5mm.mat']);
            fname_in = [suj '.pt' num2str(n_prt) '.' ext_lock{d}];
            fprintf('Loading %50s\n',fname_in);
            load(['../data/elan/' fname_in '.mat'])
            
            data_elan               = ft_timelockanalysis([],data_elan);

            % create common filter
            
            cfg                     = [];
            cfg.toilim              = [-0.3 0.7];
            singleData{d}           = ft_redefinetrial(cfg, data_elan); clear data_elan ;
            
            ext_filt_time           = ['m' num2str(abs(cfg.toilim(1))*1000) 'p' num2str(abs(cfg.toilim(2))*1000)];

            
        end
        
        poiConcat               = ft_appenddata([],singleData{:});
        
        cfg                     = [];
        cfg.method              = 'mtmfft';
        cfg.foi                 = 80;
        cfg.tapsmofrq           = 50;
        cfg.output              = 'powandcsd';
        cfg.taper               = 'hanning';
        freqConcat              = ft_freqanalysis(cfg,poiConcat);
        
        ext_filt_freq           = [num2str(cfg.foi-cfg.tapsmofrq) 't' num2str(cfg.foi+cfg.tapsmofrq) 'Hz'];
        
        cfg                     = [];
        cfg.method              = 'dics';
        cfg.frequency           = freqConcat.freq;cfg.grid                = leadfield;
        cfg.headmodel           = vol;cfg.dics.keepfilter     = 'yes';
        cfg.dics.fixedori       = 'yes';cfg.dics.projectnoise   = 'yes';
        cfg.dics.lambda         = '5%'; source                  = ft_sourceanalysis(cfg, freqConcat);
        clear freqConcat poiConcat;
        com_filter              = source.avg.filter;
        clear source
        
        nfilterout      = ['../data/filter/' suj '.pt' num2str(n_prt) '.DisfDis' ext_filt_time ext_filt_freq '.EvokedHanningCommonFilter.mat'];
        
        fprintf('Saving Filter %s\n',nfilterout);
        save(nfilterout,'com_filter','-v7.3');
        
        tlist = [round(-0.2:0.1:0.5,2) round(-0.2:0.1:0.5,2) round(-0.2:0.1:0.5,2) round(-0.2:0.1:0.5,2)];
        flist = [repmat(50,1,length(tlist)/4) repmat(70,1,length(tlist)/4) repmat(90,1,length(tlist)/4) repmat(110,1,length(tlist)/4)];
        fpad  = 10;
        twin  = 0.1;
        tpad  = 0;
        
        for d = 1:2
            
            data_elan                   = singleData{d};
            
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
                
                if tlist(ntest) < 0; ext_ext= 'm';else ext_ext='p';end
                
                ext_time        = [ext_ext num2str(abs(tlist(ntest)*1000)) ext_ext num2str(abs((tlist(ntest)+twin)*1000))];
                ext_freq        = [num2str(flist(ntest)-cfg.tapsmofrq) 't' num2str(flist(ntest)+cfg.tapsmofrq) 'Hz'];
                
                cfg                     = [];
                cfg.method              = 'dics';
                cfg.frequency           = freq.freq;cfg.grid                = leadfield;
                cfg.grid.filter         = com_filter ;
                cfg.headmodel           = vol;cfg.dics.fixedori       = 'yes';cfg.dics.projectnoise   = 'yes';
                cfg.dics.lambda         = '5%';
                source                  = ft_sourceanalysis(cfg, freq);
                source                  = source.avg.pow;
                
                clear freq
                
                ext_name = [suj '.pt' num2str(n_prt) '.' ext_lock{d} '.' ext_time '.' ext_freq '.EvokedHanningSource.mat'];
                fprintf('\nSaving %s\n',ext_name);
                save(['../data/source/' ext_name],'source','-v7.3');
                clear source ext_name
                
                
                clear poi
                
            end
        end
        
        clear leadfield com_filter data_elan singleData
        
    end
    
    clear vol grid
    
end
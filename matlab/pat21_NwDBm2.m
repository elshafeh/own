% low

clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    for n_prt = 1:3
        
        load(['../data/headfield/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.5mm.mat']);
        fname_in = [suj '.pt' num2str(n_prt) '.CnD'];
        fprintf('Loading %50s\n',fname_in);
        load(['../data/elan/' fname_in '.mat'])
        
        %         create common filter
        
        cfg                     = [];
        cfg.toilim              = [-0.8 2];
        poi                     = ft_redefinetrial(cfg, data_elan);
        
        cfg                     = [];
        cfg.method              = 'mtmfft';
        cfg.foi                 = 25;
        cfg.tapsmofrq           = 15;
        cfg.output              = 'powandcsd';
        freq                    = ft_freqanalysis(cfg,poi);
        
        cfg                     = [];
        cfg.method              = 'dics';
        cfg.frequency           = freq.freq;
        cfg.grid                = leadfield;
        cfg.headmodel           = vol;
        cfg.dics.keepfilter     = 'yes';
        cfg.dics.fixedori       = 'yes';
        cfg.dics.projectnoise   = 'yes';
        cfg.dics.lambda         = '5%';
        source                  = ft_sourceanalysis(cfg, freq);
        
        clear freq poi;
        
        com_filter              = source.avg.filter;
        
        clear source
        
        nfilterout = ['../data/filter/' suj '.pt' num2str(n_prt) '.CnD.m800p2000.10t40Hz.NewExplorCommonFilter.mat'];
        fprintf('Saving Filter\n');
        save(nfilterout,'com_filter','-v7.3');
        
        ntest = 4 ;

        tlist = [-0.6 0.2 0.7 1.4];
        flist = [25 25 25 25];
        twin  = 0.4;
        tpad  = 0;
        fpad  = 10;
        
        for n = 1:ntest
            
            cfg                     = [];
            cfg.toilim              = [tlist(n)-tpad tlist(n)+tpad+twin];
            poi                     = ft_redefinetrial(cfg, data_elan);
            
            cfg                     = [];
            cfg.method              = 'mtmfft';
            cfg.foi                 = flist(n);
            cfg.tapsmofrq           = fpad;
            cfg.output              = 'powandcsd';
            freq                    = ft_freqanalysis(cfg,poi);
            
            if tlist(n) < 0
                ext_ext= 'm';
            else
                ext_ext='p';
            end
            
            ext_time        = [ext_ext num2str(abs(tlist(n)*1000)) ext_ext num2str(abs((tlist(n)+twin)*1000))];
            ext_freq        = [num2str(flist(n)-cfg.tapsmofrq) 't' num2str(flist(n)+cfg.tapsmofrq) 'Hz'];
            
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
            ext_name = [suj '.pt' num2str(n_prt) '.CnD.' ext_time '.' ext_freq '.NewExploreSource.mat'];
            fprintf('Saving Source\n');
            save(['../data/source/' ext_name],'source','-v7.3');
            clear source ext_name
            
        end
    end
    
    clear leadfield com_filter data_elan
    
    clear vol grid
    
end
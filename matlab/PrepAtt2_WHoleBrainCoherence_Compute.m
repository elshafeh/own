clear ; clc ; dleiftrip_addpath ;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))] ;
    load(['../data/headfield/' suj '.VolGrid.5mm.mat']);
    
    ext_lock    = 'CnD';
    
    
    load(['../data/headfield/' suj '.pt' num2str(n_prt) '.adjusted.leadfield.2cm.mat']);
    
    fname_in = [suj '.pt' num2str(n_prt) '.' ext_lock];
    fprintf('Loading %50s\n',fname_in);
    load(['../data/elan/' fname_in '.mat'])
    
    % create common filter
    
    cfg                     = [];
    cfg.toilim              = [-0.8 2];
    poi                     = ft_redefinetrial(cfg, data_elan);
    
    cfg                     = [];
    cfg.method              = 'mtmfft';
    cfg.output              = 'fourier';
    cfg.keeptrials          = 'yes';
    cfg.foi                 = 10;
    cfg.tapsmofrq           = 5;
    freqCommon              = ft_freqanalysis(cfg,poi);
    
    cfg                     = [];
    cfg.frequency           = freqCommon.freq;
    cfg.method              = 'pcc';
    cfg.grid                = leadfield;
    cfg.headmodel           = vol;
    cfg.keeptrials          = 'yes';
    cfg.pcc.lambda          = '10%';
    cfg.pcc.projectnoise    = 'yes';
    cfg.pcc.keepfilter      = 'yes';
    cfg.pcc.fixedori        = 'yes';
    source                  = ft_sourceanalysis(cfg, freqCommon);
    com_filter              = source.avg.filter;
    
    clear source freqCommon
    
    nfilterout = ['../data/filter/' suj '.pt' num2str(n_prt) '.' ext_lock '.pccCommonFilter2cm.mat'];
    fprintf('Saving Filter\n');
    save(nfilterout,'com_filter','-v7.3');
    
    tlist = [-0.6 0.2 0.6 1.4];
    flist = [9 13] ;
    twin  = 0.4;
    tpad  = 0.25;
    
    for f = 1:length(flist)
        for t = 1:length(tlist)
            
            cfg                     = [];
            cfg.toilim              = [tlist(t)-tpad tlist(t)+tpad+twin];
            poi                     = ft_redefinetrial(cfg, data_elan);
            
            cfg                     = [];
            cfg.method              = 'mtmfft';
            cfg.output              = 'fourier';
            cfg.keeptrials          = 'yes';
            cfg.foi                 = flist(f);
            cfg.tapsmofrq           = 2;
            freq                    = ft_freqanalysis(cfg,poi);
            
            if tlist(t) < 0
                ext_ext= 'm';
            else
                ext_ext='p';
            end
            
            ext_time                = [ext_ext num2str(abs(tlist(t)*1000)) ext_ext num2str(abs((tlist(t)+twin)*1000))];
            ext_freq                = [num2str(flist(f)-cfg.tapsmofrq) 't' num2str(flist(f)+cfg.tapsmofrq) 'Hz'];
            
            cfg                   = [];
            cfg.frequency         = freq.freq;
            cfg.method            = 'pcc';
            cfg.grid              = leadfield;
            cfg.grid.filter       = com_filter;
            cfg.headmodel         = vol;
            cfg.keeptrials        = 'yes';
            cfg.pcc.lambda        = '10%';
            cfg.pcc.projectnoise  = 'yes';
            source                = ft_sourceanalysis(cfg, freq);
            
            source.pos            = grid.MNI_pos;
            
            cfg                          = [];
            cfg.method                   = 'coh';
            cfg.complex                  = 'absimag';
            source_conn                  = ft_connectivityanalysis(cfg, source);
            
            clear freq poi
            
            ext_name = [suj '.pt' num2str(n_prt) '.' ext_lock '.' ext_time '.' ext_freq '.PCCSource2cm.mat'];
            
            fprintf('Saving Source\n');
            
            save(['../data/new_source/' ext_name],'source','-v7.3');
            
            clear source ext_name
            
        end
    end
    
    clear leadfield com_filter data_elan
    
    
    clear vol grid
    
end
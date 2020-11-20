clear ; clc ; 

for sb = [1:4 8:17]
    
    suj         = ['yc' num2str(sb)] ;
    
    fname_in    =['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat'];
    load(fname_in);
    
    
    for prt = 1:3
        
        fprintf('\nLoading %s\n',fname_in);
        fname_in    = ['../data/' suj '/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat'];
        load(fname_in);

        fname_in    = [suj '.pt' num2str(prt) '.CnD'];
        
        fprintf('Loading %50s\n',fname_in);
        
        load(['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' fname_in '.mat'])
        
        data_in                 = data_elan ;
        
        time_list               = [-0.35 1.3];
        time_wind               = 0.15;
        
        clear data_elan
        
        cfg                     = [];
        cfg.toilim              = [-0.8 2];
        data                    = ft_redefinetrial(cfg, data_in);
        
        cfg                     = [];
        cfg.method              = 'mtmfft';
        cfg.output              = 'fourier';
        cfg.keeptrials          = 'yes';
        cfg.taper               = 'hanning';
        cfg.foi                 = 80;
        cfg.tapsmofrq           = 30;
        
        freq                    = ft_freqanalysis(cfg,data);

        
        cfg                     = [];
        cfg.method              = 'pcc';
        cfg.frequency           = freq.freq;
        cfg.grid                = leadfield;
        cfg.headmodel           = vol;
        cfg.pcc.projectnoise    = 'yes';
        cfg.pcc.lambda          = '5%';
        cfg.pcc.keepfilter      = 'yes';
        cfg.keeptrials          = 'yes';
        cfg.pcc.fixedori        = 'yes';
        source                  = ft_sourceanalysis(cfg, freq);
        com_filter              = source.avg.filter;

    end
end
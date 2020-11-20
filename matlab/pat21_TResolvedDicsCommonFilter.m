clear;clc;

for sb = 2:14;
    
    for pt = 1:3
        
        suj_list = [1:4 8:17];
        
        suj = ['yc' num2str(suj_list(sb))] ;
        
        fname_in = [suj '.pt' num2str(pt) '.CnD'];
        fprintf('Loading %50s \n\n',fname_in);
        load(['../data/' suj '/elan/' fname_in '.mat'])
        
        data = data_elan ;
        
        clear data_elan
        
        st_point = -0.7;
        tim_win  = 2.7;
        
        lm1 = st_point;
        lm2 = st_point+tim_win;
        
        cfg             = [];
        cfg.toilim      = [lm1 lm2];
        poi             = ft_redefinetrial(cfg, data);
        
        cfg               = [];
        cfg.method        = 'mtmfft';
        cfg.foi           = 10;
        cfg.tapsmofrq     = 1.1;
        cfg.output        = 'powandcsd';
        freq              = ft_freqanalysis(cfg,poi);
        
        load(['../data/' suj '/headfield/' suj '.pt' num2str(pt) '.adjusted.leadfield.5mm.mat']);
        load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);
        
        clc ; 
        
        cfg                     = [];
        cfg.method              = 'dics';
        cfg.grid                = leadfield;
        cfg.headmodel           = vol;
        cfg.dics.keepfilter     = 'yes';
        cfg.dics.fixedori       = 'yes';
        cfg.dics.projectnoise   = 'yes';
        cfg.dics.lambda         = '5%';
        source                  = ft_sourceanalysis(cfg, freq);
        
        com_filter              = source.avg.filter;
        
        FnameFilterOut = [suj '.pt' num2str(pt) '.TResolved.commonFilter' ];
        
        fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
        save(['../data/' suj '/filter/' FnameFilterOut '.mat'],'com_filter','-v7.3');
        
        clear source poi data freq com_filter
        
    end
    
    
end
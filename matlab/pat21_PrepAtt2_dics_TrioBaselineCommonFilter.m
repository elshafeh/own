clear;clc;

suj_list = [1:4 8:17];

for sb = 1:14
    
    for prt = 1:3
        
        st_point = -1.6 ;
        
        lck = 'DIS' ;
        suj = ['yc' num2str(suj_list(sb))] ;
        
        fname_in = [suj '.pt' num2str(prt) '.' lck];
        fprintf('\n\nLoading %50s \n\n',fname_in);
        load(['../data/' suj '/elan/' fname_in '.mat'])
        
        data = data_elan ;
        
        clear data_elan
        
        % Select period of interests
        
        tim_win = 2.3;
        
        lm1 = st_point;
        lm2 = st_point+tim_win;
        
        cfg             = [];
        cfg.toilim      = [lm1 lm2];
        poi             = ft_redefinetrial(cfg, data);
        
        clear data
        
        % Fourrier transform
        
        f_focus = 75;
        f_tap   = 2.4;
        
        for t = 1
            
            cfg               = [];
            cfg.method        = 'mtmfft';
            cfg.foi           = f_focus;
            cfg.tapsmofrq     = f_tap(t);
            cfg.output        = 'powandcsd';
            freq              = ft_freqanalysis(cfg,poi);
            
            fprintf('\nLoading Leadfield and Common Filters\n');
            load(['../data/' suj '/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
            load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);
            
            formul = 10 ; 
            
            cfg                     = [];
            cfg.method              = 'dics';
            cfg.frequency           = freq.freq;
            cfg.grid                = leadfield;
            cfg.headmodel           = vol;
            cfg.dics.fixedori       = 'yes';
            cfg.dics.projectnoise   = 'yes';
            cfg.dics.lambda         = '5%';
            cfg.dics.keepfilter     = 'yes';
            source                  = ft_sourceanalysis(cfg, freq);
            com_filter              = source.avg.filter;
            
            clear source
            
            ext_com = '' ; 
            
            FnameFilterOut = [suj '.pt' num2str(prt) '.' lck  '.' num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz.' ...
                'm' num2str(abs(st_point)*1000) 'p' num2str(abs(st_point+tim_win)*1000) '.FixedCommonFilter' ext_com];
            
            fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
            
            save(['../data/' suj '/filter/' FnameFilterOut '.mat'],'com_filter','-v7.3');
            
            clear source com_filter freq
            
        end
        
        clear poi
        
    end
end
clear;clc;dleiftrip_addpath ;

suj_list = [1:4 8:17];

for sb = 1:14
    
    for prt = 1:3
        
        st_point = [-0.45 0.9];
        
        lck = 'CnD' ;
        suj = ['yc' num2str(suj_list(sb))] ;
        
        fname_in = [suj '.pt' num2str(prt) '.' lck];
        fprintf('\n\nLoading %50s \n\n',fname_in);
        load(['../data/' suj '/elan/' fname_in '.mat'])
        
        data = data_elan ;
        
        clear data_elan
        
        % Select period of interests
        
        tim_win = 0.2;
        
        for p = 1:length(st_point)
            
            lm1 = st_point(p)-0.04;
            lm2 = st_point(p)+tim_win+0.04;
            
            cfg             = [];
            cfg.toilim      = [lm1 lm2];
            poi{p}          = ft_redefinetrial(cfg, data);
            
        end
        
        tmp = ft_appenddata([],poi{:}) ; poi = tmp ; clear tmp ;
        
        % Fourrier transform
        
        f_focus = 14;
        f_tap   = 3;
        
        for t = 1:length(f_tap)
            
            cfg               = [];
            cfg.method        = 'mtmfft';
            cfg.foi           = f_focus;
            cfg.tapsmofrq     = f_tap(t);              % 5  = 1tap 6 = 2tap
            cfg.output        = 'fourier';
            cfg.keeptrials    = 'yes';
            freq              = ft_freqanalysis(cfg,poi);
            
            fprintf('\nLoading Leadfield and Common Filters\n');
            load(['../data/' suj '/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
            load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);
            
            formul = f_tap(t) - 2 ; 
            
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
            
            ext_com = '.pcc.Fixed' ; 
            
            FnameFilterOut = [suj '.pt' num2str(prt) '.' lck  '.4KT.' num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz' ...
                '.commonFilter' ext_com];
            
            fprintf('\n\nSaving %50s \n\n',FnameFilterOut);
            save(['../data/' suj '/filter/' FnameFilterOut '.mat'],'com_filter','-v7.3');
            
            clear source com_filter freq
            
        end
        
        clear poi
        
    end
    
end
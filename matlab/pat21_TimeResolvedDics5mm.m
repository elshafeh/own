clear;clc;

for sb = 1:14;
    
    for pt = 1:3
        
        suj_list = [1:4 8:17];
        
        st_point = -3;
        
        lck = 'CnD' ;
        suj = ['yc' num2str(suj_list(sb))] ;
        
        fname_in = [suj '.pt' num2str(pt) '.' lck];
        fprintf('\n\nLoading %50s \n\n',fname_in);
        load(['../data/' suj '/elan/' fname_in '.mat'])
        
        data = data_elan ;
        
        clear data_elan
        
        tim_win     = 6;
        
        lm1 = st_point;
        lm2 = st_point+tim_win;
        
        cfg             = [];
        cfg.toilim      = [lm1 lm2];
        poi             = ft_redefinetrial(cfg, data);
        
        % Fourrier transform
        
        f_focus = 13;
        
        cfg                 = [];
        cfg.method          = 'mtmconvol';
        cfg.taper           = 'dpss';
        cfg.output          = 'powandcsd';
        cfg.foi             = f_focus;
        cfg.toi             = -3:0.05:3;
        cfg.t_ftimwin       = 4./cfg.foi;
        cfg.tapsmofrq       = 0.3.*cfg.foi;
        freq                = ft_freqanalysis(cfg,poi);
        
        clear poi
        
        load(['../data/' suj '/headfield/' suj '.pt' num2str(pt) '.adjusted.leadfield.5mm.mat']);
        load(['../data/' suj  '/headfield/' suj '.VolGrid.1cm.mat']);
        fname_filt = [suj '.pt' num2str(pt) '.CnD.all.mtmfft.7t15Hz.m700p1900.commonFilter.bsl.5mm'];
        fprintf('\n\nLoading %50s \n\n',fname_filt);
        load(['../data/' suj '/filter/' fname_filt '.mat'])
        
        tResolvedSource{pt} = [];
        
        for t = -0.7:0.1:1.2
            
            cfg                     = [];
            cfg.latency             = [t t+0.1];
            cfg.avgovertime         = 'yes';
            cfg.avgoverfreq         = 'yes';
            freq_slct               = ft_selectdata(cfg,freq);
            freq_slct.dimord        = 'chan_freq';
            freq_slct               = rmfield(freq_slct,'time');
            
            cfg                     = [];
            cfg.method              = 'dics';
            cfg.frequency           = freq_slct.freq;
            cfg.grid                = leadfield;
            cfg.grid.filter         = com_filter;
            cfg.headmodel           = vol;
            cfg.dics.projectnoise   = 'yes';
            cfg.dics.lambda         = '5%';
            source                  = ft_sourceanalysis(cfg,freq_slct);
            
            tResolvedSource{pt} = [tResolvedSource{pt} source.avg.pow];
            
            clear source
            
        end
        
        clearvars -except tResolvedSource pt sb
        
    end
    
    for n = 1:size(tResolvedSource{1},1)
        for t =1:size(tResolvedSource{1},2)
            tResolvedAvg.pow(n,t) = mean([tResolvedSource{1}(n,t) tResolvedSource{2}(n,t) tResolvedSource{3}(n,t)]);
        end
    end
    
    clear tResolvedSource n
    
    tResolvedAvg.time = -0.7:0.1:1.2;
    tResolvedAvg.freq = 13 ;
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))] ;
    
    save(['../data/' suj '/source/' suj '.tResolved.12t14Hz.m700p1200ms.mat'],'tResolvedAvg','-v7.3');
    
    clearvars -except sb
    
end
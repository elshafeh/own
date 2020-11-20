function h_dicsSeparate(suj,n_prt,data_in,list_cond,list_time,time_win,trilili,f_focus,tap,formul,ext_filter,leadfield,vol)

for ii = 1:length(data_in)
    
    for t = 1:length(list_time)
        
        lm1             = list_time(t)-trilili;
        lm2             = list_time(t)+time_win+trilili;
        
        cfg             = [];
        cfg.toilim      = [lm1 lm2];
        data            = ft_redefinetrial(cfg, data_in{ii});
        
        cfg               = [];
        cfg.method        = 'mtmfft';
        cfg.foi           = f_focus;
        cfg.tapsmofrq     = tap;
        cfg.output        = 'powandcsd';
        freq              = ft_freqanalysis(cfg,data);
        
        ext_freq            = [num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz'];
        
        FnameFilterIn = dir(['../data/filter/' suj '.pt' num2str(n_prt) '*'  ext_filter '*']);
        FnameFilterIn = ['../data/filter/' FnameFilterIn.name];
        
        fprintf('Loading %50s \n\n',FnameFilterIn);
        load(FnameFilterIn);
        
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
        
        source = source.avg.pow;
        
        if lm1 < 0
            ext_ext= 'm';
        else
            ext_ext='p';
        end
        
        ext_time_source = [ext_ext num2str(abs(list_time(t)*1000)) ext_ext num2str(abs((list_time(t)+time_win)*1000))];
        
        f_name_source = [suj '.pt' num2str(n_prt) '.' list_cond{ii} '.' ext_freq '.' ext_time_source '.dics'];
        
        fprintf('\n\nSaving %50s \n\n',f_name_source);
        
        save(['../data/source/' f_name_source '.mat'],'source','-v7.3');
        
    end
end
clear;clc;

suj_list = [1:4 8:17];

for a = 1:length(suj_list);
    
    st_point_all = [0.3 0.3 0.3];
    tim_win_all  = [0.3 0.3 0.3];
    f_focus_all  = [7   7   7];
    taptap       = [3   5   7];
    forfor       = [1   2   3];
    
    lck = 'DIS1' ;
    suj = ['yc' num2str(suj_list(a))] ;
    cnd = {'V','N','fV','fN'};
    
    for b = 1:3
        
        for c = 1:length(cnd)
            
            fname_in = [suj '.pt' num2str(b) '.' cnd{c} lck];
            fprintf('\n\nLoading %50s \n\n',fname_in);
            load(['../data/' suj '/elan/' fname_in '.mat'])
            data{c}         = data_elan ;
            clear data_elan
            
        end
        
        data{end+1} = ft_appenddata([],data{:});
        
        for c = [length(data) 1:length(cnd)];
            
            for x = 1:length(st_point_all);
                
                st_point    = st_point_all(x);
                tim_win     = tim_win_all(x);
                f_focus     = f_focus_all(x);
                wdth        = taptap(x);
                formul      = forfor(x);
                
                st_t = st_point ; % st_t = [-0.2-tim_win st_point];
                
                for t = 1:length(st_t)
                    
                    % Select period of interests
                    
                    lm1 = st_t(t);
                    lm2 = st_t(t)+tim_win;
                    
                    cfg             = [];
                    cfg.toilim      = [lm1 lm2];
                    poi             = ft_redefinetrial(cfg, data{c});
                    
                    % Fourrier transform
                    
                    cfg               = [];
                    cfg.method        = 'mtmfft';
                    cfg.foi           = f_focus;
                    cfg.tapsmofrq     = wdth;
                    cfg.output        = 'powandcsd';
                    freq              = ft_freqanalysis(cfg,poi);
                    
                    if lm1 < 0
                        ext1= 'm';
                    else
                        ext1='p';
                    end
                    
                    ext_com = 'dis.fc';
                    
                    fprintf('\nLoading Leadfield and Common Filters\n');
                    load(['../data/' suj '/headfield/' suj '.pt' num2str(b) '.adjusted.leadfield.1cm.mat']);
                    load(['../data/' suj  '/headfield/' suj '.VolGrid.1cm.mat']);
                    
                    if c == length(data)
                        
                        cfg                     = [];
                        cfg.method              = 'dics';
                        cfg.frequency           = freq.freq;
                        cfg.grid                = leadfield;
                        cfg.headmodel           = vol;
                        cfg.dics.projectnoise   = 'yes';
                        cfg.dics.lambda         = '5%';
                        cfg.dics.keepfilter     = 'yes';
                        source                  = ft_sourceanalysis(cfg, freq);
                        com_filter              = source.avg.filter;
                        
                        fname_out = [suj '.pt' num2str(b) '.' lck  '.all.mtmfft.' num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz.' ext1 num2str(abs(lm1*1000)) ext1 num2str(abs(lm2*1000)) '.common.filter.' ext_com];
                        fprintf('\n\nSaving %50s \n\n',fname_out);
                        save(['../data/' suj '/filter/' fname_out '.mat'],'com_filter','-v7.3')
                        
                        clear source freq com_filter poi
                        
                    else
                        
                        fname_in = [suj '.pt' num2str(b) '.' cnd{c} lck];
                        
                        fname_out = [fname_in '.all.mtmfft.' num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz.' ext1 num2str(abs(lm1*1000)) ext1 num2str(abs(lm2*1000)) '.' ext_com];
                        fprintf('\n Saving .. %30s\n',fname_out);
                        save(['../data/' suj '/tfr/' fname_out '.mat'],'freq')
                        
                        f_name_filt = [suj '.pt' num2str(b) '.' lck  '.all.mtmfft.' num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz.' ext1 num2str(abs(lm1*1000)) ext1 num2str(abs(lm2*1000)) '.common.filter.' ext_com];
                        fprintf('\nLoading %50s \n\n',f_name_filt);
                        load(['../data/' suj '/filter/' f_name_filt '.mat']);
                        
                        cfg                     = [];
                        cfg.method              = 'dics';
                        cfg.frequency           = freq.freq;
                        cfg.grid                = leadfield;
                        cfg.headmodel           = vol;
                        cfg.dics.projectnoise   = 'yes';
                        cfg.dics.lambda         = '5%';
                        cfg.grid.filter         = com_filter;
                        source                  = ft_sourceanalysis(cfg, freq);
                        
                        f_name_source = [fname_out '.source'];
                        fprintf('\n\nSaving %50s \n\n',f_name_source);
                        save(['../data/' suj '/source/' f_name_source '.mat'],'source','-v7.3');
                        
                        clear source com_filter freq
                        
                    end
                    
                end
                
            end
            
        end
        
        clear data
        
    end
    
    clearvars -except suj_list frq_suj a
    
end
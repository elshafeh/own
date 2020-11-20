clear;clc;dleiftrip_addpath;

for cond_freq = {'12t14Hz'} % ,'11t15Hz'}
    
    for cond_filter = {'FixedAvg'} % , 'Fixed','Free','FreeAvg','FixedAvg'}
        
        for sb = 10:14 % 1:14
            
            suj_list = [1:4 8:17];
            
            for prt = 1:3
                
                lck = 'CnD' ;
                suj = ['yc' num2str(suj_list(sb))] ;
                
                fname_in = [suj '.pt' num2str(prt) '.' lck];
                fprintf('\n\nLoading %50s \n\n',fname_in);
                load(['../data/' suj '/elan/' fname_in '.mat'])
                
                data = data_elan ;
                
                clear data_elan
                
                for cnd_time = 1:2
                    
                    st_point = [-0.45 0.9];
                    tim_win = 0.2;
                    
                    % Select period of interests
                    
                    lm1 = st_point(cnd_time)-0.015;
                    lm2 = st_point(cnd_time)+tim_win+0.015;
                    
                    cfg             = [];
                    cfg.toilim      = [lm1 lm2];
                    poi             = ft_redefinetrial(cfg, data);
                    
                    % Fourrier transform
                    
                    f_focus = 13;
                    f_tap   = str2double(cond_freq{:}(4:5))  - str2double(cond_freq{:}(1:2));
                    f_tap   = f_tap / 2 ;
                    f_tap   = f_tap + 4 ;
                    
                    cfg               = [];
                    cfg.method        = 'mtmfft';
                    cfg.foi           = f_focus;
                    cfg.tapsmofrq     = f_tap;
                    cfg.output        = 'powandcsd';
                    cfg.keeptrials    = 'yes';
                    freq              = ft_freqanalysis(cfg,poi);
                    
                    if lm1 < 0
                        ext1= 'bsl';
                    else
                        ext1='actv';
                    end
                    
                    fprintf('\nLoading Leadfield and Common Filters\n');
                    load(['../data/' suj  '/headfield/' suj '.VolGrid.5mm.mat']);
                    load(['../data/' suj  '/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat']);
                    
                    cfg                     = [];
                    cfg.method              = 'dics';
                    cfg.frequency           = freq.freq;
                    cfg.grid                = leadfield;
                    cfg.headmodel           = vol;
                    cfg.dics.projectnoise   = 'yes';
                    cfg.dics.lambda         = '5%';
                    cfg.keeptrials          = 'yes';
                    cfg.rawtrial            = 'yes';
                    
                    if strcmp(cond_filter{:}(1:2),'Fi')
                        cfg.dics.fixedori       = 'yes';
                    else
                        cfg.dics.fixedori       = 'no';
                    end
                    
                    if strcmp(cond_filter{:}(end-2:end),'Avg')
                        fname_filt = [suj '.CnD.4KT.' cond_freq{:} '.commonFilter.' cond_filter{:}];
                    else
                        fname_filt = [suj '.pt' num2str(prt) '.CnD.4KT.' cond_freq{:} '.commonFilter.' cond_filter{:}];
                    end
                    
                    fprintf('\nLoading %50s \n\n',fname_filt);
                    load(['../data/' suj '/filter/' fname_filt '.mat']);
                    
                    cfg.grid.filter         = com_filter;
                    source                  = ft_sourceanalysis(cfg, freq);
                    source                  = [source.trial.pow];
                    
                    f_name_source = [suj '.pt' num2str(prt) '.' lck '.KT.' cond_freq{:} '.' ext1 ...
                        '.' cond_filter{:}];
                    
                    fprintf('Saving %50s \n',f_name_source);
                    save(['../data/' suj '/source/' f_name_source '.mat'],'source','-v7.3');
                    
                    clear source com_filter leadfield vol freq poi
                    
                end
                
                clear data
                
            end
            
        end
        
    end
    
    clearvars -except cond_filter cond_freq
    
end
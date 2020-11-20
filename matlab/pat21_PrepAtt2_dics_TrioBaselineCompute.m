clear;clc;dleiftrip_addpath;

suj_list = [1:4 8:17];

for a = 1:14
    
    for b = 1:3
        
        for xi = 1
            
            cond = {''};
            
            lck = [cond{xi} 'CnD'] ;
            suj = ['yc' num2str(suj_list(a))] ;
            
            fname_in = [suj '.pt' num2str(b) '.' lck];
            fprintf('\n\nLoading %50s \n\n',fname_in);
            load(['../data/' suj '/elan/' fname_in '.mat'])
            
            data = data_elan ;
            
            clear data_elan
                
            for c = 1
                
                st_point = 0.2;
                tim_win  = 0.4;
                
                % Select period of interests
                
                lm1 = st_point(c)-0.025;
                lm2 = st_point(c)+tim_win+0.025;
                
                cfg             = [];
                cfg.toilim      = [lm1 lm2];
                poi             = ft_redefinetrial(cfg, data);
                
                % Fourrier transform
                
                for d = 1:2;
                    
                    for e = 1
                        
                        lst_frq = [9 13];
                        lst_tap = 2;
                        
                        f_focus = lst_frq(d);
                        f_tap   = lst_tap(e);
                        formul  = round(f_tap-1);
                        
                        cfg               = [];
                        cfg.method        = 'mtmfft';
                        cfg.foi           = f_focus;
                        cfg.tapsmofrq     = f_tap;
                        cfg.output        = 'powandcsd';
                        freq              = ft_freqanalysis(cfg,poi);clc;
                        
                        if lm1 < 0
                            ext1= 'm';
                        else
                            ext1='p';
                        end
                        
                        ext_com = 'bsl.5mm.fixed';
                        
                        fprintf('\nLoading Leadfield and Common Filters\n');
                        load(['../data/' suj '/headfield/' suj '.pt' num2str(b) '.adjusted.leadfield.5mm.mat']);
                        load(['../data/' suj  '/headfield/' suj '.VolGrid.1cm.mat']);
                        
                        fname_filt = [suj '.pt' num2str(b) '.' lck  '.all.mtmfft.7t15Hz.m700p1900.commonFilter.' ext_com];
                        fprintf('\n\nLoading %50s \n\n',fname_filt);
                        load(['../data/' suj '/filter/' fname_filt '.mat'])
                        
                        fname_in = [suj '.pt' num2str(b) '.' lck];
                        
                        fname_tfr = [fname_in '.all.mtmfft.' num2str(f_focus-formul) 't' num2str(f_focus+formul) 'Hz.' ext1 num2str(abs((lm1+0.025)*1000)) ext1 num2str(abs((lm2-0.025)*1000)) '.' ext_com];
                        
                        cfg                     = [];
                        cfg.method              = 'dics';
                        cfg.frequency           = freq.freq;
                        cfg.grid                = leadfield;
                        cfg.headmodel           = vol;
                        cfg.dics.projectnoise   = 'yes';
                        cfg.dics.lambda         = '5%';
                        cfg.grid.filter         = com_filter;
                        cfg.dics.fixedori       = 'yes';
                        source                  = ft_sourceanalysis(cfg, freq);
                        
                        source = source.avg.pow;
                        
                        f_name_source = [fname_tfr '.source'];
                        fprintf('\n\nSaving %50s \n\n',f_name_source);
                        save(['../data/' suj '/source/' f_name_source '.mat'],'source','-v7.3');
                        
                        clear source com_filter freq fname_* f_* grid leadfield vol
                        
                    end
                    
                end
                
                clear poi
                
            end
            
            clearvars -except suj_list a b xi
            
        end
        
        clearvars -except suj_list a b 
        
    end
    
end
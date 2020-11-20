clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

load ../data/data_fieldtrip/allyc_ageing_suj_list_1Old_2Young_3AllYoung.mat

suj_list = suj_group{3};

for sb = 1:length(suj_list)
    
    suj                             = suj_list{sb};
    
    fprintf('Loading Virtual Data For %s\n',suj)
    
    for cond_main = {'DIS','fDIS'}
        
        ext_virt                    = 'AudSchaef.50t120Hz.m200p800msCov';
        
        load(['../data/pat22_data/' suj '.' cond_main{:} '.' ext_virt '.mat']);
        
        new_data                    = h_removeEvoked(virtsens);
        
        cfg                         = [];
        cfg.method                  = 'wavelet';
        cfg.output                  = 'fourier';
        cfg.keeptrials              = 'yes';
        cfg.width                   = 7;
        cfg.gwidth                  = 4;
        cfg.toi                     = -1:0.01:1;
        cfg.foi                     = 50:110;
        freq                        = ft_freqanalysis(cfg,new_data);
        
        %         cfg.freq_start              = 60;
        %         cfg.freq_step               = 2;
        %         cfg.freq_end                = 100-cfg.freq_step;
        %         cfg.freq_window             = cfg.freq_step;
        %         freq                        = h_smoothFreq(cfg,freq);
        
        cfg                         = [];
        cfg.latency                 = [-0.1 0.35];
        cfg.frequency               = [60 100];
        freq                        = ft_selectdata(cfg,freq);
        
        fprintf('Calculating Connectivity For %s\n',[suj ' ' cond_main{:}]);
        
        ext_name_out                = 'MinEvoked';
        
        cfg                         = [];
        cfg.method                  = 'plv';
        freq_conn                   = ft_connectivityanalysis(cfg,freq);
        
        freq_conn.powspctrm         = freq_conn.plvspctrm;
        freq_conn                   = rmfield(freq_conn,'dof');
        freq_conn                   = rmfield(freq_conn,'cfg');
        freq_conn                   = rmfield(freq_conn,'plvspctrm'); clc;
        
        fprintf('Saving Connectivity For %s\n',[suj ' ' cond_main{:}]);
        
        save(['../data/pat22_data/' suj '.' cond_main{:} '.' ext_virt '.' cfg.method '.' ext_name_out '.mat'],'freq_conn','-v7.3');
        clear freq_conn
        
    end
end
clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

suj_list           = [1:4 8:17] ;

for sb = 1:length(suj_list)
    
    suj                         = ['yc' num2str(suj_list(sb))] ;
    ext_data                    = 'CnD.PaperAudVisTD.1t20Hz.m800p2000msCov';
    
    fname                       = ['../data/conn/' suj '.' ext_data '.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    cond_ix_sub                 = {'N','L','R',''};
    cond_ix_cue                 = {0,1,2,0:2};
    cond_ix_dis                 = {0,0,0,0};
    cond_ix_tar                 = {1:4,1:4,1:4,1:4};
    
    list_time                   = [-0.6 0.6];
    tpad                        = 0.025;
    twin                        = 0.4;
    
    for ntime = 1:length(list_time)
        
        if list_time(ntime) < 0
            ext_time        = ['m' num2str(abs(list_time(ntime))*1000) 'm' num2str(abs(list_time(ntime)+twin)*1000)];
        else
            ext_time        = ['p' num2str(abs(list_time(ntime))*1000) 'p' num2str(abs(list_time(ntime)+twin)*1000)];
        end
        
        cfg                         = [];
        cfg.latency                 = [list_time(ntime)-tpad list_time(ntime)+tpad+twin];
        data_select                 = ft_selectdata(cfg,virtsens);
        
        for ncue = 1:length(cond_ix_sub)
            
            cfg                     = [];
            cfg.trials              = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
            data                    = ft_selectdata(cfg,data_select);
            
            data                    = h_removeEvoked(data);
            
            cfg                     = [];
            cfg.method              = 'mtmfft';
            cfg.taper               = 'dpss';
            cfg.output              = 'fourier';
            cfg.foilim              = [2 20];
            cfg.tapsmofrq           = 2;
            freq                    = ft_freqanalysis(cfg,data);
            
            cfg                     = [];
            cfg.freq                = [2 20];
            cfg.alpha               = 0.05;
            plf                     = mbon_PhaseLockingFactor(freq, cfg);
            
            fname_out               = ['../data/conn/' suj '.' cond_ix_sub{ncue} ext_data '.' ext_time '.plf.mat'];
            
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'plf','-v7.3'); clc;
            
            
        end
    end
end
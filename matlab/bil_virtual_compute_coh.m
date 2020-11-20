clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                                     = suj_list{nsuj};
    ext_virt                                        = 'mni.slct';
    fname                                           = ['I:\bil\virt\' subjectName '.virtualelectrode.' ext_virt '.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    list_time                                       = [0.5 1.5; 2 3; 3.5 4.5; 5 6; 0 0.5; 1.5 2; 3 3.5; 4.5 5];
    list_name                                       = {'cue1.to.gab1' 'gab1.to.cue2' 'cue2.to.gab2' 'gab2.to.resp' 'cue1' 'gab1' 'cue2' 'gab2'};
    list_cue                                        = {'pre' 'retro'};
    list_correct                                    = {'incorrect' 'correct'};
    
    for ntime = 1:size(list_time,1)
        for ncue = 1:2
            for ncor = 2
                
                cfg                                 = [];
                cfg.latency                         = list_time(ntime,:);
                cfg.trials                          = find(data.trialinfo(:,16) == ncor-1 & data.trialinfo(:,8)==ncue);
                data_select                         = ft_selectdata(cfg,data);
                
                cfg                                 = [];
                cfg.output                          = 'fourier';
                cfg.method                          = 'mtmfft';
                cfg.foi                             = 1:100;
                cfg.tapsmofrq                       = 1;
                cfg.keeptrials                      = 'yes';
                cfg.taper                           = 'hanning';
                cfg.pad                             = 2;
                freq                                = ft_freqanalysis(cfg, data_select);
                
                cfg                                 = [];
                cfg.method                          = 'coh';
                cfg.complex                         = 'imag';
                coh                                 = ft_connectivityanalysis(cfg, freq);
                
                fname_out                           = ['D:\Dropbox\project_me\data\bil\virt\' subjectName '.' ext_virt '.coh.imag.' list_cue{ncue} '.' list_correct{ncor} '.' list_name{ntime} '.mat'];
                fprintf('\nsaving %s\n',fname_out);
                save(fname_out,'coh','-v7.3'); clc;
                
                cfg                                 = [];
                cfg.method                          = 'coh';
                coh                                 = ft_connectivityanalysis(cfg, freq);
                
                fname_out                           = ['D:\Dropbox\project_me\data\bil\virt\' subjectName '.' ext_virt '.coh.' list_cue{ncue} '.' list_correct{ncor} '.' list_name{ntime} '.mat'];
                fprintf('\nsaving %s\n',fname_out);
                save(fname_out,'coh','-v7.3'); clc;
                
                
            end
        end
    end
end
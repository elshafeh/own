clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [0 1 2];
    list_cond                       = {'0back','1back','2Back'};
    
    for nback = 1:length(list_nback)
        
        list_lock                   = {'first','target'};
        avg_data                    = [];
        i                           = 0;
        
        for nlock = 1:length(list_lock)
            
            file_list             	= dir(['K:\nback\stim_per_cond\sub' num2str(suj_list(nsuj)) '.sess*.' ...
                num2str(list_nback(nback)) 'back.dwn70.' list_lock{nlock}  '.auc.mat']);
            
            tmp                     = [];
            
            for nf = 1:length(file_list)
                fname               = [file_list(nf).folder filesep file_list(nf).name];
                fprintf('loading %s\n',fname);
                load(fname);
                tmp                 = [tmp;scores]; clear scores;
            end
            
            avg_data(nlock,:)       = mean(tmp,1); clear tmp;
            
        end
        
        avg                       	= [];
        avg.time               		= time_axis;
        avg.label                   = list_lock;
        avg.avg                   	= avg_data; clear avg_data;
        avg.dimord              	= 'chan_time';
        
        cfg                         = [] ;
        cfg.output                  = 'pow';
        cfg.method                  = 'mtmconvol';
        cfg.keeptrials              = 'no';
        cfg.taper                   = 'hanning';
        cfg.pad                     = 10;
        cfg.toi                     = -1:0.03:2;
        cfg.foi                     = 1:1:30;
        cfg.t_ftimwin               = 5./cfg.foi;
        cfg.tapsmofrq               = 0.1 *cfg.foi;
        freq                        = ft_freqanalysis(cfg,avg);
        
        freq                        = rmfield(freq,'cfg');
        
        fname_out                   = ['J:/temp/nback/data/auc2mtm/sub' num2str(suj_list(nsuj)) '.' ...
            num2str(list_nback(nback)) 'back.dwn70.auc.mtm.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'freq','-v7.3');
        
        
    end
end
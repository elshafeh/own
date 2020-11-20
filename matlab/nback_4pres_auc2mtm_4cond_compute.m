clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                          	= [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    list_nback                      = [0 1];
    list_cond                       = {'0back','1back'};
    list_color                      = 'km';
    
    list_cond                       = list_cond(list_nback+1);
    list_color                      = list_color(list_nback+1);
    
    for nback = 1:length(list_nback)
        
        list_lock                   = {'all'};
        avg_data                    = [];
        i                           = 0;
        
        for nlock = 1:length(list_lock)
            
            fname                   = ['P:/3015079.01/nback/sens_level_auc/cond/sub'  num2str(suj_list(nsuj)) '.sess' num2str(nback) '.decoding.' ...
                num2str(list_nback(nback)) 'back.lockedon.' list_lock{nlock} '.dwn70.bsl.excl.auc.mat'];
            
            fprintf('loading %s\n',fname);
            
            load(fname);
            
            avg_data(nlock,:)       = scores; clear scores;
            
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
        
        fname_out                   = ['J:/temp/nback/data/auc2mtm/sub'  num2str(suj_list(nsuj)) '.decoding.' ...
            num2str(list_nback(nback)) 'back.lockedon.stim.auc.mtm.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'freq','-v7.3'); clear freq;
        
    end
    
    vct                       	= avg.avg;
    for xi = 1:size(vct,1)
        for yi = 1:size(vct,2)
            
            ln_rnd          	= [0.49:0.001:0.51];
            rnd_nb             	= randi(length(ln_rnd));
            vct(xi,yi)       	= ln_rnd(rnd_nb);
            
        end
    end
    
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
    
    fname_out                   = ['J:/temp/nback/data/auc2mtm/sub'  num2str(suj_list(nsuj)) '.decoding.chance.' ...
        'lockedon.stim.auc.mtm.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'freq','-v7.3'); clear freq;
    
end
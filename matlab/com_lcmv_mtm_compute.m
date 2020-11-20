clear;

suj_list                    = [1:4 8:17] ;
data_list                   = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        ext_name            = ['.CnD.brain1vox.dwn60.' data_list{ndata}];
        
        fname_in            = ['J:/temp/meeg/data/voxbrain/preproc/' suj ext_name '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        cfg                	= [] ;
        cfg.output      	= 'pow';
        cfg.method         	= 'mtmconvol';
        cfg.keeptrials  	= 'yes';
        cfg.taper        	= 'hanning';
        cfg.pad            	= 'nextpow2';
        cfg.toi            	= -1.5:0.05:2.5;
        cfg.foi            	= 1:1:30;
        cfg.t_ftimwin      	= 5./cfg.foi;
        cfg.tapsmofrq     	= 0.1 *cfg.foi;
        big_freq           	= ft_freqanalysis(cfg,data);
        big_freq         	= rmfield(big_freq,'cfg');
        
        list_ix_cue         = {[0:2],[1],[2],[1 2],[0]};
        list_ix_tar         = {[1:4],[1:4],[1:4],[1:4],[1:4]};
        list_ix_name        = {'all','left','right','inf','unf'};
        
        ext_freq            = h_freqparam2name(cfg);
        
        for ncond = 1:length(list_ix_name)
            
            cfg             = [];
            cfg.trials      = h_chooseTrial(big_freq,list_ix_cue{ncond},0,list_ix_tar{ncond});
            cfg.avgoverrpt  = 'yes';
            freq            = ft_selectdata(cfg,big_freq);
            freq           	= rmfield(freq,'cfg');
            
            fname         	= ['J:/temp/meeg/data/voxbrain/tf/' suj '.' list_ix_name{ncond} ext_name '.' ext_freq '.mat'];
            fprintf('Saving %s\n',fname);
            save(fname,'freq','-v7.3'); clear freq;
            
        end
        
        fprintf('\ndone\n\n');
        
    end
end
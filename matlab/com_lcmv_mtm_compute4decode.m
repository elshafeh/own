clear;

suj_list                            = [1:4 8:17] ;
data_list                           = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                             = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        ext_name                    = ['.CnD.brain1vox.dwn60.' data_list{ndata}];
        
        fname_in                    = ['J:/temp/meeg/data/voxbrain/preproc/' suj ext_name '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        %         trials_inf                  = h_chooseTrial(data,[1 2],0,1:4);
        %         trials_unf                  = h_chooseTrial(data,0,0,1:4);
        %         trials_lft                  = h_chooseTrial(data,1,0,1:4);
        %         trials_rte                  = h_chooseTrial(data,2,0,1:4);
        %         equal_inf                   = h_equalVectors({trials_inf,trials_unf});
        %         equal_sde                   = h_equalVectors({trials_lft,trials_rte});
        %         slct_trials                 = unique([equal_inf{1};equal_inf{2};equal_sde{1};equal_sde{2}]);
        
        orig_data                 	= data; clear data;
        
        time_width                  = 0.05;
        freq_width                  = 1;
        
        time_list                   = -1.5:time_width:2.5;
        freq_list                   = 1:freq_width:30;
        chan_list                   = 1:length(orig_data.label);
        
        cfg                         = [] ;
        cfg.output                  = 'pow';
        cfg.method                  = 'mtmconvol';
        cfg.keeptrials              = 'yes';
        cfg.taper                   = 'hanning';
        cfg.pad                     = 'nextpow2';
        cfg.toi                     = time_list;
        cfg.foi                     = freq_list;
        cfg.t_ftimwin               = 5./cfg.foi;
        cfg.tapsmofrq               = 0.1 *cfg.foi;
        cfg.channel                 = chan_list;
        freq                        = ft_freqanalysis(cfg,orig_data);
        
        for nf = 1:length(freq_list)
            
            data                    = orig_data;
            
            for xi = 1:length(data.trial)
                data.trial{xi}      = squeeze(freq.powspctrm(xi,:,nf,:));
                data.time{xi}       = freq.time;
            end
            
            data.label              = freq.label;
            
            fname_out               = ['J:/temp/meeg/data/voxbrain/tf/' suj ext_name '.' num2str(round(freq.freq(nf))) 'Hz.mtm.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'data');toc;
            
            clear data;clc;
            
        end
    end
end
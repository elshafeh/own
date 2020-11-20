clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

for n_suj = 1:51
    for n_ses = 1:2
        
        ext_virt                        = 'brain1vox';
        fname                           = ['J:/temp/nback/data/voxbrain/preproc/sub' num2str(n_suj) '.session' num2str(n_ses) '.' ext_virt '.mat'];
        
        if exist(fname)
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            time_width                  = 0.03;
            freq_width                  = 1;
            
            time_list                   = -1.5:time_width:2;
            freq_list                   = 1:freq_width:30;
            
            cfg                         = [] ;
            cfg.output                  = 'pow';
            cfg.method                  = 'mtmconvol';
            cfg.keeptrials              = 'yes';
            cfg.taper                   = 'hanning';
            cfg.pad                     = 'nextpow2';
            cfg.toi                     = time_list;
            cfg.foi                     = freq_list;
            cfg.t_ftimwin               = ones(length(cfg.foi),1).*0.5;
            cfg.tapsmofrq               = 0.1 *cfg.foi;
            big_freq                  	= ft_freqanalysis(cfg,data);
            big_freq                  	= rmfield(big_freq,'cfg');
            
            ext_freq                    = h_freqparam2name(cfg);
            
            for nback = [3]
                
                cfg                     = [];
                
                if nback == 3
                    cfg.trials       	= 1:length(big_freq.trialinfo);
                else
                    cfg.trials          = find(big_freq.trialinfo(:,1) == nback+4);
                end
                
                if ~isempty(cfg.trials)
                    
                    cfg.avgoverrpt      = 'yes';
                    freq                = ft_selectdata(cfg,big_freq);
                    freq                = rmfield(freq,'cfg');
                    
                    fname_out           = ['J:/temp/nback/data/voxbrain/tf/sub' num2str(n_suj) '.session' num2str(n_ses) '.' ext_virt '.' num2str(nback) 'back.' ext_freq(1:end-11) '.mat'];
                    fprintf('Saving %s\n',fname_out);
                    tic;save(fname_out,'freq','-v7.3');toc
                    
                    [allpeaks]          = h_virt_findpeak(freq,[-0.5 0]);
                    
                    fname_out           = ['J:/temp/nback/data/voxbrain/tf/sub' num2str(n_suj) '.session' num2str(n_ses) '.' ext_virt '.alphabetapeak.mat'];
                    fprintf('Saving %s\n',fname_out);
                    tic;save(fname_out,'allpeaks');toc
                    
                end
            end
        end
    end
end

%             [allpeaks,peak_name]        = h_findpeaks(freq,[-1 0]);
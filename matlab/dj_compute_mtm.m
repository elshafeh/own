close all;clc;
file_list                                           = dir('../data/preproc/*.fixlock.fin.mat');
i                                                   = 0;

for nf = 1:length(file_list)
    
    subjectName                                     = strsplit(file_list(nf).name,'.');
    subjectName                                     = subjectName{1};
    
    fname                                           = [file_list(nf).folder filesep file_list(nf).name];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    data                                            = h_ax2plan(data);
    
    for nfreq = [1 2 3]
        for ntarget = [0 3]
            
            ix_trials                               = find(data.trialinfo(:,2) == nfreq & data.trialinfo(:,3) == ntarget);
            ln_trials                               = length(ix_trials);
            prtin                                   = round(ln_trials/5);
            
            trial_count(nfreq,ntarget+1)            = length(ix_trials);
            
            for nratio  = [5]
                
                if nratio < 5
                    slct_trials                     = ix_trials(randperm(numel(ix_trials)));
                    slct_trials                     = ix_trials(1:prtin*nratio);
                else
                    slct_trials                     = ix_trials;
                end
                
                cfg                                 = [];
                cfg.trials                          = slct_trials;
                sub_data                            = ft_selectdata(cfg,data);
                sub_data                            = h_removeEvoked(sub_data);
                
                time_width                          = 0.03;
                freq_width                          = 0.1;
                
                time_list                           = -1:time_width:7;
                freq_list                           = freq_width:freq_width:15;
                
                cfg                                 = [] ;
                cfg.output                          = 'pow';
                cfg.method                          = 'mtmconvol';
                cfg.keeptrials                      = 'no';
                cfg.taper                           = 'hanning';
                cfg.tapsmofrq                       = 0;
                cfg.pad                             = 10;
                cfg.toi                             = time_list;
                cfg.foi                             = freq_list;
                cfg.t_ftimwin                       = ones(length(cfg.foi),1).*0.5;
                %                 cfg.polyremoval                     = 1;
                freq                                = ft_freqanalysis(cfg,sub_data);
                
                cfg                                 = []; cfg.method     = 'sum';
                freq_comb                           = ft_combineplanar(cfg,freq);
                
                fname                               = ['../data/tf/' subjectName '.freq' num2str(nfreq) '.' num2str(ntarget) 'cycles.'];
                fname                               = [fname num2str((nratio/5)*100) 'perc.mtm.minevoked.mat'];
                fprintf('Saving %s\n',fname);
                save(fname,'freq_comb','-v7.3');
                
                
            end
        end
    end
end
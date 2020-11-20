close all;clc;
file_list                                       = dir('../data/preproc/*.fixlock.fin.mat');
i                                               = 0;

for nf = 1:length(file_list)
    
    subjectName                                 = strsplit(file_list(nf).name,'.');
    subjectName                                 = subjectName{1};
    
    fname                                       = [file_list(nf).folder filesep file_list(nf).name];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    cfg                                             = [];
    cfg.demean                                      = 'yes';
    cfg.baselinewindow                              = [-0.1 0];
    cfg.lpfilter                                    = 'yes';
    cfg.lpfreq                                      = 20;
    data                                            = ft_preprocessing(cfg,data);
    
    trial_count                                     = [];
    
    for nfreq = [1 2 3]
        for ntarget = [0 1 2 3]
            
            ix_trials                               = find(data.trialinfo(:,2) == nfreq & data.trialinfo(:,3) == ntarget);
            ln_trials                               = length(ix_trials);
            prtin                                   = round(ln_trials/5);
            
            trial_count(nfreq,ntarget+1)            = length(ix_trials);
            
            for nratio  = [3 4 5]
                
                if nratio < 5
                    slct_trials                     = ix_trials(randperm(numel(ix_trials)));
                    slct_trials                     = ix_trials(1:prtin*nratio);
                else
                    slct_trials                     = ix_trials;
                end
                
                cfg                                 = [];
                cfg.trials                          = slct_trials;
                avg                                 = ft_timelockanalysis(cfg,data);
                
                cfg                                 = [];
                cfg.feedback                        = 'yes';
                cfg.method                          = 'template';
                cfg.neighbours                      = ft_prepare_neighbours(cfg, avg); close all;
                
                cfg.planarmethod                    = 'sincos';
                avg_planar                          = ft_megplanar(cfg, avg);
                
                avg_comb                            = ft_combineplanar([],avg_planar);
                
                avg_comb                            = rmfield(avg_comb,'cfg');
                avg                                 = rmfield(avg,'cfg');
                
                clc;
                
                fname                               = ['../data/erf/' subjectName '.freq' num2str(nfreq) '.' num2str(ntarget) 'cycles.'];
                fname                               = [fname num2str((nratio/5)*100) 'perc.mat'];
                fprintf('Saving %s\n',fname);
                save(fname,'avg_comb','-v7.3');
                
            end
        end
    end
    
    fname                                           = ['../data/preproc/' subjectName '.trialcount.mat'];
    fprintf('Saving %s\n',fname);
    save(fname,'trial_count');
    
end
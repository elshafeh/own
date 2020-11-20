clear ; clc;

if isunix
    project_dir                 = '/project/3015079.01/data/';
else
    project_dir                 = 'P:/3015079.01/data/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    
    fname                       = [project_dir subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('Loading %s\n',fname);
    load(fname);
    
    list_cue                    	= {'pre' 'retro'};
    
    for ncue = 1:length(list_cue)
        
        cfg                       	= [];
        cfg.trials                  = find(dataPostICA_clean.trialinfo(:,8) == ncue);
        data_axial                  = ft_selectdata(cfg,dataPostICA_clean);
        data_planar                 = h_ax2plan(data_axial); clear data_axial;
        
        fname                       = [project_dir subjectName '/tf/' subjectName '.' list_cue{ncue} 'cuelock.itc.5binned.withEvoked.withIncorrect.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
                
        for nbin = 1:length(phase_lock)
            
            cfg                     = [] ;
            cfg.output              = 'pow';
            cfg.method              = 'mtmconvol';
            cfg.keeptrials          = 'no';
            cfg.pad                 = 'maxperlen';
            cfg.foi                 = [1:1:40 42:2:100];
            cfg.t_ftimwin           = ones(length(cfg.foi),1).*0.5;
            cfg.toi                 = -1:0.02:7;
            cfg.taper               = 'hanning';
            cfg.tapsmofrq           = 0.1 *cfg.foi;
            cfg.trials              = phase_lock{nbin}.index; % adapt trials per bin
            freq_planar             = ft_freqanalysis(cfg,data_planar);
            
            cfg                     = []; cfg.method = 'sum';
            freq_comb               = ft_combineplanar(cfg,freq_planar);
            freq_comb               = rmfield(freq_comb,'cfg');
            
            fname                   = [project_dir subjectName '/tf/' subjectName '.' list_cue{ncue} 'cue.itc.withcorrect.bin' num2str(nbin) '.mtm.mat'];
            fprintf('\nSaving %s\n\n',fname);
            save(fname,'freq_comb','-v7.3'); clear freq_comb freq_planar;
            
        end
    end
end
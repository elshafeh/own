clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    subjectName                 = suj_list{ns};
    fname                       = [project_dir 'data/' subjectName '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    
    fprintf('Loading %s\n\n',fname);
    load(fname);
    
    fname                       = [project_dir 'data/' subjectName '/tf/' subjectName '.itc.incorrect.index.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    time_width                  = 0.05;
    time_list                   = -1:time_width:7;
    freq_list                   = 1:1:40;
    
    for nbin = [1 5]
        
        cfg                   	= [] ;
        cfg.output           	= 'pow';
        cfg.method              = 'mtmconvol';
        cfg.keeptrials      	= 'yes';
        cfg.taper            	= 'hanning';
        cfg.pad                 = 'nextpow2';
        cfg.toi             	= time_list;
        cfg.trials              = bin_index(:,nbin);
        
        index                   = dataPostICA_clean.trialinfo(cfg.trials,:);
        
        dir_data_out            = 'D:\Dropbox\project_me\data\bil\mtm\in\';
        ext_name                = ['.cue.itcbin' num2str(nbin) '.mtm4decode.'];
        fname_out               = [dir_data_out subjectName ext_name 'trialinfo.mat'];
        fprintf('Saving %s\n',fname_out);
        save(fname_out,'index');
        
        for nf = 1 : length(freq_list)
            
            cfg.foi             = freq_list(nf);
            cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
            cfg.tapsmofrq      	= 0.1 *cfg.foi; % !!
            freq                = ft_freqanalysis(cfg,dataPostICA_clean);
            
            data                = dataPostICA_clean;
            data.trialinfo      = dataPostICA_clean.trialinfo(cfg.trials,:);
            data.sampleinfo   	= dataPostICA_clean.sampleinfo(cfg.trials,:);
            data.trial          = dataPostICA_clean.trial(cfg.trials);
            data.time           = dataPostICA_clean.time(cfg.trials);
            
            data.fsample     	= 1/time_width;
            
            for xi = 1:length(data.trial)
                data.trial{xi}  = squeeze(freq.powspctrm(xi,:,:,:));
                data.time{xi}   = freq.time;
            end
            
            fname_out           = [dir_data_out subjectName ext_name num2str(round(cfg.foi)) 'Hz.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'data','-v7.3'); clear freq data;
            
        end
    end
end
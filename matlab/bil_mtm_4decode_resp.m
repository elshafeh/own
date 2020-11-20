clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for ns = 1:length(suj_list)
    
    subjectName          	= suj_list{ns};
    
    fname                   = [project_dir 'data/' subjectName '/preproc/' subjectName '.resplock.dwnsample100Hz.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    data_axial              = data; clear data;

    time_width              = 0.05;
    time_list               = -4:time_width:1;
    freq_list               = [1:1:30 32:2:40];
    
    cfg                   	= [] ;
    cfg.output           	= 'pow';
    cfg.method              = 'mtmconvol';
    cfg.keeptrials      	= 'yes';
    cfg.taper            	= 'hanning';
    cfg.pad                 = 'nextpow2';
    cfg.toi             	= time_list;
    
    time_axis               = time_list;
    freq_axis               = freq_list;
    index                   = data_axial.trialinfo;
    
    dir_data_out            = '/project/3015039.06/bil/tf/';
    ext_name                = '.resplock.mtm4decode.';
    
    fname_out               = [dir_data_out subjectName ext_name 'trialinfo.mat'];
    fprintf('Saving %s\n',fname_out);
    save(fname_out,'index');
    
    fname_out               = [dir_data_out subjectName ext_name 'freqlist.mat'];
    fprintf('Saving %s\n',fname_out);
    save(fname_out,'freq_axis');
    
    fname_out               = [dir_data_out subjectName ext_name 'timelist.mat'];
    fprintf('Saving %s\n',fname_out);
    save(fname_out,'time_axis');
    
    for nf = 1 : length(freq_list)
        
        cfg.foi             = freq_list(nf);
        cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
        cfg.tapsmofrq      	= 0.1 *cfg.foi; % !!
        freq                = ft_freqanalysis(cfg,data_axial);
        
        data                = data_axial;
        for xi = 1:length(data.trial)
            data.trial{xi}  = squeeze(freq.powspctrm(xi,:,:,:));
            data.time{xi}   = freq.time;
        end
        
        fname_out           = [dir_data_out subjectName ext_name num2str(round(cfg.foi)) 'Hz.mat'];
        fprintf('Saving %s\n',fname_out);
        save(fname_out,'data','-v7.3'); clear freq data;
        
    end
    
end
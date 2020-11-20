clear ;

suj_list                        = dir('../data/sub*/preproc/*_firstcuelock_dwnsample100Hz.mat');

for ns = 1:length(suj_list)
    
    subjectName                 = suj_list(ns).name(1:6);
    
    chk                         = dir(['/Volumes/heshamshung/bil_freq_data/' subjectName '_mtmFreqbreak_50Hz.mat']);
    
    if isempty(chk)
        
        suj                     = subjectName;
        
        fname                   = [suj_list(ns).folder '/' suj_list(ns).name];
        fprintf('Loading %s\n\n',fname);
        load(fname);
        
        cfg                     = [];
        cfg.trials              = find(data.trialinfo(:,2) == 1);
        data_axial              = ft_selectdata(cfg,data); clear data;
        data_axial              = rmfield(data_axial,'cfg');
        
        time_width              = 0.03;
        freq_width              = 1;
        
        time_list               = -1:time_width:6;
        freq_list           	= [1:1:50 52:2:100];
        
        cfg                   	= [] ;
        cfg.output           	= 'pow';
        cfg.method              = 'mtmconvol';
        cfg.keeptrials      	= 'yes';
        cfg.taper            	= 'hanning';
        cfg.pad                 = 'nextpow2';
        cfg.toi             	= time_list;
        cfg.foi               	= freq_list;
        cfg.t_ftimwin           = 5./cfg.foi;
        cfg.tapsmofrq        	= 0.1 *cfg.foi;
        
        for nf = 1 : length(freq_list)
            cfg.foi             = freq_list(nf);
            cfg.t_ftimwin       = ones(length(cfg.foi),1).*0.5;
            freq                = ft_freqanalysis(cfg,data_axial);
            
            data                = data_axial;
            
            for xi = 1:length(data.trial)
                data.trial{xi}  = squeeze(freq.powspctrm(xi,:,:,:));
                data.time{xi}   = freq.time;
            end
            
            index               = freq.trialinfo;
            
            fname_out           = ['/Volumes/heshamshung/bil_freq_data/' suj '_mtmFreqbreak_' num2str(round(freq.freq)) 'Hz.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'data','-v7.3');
            
            fname_out           = [fname_out(1:end-4) '_trialinfo.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'index');toc;
            
        end
    end
end
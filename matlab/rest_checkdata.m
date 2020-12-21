clear;

if ispc
    start_dir = 'D:/Dropbox/project_me/data/resting/';
else
    start_dir = '~/Dropbox/project_me/data/resting/';
end

file_list                               = dir([start_dir '/*']);
suj_list                                = {};

for nf = 1:length(file_list)
    if ~strcmp(file_list(nf).name(1),'.')
        suj_list                        = [suj_list;file_list(nf).name];
        %         mkdir([start_dir file_list(nf).name '/preproc/']);
        %         mkdir([start_dir file_list(nf).name '/tf/']);
        %         mkdir([start_dir file_list(nf).name '/erf/']);
        %         mkdir([start_dir file_list(nf).name '/source/']);
    end
end

keep suj_list start_dir

%%

for ns = 1:length(suj_list)
    
    subjectName                         = suj_list{ns};
    
    dsFileName                          = [start_dir subjectName '/ds/' subjectName '.pat2.restingstate.thrid_order.ds'];
    finalName                           = [start_dir subjectName '/preproc/' subjectName '.pat22.restingstate.mat'];
    
    if ~exist(finalName)
        
        events                          = ft_read_event(dsFileName);
        hdr                             = ft_read_header(dsFileName,'headerformat','ctf_old');
        
        cfg                             = [];
        cfg.dataset                     = dsFileName;
        cfg.trialfun                    = 'ft_trialfun_general';
        cfg.trialdef.eventtype          = 'UPPT001';
        cfg.trialdef.eventvalue         = 253;
        cfg.trialdef.prestim            = 0;
        cfg.trialdef.poststim           = 5;
        trialdef                        = ft_definetrial(cfg);
        
        %% read in data
        cfg                             = [];
        cfg.dataset                     = dsFileName;
        cfg.trl                         = trialdef.trl;
        cfg.channel                     = {'MEG'};
        cfg.continuous                  = 'yes';
        cfg.bsfilter                    = 'yes';
        cfg.bsfreq                      = [49 51; 99 101; 149 151];
        cfg.precision                   = 'single';
        data                            = ft_preprocessing(cfg);
        
        %% DownSample to 300Hz
        cfg                             = [];
        cfg.resamplefs                  = 300;
        cfg.detrend                     = 'no';
        cfg.demean                      = 'no';
        data_downsample                 = ft_resampledata(cfg, data); clear data;
        
        %% check for outlier bad channels & trials
        % press !!! QUIT !!!
        cfg                           	= [];
        cfg.method                     	= 'summary';
        cfg.megscale                  	= 1;
        cfg.alim                       	= 1e-12;
        cfg.metric                    	= 'maxabs';
        data                            = ft_rejectvisual(cfg,data_downsample); clear data_downsample;
        
        % save data
        fprintf('saving %s\n',finalName);
        save(finalName,'data','-v7.3');
        
        clear data
        
    end
end
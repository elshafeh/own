function eyes_preproc_ds2mat

% lock to first cue and add behavior in trial info
% bandstop filter line-noise

subjectName                     = input('Enter Subject Name     :   ','s');
dsFileName                      = dir(['../data/' subjectName '/raw/' subjectName '_*.ds']);
dsFileName                      = [dsFileName.folder '/' dsFileName.name];

switch subjectName
    case 'pilot01'
        bloc_order              = [1 2 1 2 1 2 1 2];
    case 'pilot02'
        bloc_order              = [2 1 2 1 2 1 2 1];
    case 'pilot03'
        bloc_order              = [1 2 1 2 1 2 1 2];
    case 'pilot04'
        bloc_order              = [2 1 2 1 2 1 2 1];
    case 'pilot05'
        bloc_order              = [1 2 1 2 1 2 1 2];
end

cfg                             = [];
cfg.dataset                     = dsFileName;
cfg.trialfun                    = 'ft_trialfun_general';
cfg.trialdef.eventtype          = 'UPPT001';

cfg.trialdef.eventvalue         = [64 128];
cfg.trialdef.prestim            = 2;
cfg.trialdef.poststim           = 4;

cfg                             = ft_definetrial(cfg);

% - - this adds behavior to field struct
[trl,cue]                       = e_func_extract_behav_from_ds(dsFileName,bloc_order,76);
new_trl                         = [cfg.trl(cue.good,:) trl];
cfg.trl                         = new_trl;
% - - 

cfg.channel                     = {'MEG'};
cfg.continuous                  = 'yes';
cfg.bsfilter                    = 'yes';
cfg.bsfreq                      = [49 51; 99 101; 149 151];
cfg.precision                   = 'single';
data                            = ft_preprocessing(cfg);

% DownSample
cfg                             = [];
cfg.resamplefs                  = 300;
cfg.detrend                     = 'no';
cfg.demean                      = 'no';
data_downsample                 = ft_resampledata(cfg, data); clear data;

mkdir(['../data/' subjectName '/preproc/']);
mkdir(['../data/' subjectName '/tf/']);
mkdir(['../data/' subjectName '/erf/']);

% Save data
fname                           = ['../data/' subjectName '/preproc/' subjectName '_cuelock_raw_dwnsample.mat'];
fprintf('saving %s \n',fname);
save(fname,'data_downsample','-v7.3');
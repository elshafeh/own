clear;clc;
clc; global ft_default;
ft_default.spmversion = 'spm12';
addpath('../../BetaEvents/');

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1
    %% load
    subjectName               	= suj_list{nsuj};
    subject_folder            	= '~/Dropbox/project_me/data/bil/virt/'; %'I:/bil/virt/';
    ext_virt                  	= 'wallis';
    fname                     	= [subject_folder subjectName '.virtualelectrode.' ext_virt '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    %% fix trialinfo
    indx_rt                     = data.trialinfo(:,14);
    indx_rt(indx_rt(:,1) < median(indx_rt(:,1)),2) = 1;
    indx_rt(indx_rt(:,1) > median(indx_rt(:,1)),2) = 2;
    trialinfo                   = data.trialinfo;
    trialinfo                   = trialinfo(:,[7 8 16]); % 1st column is task , 2nd is cue and 3 correct
    trialinfo                   = [trialinfo indx_rt(:,2)]; % col.4 is RT
    trialinfo                   = [trialinfo [1:length(trialinfo)]']; % col 5 in index
    
    %% compute FFT
    cfg                         = [] ;
    cfg.output                  = 'pow';
    cfg.method                  = 'mtmconvol';
    cfg.keeptrials              = 'yes';
    cfg.pad                     = 10;
    cfg.foi                     = 1:1:40;
    cfg.t_ftimwin               = ones(length(cfg.foi),1).*0.5;
    cfg.toi                     = -1:0.02:7;
    cfg.taper                   = 'hanning';
    cfg.tapsmofrq               = 0.1 *cfg.foi;
    cfg.trials                  = trialinfo(trialinfo(:,3) == 1,5);
    freq                        = ft_freqanalysis(cfg,data);
    
    %% run burst analysis
    resultPath                  =subject_folder;
    thrFOM                      = 6;
    rhythm_band_inds            = 15:30; % indices of fVec that corresponds to 15 to 30 Hz band.
    rhythmid                    ='beta';
    datatypeid                  ='bil';
    
    
    for nchan = 1:size(freq.powspctrm)
        

        t1                      = find(round(freq.time,2) == round(-1,2));
        t2                      = find(round(freq.time,2) == round(0,2));
        indsoi                  = t1:t2; % Indices correspond to t = -1000:0 ms.

        data                    = squeeze(freq.powspctrm(:,nchan,:,t1:t2));
        data                    = permute(data,[2 3 1]);
        tVec                    = freq.time(t1:t2);
        fVec                    = freq.freq;
        YorN                    = 1:size(data,3);
        
        data(isnan(data))       = 0;
        
        rhythm_localmax_analysis(resultPath, datatypeid, [subjectName '_chan' num2str(nchan)], ...
            rhythmid, rhythm_band_inds, tVec, fVec, indsoi, data, YorN);
        
        rhythm_event_analysis(rhythmid, datatypeid, resultPath, [subjectName '_chan' num2str(nchan)], s, thrFOM, tVec, fVec, prestim_TFR_yes_no, YorN)
        
    end
    
end
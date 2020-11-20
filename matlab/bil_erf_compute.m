
clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName             = suj_list{nsuj};
    subject_folder          = ['P:/3015079.01/data/' subjectName '/'];
    fname                   = [subject_folder 'preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % - - low pass filtering
    cfg                  	= [];
    cfg.demean            	= 'yes';
    cfg.baselinewindow    	= [-0.1 0];
    cfg.lpfilter           	= 'yes';
    cfg.lpfreq           	= 20;
    data_axial           	= ft_preprocessing(cfg,dataPostICA_clean); clear dataPostICA_clean;
        
    trialinfo               = data_axial.trialinfo;
    trialinfo(trialinfo(:,16) == 0,16)     = 2; % change correct to 1(corr) and 2(incorr)
    trialinfo               = trialinfo(:,[7 8 16]); % 1st column is task , 2nd is cue and 3 correct
    
    list_cue                = {'pre','retro'};
    
    for ncue = 1:2
        
        %-- compute average
        cfg                 = [];
        cfg.trials      	= find(trialinfo(:,2) == ncue & ...
            trialinfo(:,3) == 1); % choose only correct trials
        avg              	= ft_timelockanalysis(cfg, data_axial);
        
        %-- combine planar
        cfg                 = [];
        cfg.feedback    	= 'yes';
        cfg.method         	= 'template';
        cfg.neighbours     	= ft_prepare_neighbours(cfg, avg); close all;
        cfg.planarmethod   	= 'sincos';
        avg_planar        	= ft_megplanar(cfg, avg);
        avg_comb        	= ft_combineplanar([],avg_planar);
        avg_comb            = rmfield(avg_comb,'cfg');
        
        dir_data            = 'I:\bil\erf\';
        fname               = [dir_data subjectName '.' list_cue{ncue}  '.cue.correct.erf.comb.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'avg_comb','-v7.3'); clear avg_*;
        
    end
end

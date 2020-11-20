clear ; clc;

if isunix
    start_dir             = '/project/';
else
    start_dir             = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    ext_virt                = 'wallis';
    
    subjectName             = suj_list{nsuj};
    subject_folder          = '~/Dropbox/project_me/data/bil/virt/'; 
    fname                   = [subject_folder subjectName '.virtualelectrode.' ext_virt '.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    % - - low pass filtering
    cfg                  	= [];
    cfg.demean            	= 'yes';
    cfg.lpfilter           	= 'yes';
    cfg.baselinewindow    	= [-0.1 0];
    cfg.lpfreq           	= 20;
    data                    = ft_preprocessing(cfg,data);
        
    trialinfo               = data.trialinfo;
    trialinfo(trialinfo(:,16) == 0,16)     = 2; % change correct to 1(corr) and 2(incorr)
    trialinfo               = trialinfo(:,[7 8 16]); % 1st column is task , 2nd is cue and 3 correct
    
    list_cue                = {'correct' 'incorrect'}; % {'pre' 'retro' 'all'};
    
    for ncue = 1:length(list_cue)
        
        %-- compute average
        cfg                 = [];
        cfg.trials          = find(trialinfo(:,3) == ncue);
        
        %         if ncue == 3
        %             cfg.trials   	= find(trialinfo(:,3) == 1); % choose only correct trials
        %         else
        %             cfg.trials    	= find(trialinfo(:,2) == ncue & trialinfo(:,3) == 1); % choose only correct trials
        %         end
        
        avg              	= ft_timelockanalysis(cfg, data);
        avg                 = rmfield(avg,'cfg');
        
        fname               = [subject_folder subjectName '.' ext_virt '.' list_cue{ncue}  '.erf.mat'];
        fprintf('Saving %s\n',fname);
        save(fname,'avg','-v7.3'); clear avg*;
        
    end
end
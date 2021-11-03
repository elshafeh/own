clear;

for nsuj = 7:21
    
    sujname                     = ['yc' num2str(nsuj)];
    
    dir_in                      = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
    dir_out                     = '~/Dropbox/project_me/data/pam/erf/';
    fname_in                    = [dir_in sujname '.CnD.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    % just cause im lacking the data locked to button-presses i'll manually
    % change the lock using the .pos files
    pos_in                      = load(['~/Dropbox/project_me/data/pam/pos/' sujname '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
    pos_in                      = pos_in(pos_in(:,3) == 0,[1 2]);
    pos_in(:,3)                 = floor(pos_in(:,2) / 1000);
    pos_in                      = pos_in(pos_in(:,3) == 1 | pos_in(:,3) == 9,:); % keep targets and presses
    
    pos_in(:,4)                 = pos_in(:,2) - pos_in(:,3)*1000; % get code
    pos_in(:,5)                 = floor(pos_in(:,4)/100); % get cue
    pos_in(:,6)                 = floor((pos_in(:,4)-100*pos_in(:,5))/10); % dis
    pos_in(:,7)                 = mod(pos_in(:,4),10); % target
    
    pos_in                      = pos_in(pos_in(:,6) == 0,:); % keep no dis only
    
    % choose cues and responses within same trial
    pos_final                   = [];
    
    for n = 1:length(pos_in)
        if pos_in(n,3) == 1 && pos_in(n+1,3) == 9
            if pos_in(n,4) == pos_in(n+1,4)
                pos_final       = [pos_final;pos_in(n:n+1,:)];
            end
        end
    end
    
    % get samples of cue and response
    sample_cue                  = pos_final(pos_final(:,3) == 1,1);
    sample_response             = pos_final(pos_final(:,3) == 9,1);
    
    sample_diff                 = sample_response - sample_cue;
    
    if length(sample_diff) == length(data_elan.trial)
        
        cfg                    	= [];
        cfg.window           	= [0.5 1];
        cfg.begsample        	= sample_diff;
        data_response           = h_redefinetrial(cfg,data_elan);
       
        % -- low pass filtering
        cfg                  	= [];
        cfg.demean            	= 'yes';
        cfg.baselinewindow    	= [-0.1 0];
        cfg.lpfilter           	= 'yes';
        cfg.lpfreq           	= 20;
        data_axial           	= ft_preprocessing(cfg,data_response);
        
        % -- compute avg
        cfg                     = [];
        avg                     = ft_timelockanalysis(cfg, data_axial);
        
        % -- combine planar
        cfg                     = [];
        cfg.feedback            = 'yes';
        cfg.method              = 'template';
        cfg.neighbours          = ft_prepare_neighbours(cfg, avg); close all;
        cfg.planarmethod        = 'sincos';
        avg_planar              = ft_megplanar(cfg, avg);
        avg_comb                = ft_combineplanar([],avg_planar);
        avg_comb                = rmfield(avg_comb,'cfg');
        
        fname_out           	= [dir_out sujname '.nBP.erf.mat'];
        fprintf('saving %s\n',fname_out);
        save(fname_out,'avg_comb','-v7.3');
        
    end
end
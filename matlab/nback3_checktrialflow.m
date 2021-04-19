clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    for nsess = 1:2
        
        fname                               = ['~/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% exclude trials with 0back trials and trials with previous
        %response
        cfg                                 = [];
        cfg.trials                          = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                                = ft_selectdata(cfg,data);
        sess_carr{nsess}                    = data; clear data;
        
    end
    
    %-%-% appenddata across
    data_concat                           	= ft_appenddata([],sess_carr{:}); clear sess_carr
    
    trialinfo(:,1)                       	= data_concat.trialinfo(:,1); % condition
    trialinfo(:,2)                       	= data_concat.trialinfo(:,3); % stim category
    trialinfo(:,3)                        	= rem(data_concat.trialinfo(:,2),10)+1; % stim identity
    trialinfo(:,4)                          = data_concat.trialinfo(:,6); % response
    trialinfo(:,5)                          = data_concat.trialinfo(:,7); % rt
    trialinfo(:,6)                        	= 1:length(data_concat.trialinfo); % trial indices to match with bin
    
    new_trialinfo                           = [];
    
    for nt = 1:length(trialinfo)
        
        % find first stimulus
        if trialinfo(nt,2) == 1
            
            nback_cond                      = trialinfo(nt,1);
            trl                             = [];
            
            switch nback_cond 
                case 5 %1back
                    
                    if nt < length(trialinfo) && trialinfo(nt+1,2) == 2
                        trl                 = trialinfo(nt:nt+1,:);
                    end
                    
                case 6 %2back
                    
                    if nt < length(trialinfo)-1 && trialinfo(nt+1,2) == 3 && trialinfo(nt+2,2) == 2
                        trl                 = trialinfo(nt:nt+2,:);
                    end
                    
            end
            
            if ~isempty(trl)
                
                % get rt
                trial_rt                        = trl(trl(:,2) == 2,5);
                % find incorrect responses
                find_incorrect                  = find(trl(:,4) == 2 | trl(:,4) == 4);
                
                if isempty(find_incorrect)
                    trl(:,5)                    = trial_rt;
                    new_trialinfo               = [new_trialinfo; trl]; clear trl;
                end
                
            end
            
        end
    end
    
    trialinfo                                   = new_trialinfo;
    
    keep trialinfo nsuj suj_list
    
    fname                                       = ['~/Dropbox/project_me/data/nback/trialinfo/sub' num2str(suj_list(nsuj)) '.flowinfo.mat'];
    fprintf('saving %s\n',fname);
    save(fname,'trialinfo'); clear trialinfo;
    
end
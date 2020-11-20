clear;close all;

suj_list                                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    for nsession = 1:2
        fname                                   = ['J:\temp\nback\data\nback_' num2str(nsession) '/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        tmp{nsession}                           = data; clear data;
    end
    
    data_concat                                 = ft_appenddata([],tmp{:}); clear tmp;
    trialinfo                                   = [data_concat.trialinfo [1:length(data_concat.trialinfo)]'];
    
    for nback = [4 5 6]
        
        if nback == 4
            
            % - - - - 0 Back - - - - - - %-%
            sub_info                            = trialinfo(trialinfo(:,1) == nback,:);
            trials_fill                         = sub_info(sub_info(:,3) ~= 1 & sub_info(:,5) == 0,:); % exclude ones preceeded by motor
            trials_correct                      = sub_info(sub_info(:,3) == 1 & sub_info(:,5) == 0,:); % exclude ones preceeded by motor
            
            newtrialinfo                        = [trials_fill;trials_correct]; clear trial_* sub_info
            newtrialinfo                        = newtrialinfo(:,[1 3 7 9]);
            
            cfg                                 = [];
            cfg.trials                          = newtrialinfo(:,4);
            data                                = ft_selectdata(cfg,data_concat);
            data                                = rmfield(data,'cfg');
            data.trialinfo                      = [repmat(1001,length(newtrialinfo),1) newtrialinfo]; clear newtrialinfo;
            index                               = data.trialinfo;
            
            fname_out                       	= ['I:\nback\preproc\sub' num2str(suj_list(nsuj)) '.' num2str(nback-4) 'back.rearranged.mat'];
            fprintf('Saving %s\n',fname_out);tic;
            save(fname_out,'data','-v7.3');toc;
            
            fname_out                       	= ['I:\nback\preproc\sub' num2str(suj_list(nsuj)) '.' num2str(nback-4) 'back.rearranged.trialinfo.mat'];
            fprintf('Saving %s\n',fname_out);tic;
            save(fname_out,'index');toc; clear data index fname;
            
        elseif nback == 5
            
            %-% - - - - 1 Back - - - - - %-%
            sub_info                            = trialinfo(trialinfo(:,1) == nback,:);
            trials_fill                         = sub_info(sub_info(:,3) == 0 & sub_info(:,5) == 0,:); % exclude ones preceeded by motor
            trials_nonfill                      = sub_info(sub_info(:,3) ~= 0 & sub_info(:,5) == 0 & mod(sub_info(:,6),2) ~= 0,:); % exclude incorrect
            
            trials_correct                      = [];
            
            for n = 1:length(trials_nonfill)-1
                chk_1                           = trials_nonfill(n,3);
                chk_2                           = trials_nonfill(n+1,3);
                
                if chk_1 == 1 && chk_2 == 2
                    trials_correct              = [trials_correct;trials_nonfill(n:n+1,:)]; clear chk_1 chk_2;
                end
            end
            
            choose_end                         	= [1:2:length(trials_fill)];
            trials_fill                         = trials_fill(1:choose_end(end-1)+1,:); % equalize trials
            
            newtrialinfo                        = [trials_fill;trials_correct]; clear trial_* sub_info
            newtrialinfo                        = newtrialinfo(:,[1 3 7 9]);
            
            cfg                                 = [];
            cfg.trials                          = newtrialinfo(:,4);
            tmp                                 = ft_selectdata(cfg,data_concat);
            tmp.trialinfo                       = newtrialinfo; 
            data                                = h_nback_stack_one(tmp);
            index                               = data.trialinfo; clear newtrialinfo tmp;
            
            fname_out                       	= ['I:\nback\preproc\sub' num2str(suj_list(nsuj)) '.' num2str(nback-4) 'back.rearranged.mat'];
            fprintf('Saving %s\n',fname_out);tic;
            save(fname_out,'data','-v7.3');toc;
            
            fname_out                       	= ['I:\nback\preproc\sub' num2str(suj_list(nsuj)) '.' num2str(nback-4) 'back.rearranged.trialinfo.mat'];
            fprintf('Saving %s\n',fname_out);tic;
            save(fname_out,'index');toc; clear data index fname;
            
        elseif nback == 6
            
            %-% - - - - 2 Back - - - - - %-%
            sub_info                            = trialinfo(trialinfo(:,1) == nback,:);
            trials_fill                         = sub_info(sub_info(:,3) == 0 & sub_info(:,5) == 0,:); % exclude ones preceeded by motor
            trials_nonfill                      = sub_info(sub_info(:,3) ~= 0 & sub_info(:,5) == 0 & mod(sub_info(:,6),2) ~= 0,:); % exclude ones preceeded by motor and incorrect
            
            trials_correct                      = [];
            
            for n = 1:length(trials_nonfill)-2
                chk_1                           = trials_nonfill(n,3);
                chk_2                           = trials_nonfill(n+1,3);
                chk_3                           = trials_nonfill(n+2,3);
                
                if chk_1 == 1 && chk_2 == 3 && chk_3 == 2
                    trials_correct              = [trials_correct;trials_nonfill(n:n+2,:)]; clear chk_1 chk_2;
                end
            end
            
            choose_end                         	= [1:3:length(trials_fill)];
            trials_fill                         = trials_fill(1:choose_end(end-1)+2,:); % equalize trials
            newtrialinfo                        = [trials_fill;trials_correct]; clear trial_* sub_info
            newtrialinfo                        = newtrialinfo(:,[1 3 7 9]);
            
            cfg                                 = [];
            cfg.trials                          = newtrialinfo(:,4);
            tmp                                 = ft_selectdata(cfg,data_concat);
            tmp.trialinfo                       = newtrialinfo; 
            data                                = h_nback_stack_two(tmp); 
            index                               = data.trialinfo; clear newtrialinfo tmp;
            
            fname_out                       	= ['I:\nback\preproc\sub' num2str(suj_list(nsuj)) '.' num2str(nback-4) 'back.rearranged.mat'];
            fprintf('Saving %s\n',fname_out);tic;
            save(fname_out,'data','-v7.3');toc;
            
            fname_out                       	= ['I:\nback\preproc\sub' num2str(suj_list(nsuj)) '.' num2str(nback-4) 'back.rearranged.trialinfo.mat'];
            fprintf('Saving %s\n',fname_out);tic;
            save(fname_out,'index');toc; clear data index fname;
            
        end
        
        keep nback nsuj suj_list data_concat trialinfo
        
    end
    
end
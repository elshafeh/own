clear ;

for ns = [1:33 35:36 38:44 46:51]
    
    for nsess = 1:2
        
        icounter                                                = 0;
        data_carrier                                            = {};
        data_index                                              = [];
        
        chk                                                     = dir(['../data/stacked/data_sess' num2str(nsess) '_s' num2str(ns) '_3stacked.mat']);
        
        if isempty(chk)
            
            fname                                               = ['../data/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(ns) '.mat'];
            fprintf('\nloading %s\n',fname);
            load(fname);
            
            grad_struct                                         = data.grad;
            
            data                                                = rmfield(data,'grad');
            data                                                = rmfield(data,'sampleinfo');
            
            data_all                                            = h_addblocknumber(data); clear data;
            
            block_list                                          = unique(data_all.trialinfo(:,10));
            
            % here combine trials within each block!
            
            for nb = 1:length(block_list)
                
                cfg                                             = [];
                cfg.trials                                      = find(data_all.trialinfo(:,10) == block_list(nb));
                data                                            = ft_selectdata(cfg,data_all);
                
                if length(data.trial) > 2 % one subject had only 2 trials within a block..
                    
                    icounter                                    = icounter+1;
                    
                    new_data                                    = data;
                    
                    new_data.trial                              = {};
                    new_data.time                               = {};
                    new_data.trialinfo                          = [];
                    
                    for nt = 1:length(data.trial)
                        
                        if length(data.trial) - nt > 1
                            
                            tmp_info                            = [];
                            
                            % find first stim till onset of following one
                            lu                                  = nt;
                            ix1                                 = 1;
                            ix2                                 = find(round(data.time{lu},3) == round(2,3));
                            data_stim1                          = data.trial{lu}(:,ix1:ix2);
                            
                            tmp_info                            = [tmp_info 701 data.trialinfo(lu,:)];
                            
                            % take next stim from onset till next onset
                            lu                                  = lu+1;
                            ix1                                 = find(round(data.time{lu},3) == round(0,3));
                            ix2                                 = find(round(data.time{lu},3) == round(2,3));
                            data_stim2                          = data.trial{lu}(:,ix1:ix2);
                            
                            tmp_info                            = [tmp_info 702 data.trialinfo(lu,:)];
                            
                            % take next stim from onset till next onset
                            lu                                  = lu+1;
                            ix1                                 = find(round(data.time{lu},3) == round(0,3));
                            ix2                                 = find(round(data.time{lu},3) == round(2,3));
                            data_stim3                          = data.trial{lu}(:,ix1:ix2);
                            
                            tmp_info                            = [tmp_info 703 data.trialinfo(lu,:)];
                            
                            new_data.trial{nt}                  = [data_stim1 data_stim2 data_stim3];
                            
                            time_res                            = data.time{nt}(2) - data.time{nt}(1);
                            time_axs                            = data.time{nt}(1);
                            
                            for hi = 2:size(new_data.trial{nt},2)
                                time_axs(hi)                    = time_axs(hi-1)+time_res;
                            end
                            
                            new_data.time{nt}                   = time_axs;
                            new_data.trialinfo                  = [new_data.trialinfo; tmp_info];
                            
                            clear tmp_info lu ix* data_stim* time_*
                            
                        end
                    end
                    
                    data_carrier{icounter}                       = new_data;
                    data_index(icounter)                         = unique(new_data.trialinfo(:,2));clear new_data;
                    
                    clear data;
                end
                
            end
            
            data                                                = ft_appenddata([],data_carrier{:}); clear data_carrier;
            data.grad                                           = grad_struct; clear grad_struct;
            
            fname_out                                           = ['../data/stacked/data_sess' num2str(nsess) '_s' num2str(ns) '_3stacked.mat'];
            fprintf('Saving %s\n',fname_out);tic;
            save(fname_out,'data','-v7.3');toc;
            
            % !! THIS IS A MUST !!
            data_repair                                         = megrepair(data);
            
            h_erf_compute(data_repair,ns,nsess);
            h_mtm_compute(data_repair,ns,nsess);
            
            clear data data_repair;
            
        end
    end
end
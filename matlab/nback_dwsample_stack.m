clear ;

dir_data                                    = '/project/3015039.05/temp/nback/data/prepro/stack/';

for nsuj = [1:33 35:36 38:44 46:51]
    
    i                                       = 0;
    
    for nsess = 1:2
        
        fname_in                          	= [dir_data 'data_sess' num2str(nsess) '_s' num2str(nsuj) '_3stacked.mat'];
        
        if exist(fname_in)
            
            fprintf('\nloading %s',fname_in);
            load(fname_in);
            
            cfg                             = [];
            cfg.resamplefs                  = 100;
            cfg.detrend                     = 'no';
            cfg.demean                      = 'no';
            data                            = ft_resampledata(cfg, data);
            data                            = rmfield(data,'cfg');
                        
            fname_out                       = [dir_data 'sub' num2str(nsuj) '.sess' num2str(nsess) '.stack.dwn100.mat'];
            fprintf('Saving %s\n',fname_out);
            tic;save(fname_out,'data','-v7.3');toc; clear data;
            
            system(['rm ' fname_in]);
            
            %             index                           = data.trialinfo(:,2) - 4;
            %             fname_out                       = [dir_out 'sub' num2str(nsuj) '.stk.exl.trialinfo.mat'];
            %             fprintf('Saving %s\n',fname_out);
            %             tic;save(fname_out,'index');toc;
            
            clc;
            
        end
    end
end
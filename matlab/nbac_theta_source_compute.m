clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                        = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    subjectname                                 = ['sub' num2str(suj_list(nsuj))];
    
    fname                                       = ['J:/temp/nback/data/source/volgrid/' subjectname '.volgrid.0.5cm.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    fname                                       = ['J:/temp/nback/data/source/lead/' subjectname '.combined.leadfield.0.5cm.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    for nback = [0 1 2]
        
        fname                                   = ['I:\nback\preproc\' subjectname '.' num2str(nback) 'back.rearranged.mat'];
        fprintf('loading %s\n',fname);
        load(fname); clear fname;
        
        % - - select non-filler
        cfg                                     = [];
        cfg.trials                              = find(data.trialinfo(:,3) == 1);
        data                                    = ft_selectdata(cfg,data); data = rmfield(data,'cfg');
        
        fname                                   = ['J:/temp/nback/data/grad_orig/grad' num2str(suj_list(nsuj)) '.mat'];
        load(fname);
        data.grad                               = grad; %clear grad;
        
        cfg                                     = [];
        cfg.channel                             = data.label;
        leadfield_slct                          = ft_selectdata(cfg,leadfield);
        
        freq_interest                           = 4;
        freq_window                             = 2;
        
        list_window                             = [-1.5 2; -1.5 4; -1.5 6];
        time_win_in                             = list_window(nback+1,:);
        
        com_filter                              = nbk_common_filter(data,leadfield_slct,vol,time_win_in,freq_interest,freq_window); clc;
        
        list_all_time{1}                        = [-1.2 -0.2; 0 1];
        list_all_time{2}                        = [-1.2 -0.2; 0 1; 2 3];
        list_all_time{3}                        = [-1.2 -0.2; 0 1; 2 3; 4 5];
        
        list_time                               = list_all_time{nback+1};
        
        for ntime = 1:size(list_time,1)
            
            t1                                  = list_time(ntime,1);
            t2                                  = list_time(ntime,2);
            
            [source,ext_name]                   = nbk_dics_separate(data,leadfield_slct,vol,com_filter,[t1 t2],freq_interest,freq_window);
            
            fname_out                           = ['I:\nback\source\' subjectname '.' num2str(nback) 'back.rearranged.nonfill.' ext_name  '.dics.mat'];
            fprintf('saving %s\n',fname_out);
            save(fname_out,'source','-v7.3'); clc;
            
        end
        
    end
end
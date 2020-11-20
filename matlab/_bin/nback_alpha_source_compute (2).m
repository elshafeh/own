clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

h                                           = waitbar(0,'Computing!...');

for nsuj = 1:length(suj_list)
    
    subjectname                             = ['sub' num2str(suj_list(nsuj))];
    
    waitbar(nsuj/length(suj_list),h,[subjectname ' ' num2str(nsuj) '/' num2str(length(suj_list))]);
    
    fname                                   = ['../data/source/volgrid/' subjectname '.volgrid.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    for nsession = 1:2
        
        fname                               = ['../data/prepro/stack/data_sess' num2str(nsession) '_s' num2str(suj_list(nsuj)) '_3stacked.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        fname                               = ['../data/source/lead/' subjectname '.session' num2str(nsession) '.leadfield.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname);
        
        % load peak
        fname                               = ['../data/peak/' subjectname '.alphabetapeak.m1000m0ms.mat'];
        fprintf('loading %s\n\n',fname);
        load(fname);
        
        com_filter                          = nbk_common_filter(data,leadfield,vol,[-1 5],apeak,2); clc;
        
        list_name                           = {'0back','1back','2back'};
        
        for nc = 1:length(list_name)
            
            cfg                             = [];
            cfg.trials                      = find(data.trialinfo(:,2) == nc+3);
            
            if ~isempty(cfg.trials)
                
                sub_data                    = ft_selectdata(cfg,data);
                
                for ntime = [-0.7 0.3:1:5]
                    
                    window_width            = 0.5;
                    [source,ext_name]       = nbk_dics_separate(sub_data,leadfield,vol,com_filter,[ntime ntime+window_width],apeak,2);
                    
                    fname_out               = ['../data/source/alpha/' subjectname '.session' num2str(nsession) '.' list_name{nc} '.' ext_name  '.dics.mat'];
                    fprintf('\nsaving %s\n',fname_out);
                    save(fname_out,'source','-v7.3'); clc;
                    
                end
            end
            
        end
    end
end

try
    close(h);
catch
    fprintf('bye bitch\n');
end
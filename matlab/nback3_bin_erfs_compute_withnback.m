clear;clc;

for nsuj = [6:33 35:36 38:44 46:51]
    
    ext_bin_name                        = 'exl500concat3bins';
    fname                               = ['D:/Dropbox/project_me/data/nback/bin/sub' num2str(nsuj) '.' ext_bin_name '.binsummary.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    bin_summary                         = struct2table(bin_summary);
    
    for nsess = 1:2
        
        
        fname                           = ['D:/Dropbox/project_me/data/nback/prepro/nback_' num2str(nsess) '/data_sess' num2str(nsess) '_s' num2str(nsuj) '.mat'];
        fprintf('loading %s\n',fname);
        load(fname);
        
        %-%-% low pass filtering
        cfg                             = [];
        cfg.demean                      = 'yes';
        cfg.baselinewindow              = [-0.1 0];
        cfg.lpfilter                    = 'yes';
        cfg.lpfreq                      = 20;
        data                            = ft_preprocessing(cfg,data);
        
        %-%-% exclude trials with a previous response + 0back
        cfg                             = [];
        cfg.trials                      = find(data.trialinfo(:,5) == 0 & data.trialinfo(:,1) ~= 4);
        data                            = ft_selectdata(cfg,data);
        
        sess_carr{nsess}                = megrepair(data);
    end
    
    data                                = ft_appenddata([],sess_carr{:}); clear sess_carr;
    
    list_name                           = {'1back','2back'};
    list_stim                           = {'first' 'target'};
    list_band                           = {'slow' 'alpha' 'beta' 'gamma1' 'gamma2'};
    
    for nband = [1 2 3 4 5]
        for nbin = [1 3]
            
            flg                         = find(strcmp(bin_summary.band,list_band{nband}) & ...
                strcmp(bin_summary.bin,['b' num2str(nbin)]));
            
            sub_summary                 = bin_summary(flg,:); clear flg;
            sub_index                   = sub_summary.index{:};
            sub_trialinfo             	= sub_summary.trialinfo{:};
            
            for nback = [1 2]
                for nstim = [1 2]
                    
                    flg_trials        	= find(sub_trialinfo(:,1) == nback+4 & sub_trialinfo(:,2) == nstim);
                    
                    cfg                 = [];
                    cfg.trials          = sub_index(flg_trials); clear flg_trials;
                    avg                 = ft_timelockanalysis(cfg, data);
                    avg_comb            = ft_combineplanar([],avg);
                    avg_comb            = rmfield(avg_comb,'cfg'); clc;
                    
                    fname_out           = ['D:/Dropbox/project_me/data/nback/erf/sub' num2str(nsuj) '.' list_name{nback}  ... 
                        '.' list_stim{nstim} '.' list_band{nband} '.' ['b' num2str(nbin)] '.erfComb.mat'];
                    
                    fprintf('Saving %s\n',fname_out);
                    tic;save(fname_out,'avg_comb','-v7.3');toc; clear avg avg_comb;
                    
                end
            end
        end
    end
end
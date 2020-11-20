clear;

suj_list                    = [1:4 8:17] ;
data_list                   = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        ext_name            = ['brain.slct.lp.' data_list{ndata}];
        
        fname_in            = ['../data/lcmv_brain/' suj '.CnD.' ext_name '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        cfg                 = [];
        cfg.demean          = 'yes';
        cfg.baselinewindow  = [-0.1 0];
        cfg.hpfilter     	= 'yes';
        cfg.hpfreq      	= 0.1;
        data                = ft_preprocessing(cfg,data);
        
        list_ix_cue         = {[1],[2],[0],[0],[0:2],[0:2],[0:2],[1 2],[0]};
        list_ix_tar         = {[1 3],[2 4],[1 3],[2 4],[1:4],[1 3],[2 4],[1:4],[1:4]};
        list_ix_name        = {'inf.left','inf.right','unf.left','unf.right','all','left','right','inf','unf'};
        
        for ncond = 1:length(list_ix_name)
            
            cfg             = [];
            cfg.trials      = h_chooseTrial(data,list_ix_cue{ncond},0,list_ix_tar{ncond});
            avg             = ft_timelockanalysis(cfg,data);
            avg             = rmfield(avg,'cfg');
            
            dir_data        = '../data/erf/';
            fname_out       = [dir_data suj '.' list_ix_name{ncond} '.' ext_name '.erf.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'avg','-v7.3'); clear avg;
            
        end
        
        clear data list_ix_*
        
    end
end
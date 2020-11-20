clear;

suj_list                    = [1:4 8:17] ;
data_list                   = {'meg','eeg'};

for nsuj = 1:length(suj_list)
    
    suj                     = ['yc' num2str(suj_list(nsuj))] ;
    
    for ndata = 1:2
        
        ext_name            = [ 'nDT.brain1vox.dwn60.' data_list{ndata}];
        
        fname_in            = ['P:/3015079.01/com/preproc/' suj '.' ext_name '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        list_unique         = h_grouplabel(data,'yes');
        data                = h_transform_data(data,list_unique(:,2),list_unique(:,1));
        
        list_ix_cue         = {[1 2],[0],[1],[2],[0:2]};
        list_ix_tar         = {[1:4],[1:4],[1:4],[1:4],[1:4]};
        list_ix_name        = {'inf','unf','left','right','all'};
        
        for ncond = 1:length(list_ix_name)
            
            cfg             = [];
            cfg.trials      = h_chooseTrial(data,list_ix_cue{ncond},0,list_ix_tar{ncond});
            avg             = ft_timelockanalysis(cfg,data);
            avg             = rmfield(avg,'cfg');
            
            dir_data        = 'P:/3015079.01/com/erf/';
            fname_out       = [dir_data suj '.' list_ix_name{ncond} '.' ext_name  '.erf.mat'];
            fprintf('Saving %s\n',fname_out);
            save(fname_out,'avg','-v7.3'); clear avg;
            
        end
        
        clear data list_ix_*
        
    end
end
clear;

suj_list                                                = [1:4 8:17] ;

for ns = 2:length(suj_list)
    
    suj                                                 = ['yc' num2str(suj_list(ns))];
    
    window_cov                                          = [-1 2];
    window_slct                                         = [-3 3];
    list_index                                          = 'brain1vox';
    list_exten                                       	= 'brain1vox.dwn60';
    
    % - % EEG % - %
    
    time_pre    = 2; time_post   = 2; lock        = 3;
    data_elan                                           = com_fun_eeg2field_cue(suj,time_pre,time_post,lock);
    data_elan                                           = rmfield(data_elan,'grad');
    data_elan                                           = rmfield(data_elan,'hdr');
    
    cfg                                                 = [];
    cfg.resamplefs                                      = 60;
    cfg.detrend                                         = 'no';cfg.demean = 'no';
    data                                                = ft_resampledata(cfg, data_elan); clear data_elan;
    
    cfg                                                 = [];
    cfg.precision                                       = 'single';
    data                                                = ft_preprocessing(cfg,data);
    
    fname_in                                            = ['K:/eegvol/' suj '.eegVolElecLead.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    [data_select,avg]                                   = h_ramaPreprocess(data,window_cov,window_slct);
    
    avg.elec                                            = elec;
    vol.elec                                            = elec;
    spatialfilter                                       = h_ramaComputeFilter(avg,leadfield,vol);
    
    [roi_list,vox_order,arsenal_list]                   = h_ramaPrepareIndex(['../data/index/' list_index '.mat'],'../data/stock/template_grid_0.5cm.mat');
    data                                                = h_ramaComputeVirtsens(data_select,spatialfilter,roi_list,arsenal_list,vox_order); clear data_select;
    data                                                = rmfield(data,'cfg');
    
    fname_out                                           = ['P:/3015079.01/com/preproc/' suj '.nDT.' list_exten '.eeg.mat'];
    fprintf('\n\nSaving %50s \n\n',fname_out);
    save(fname_out,'data','-v7.3'); clear data prt_virtsens fname_out;
    
    % - % MEG % - %
    
    fname_in                                            = ['J:/temp/meeg/data/headfield/' suj '.VolGrid.5mm.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    for np = 1:3
        
        fname_in                                        = ['F:/Fieldtripping/data/all_data/' suj '.pt' num2str(np) '.nDT.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        cfg                                             = [];
        cfg.resamplefs                                  = 60;
        cfg.detrend                                     = 'no';cfg.demean = 'no';
        data                                            = ft_resampledata(cfg, data_elan); clear data_elan;
        
        cfg                                             = [];
        cfg.precision                                   = 'single';
        data                                            = ft_preprocessing(cfg,data);
        
        fname_in                                        = ['J:/temp/meeg/data/headfield/' suj '.pt' num2str(np) '.adjusted.leadfield.5mm.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        [data_select,avg]                               = h_ramaPreprocess(data,window_cov,window_slct); clear data;
        spatialfilter                                   = h_ramaComputeFilter(avg,leadfield,vol);
        
        
        [roi_list,vox_order,arsenal_list]               = h_ramaPrepareIndex(['../data/index/' list_index '.mat'],'../data/stock/template_grid_0.5cm.mat');
        prt_virtsens{np}                                = h_ramaComputeVirtsens(data_select,spatialfilter,roi_list,arsenal_list,vox_order); clear data_select;
        
    end
    
    keep suj suj_list ns prt_virtsens list_exten window_* list_*
    
    data                                                = ft_appenddata([],prt_virtsens{:});
    data                                                = rmfield(data,'cfg');
    fname_out                                           = ['P:/3015079.01/com/preproc/' suj '.nDT.' list_exten '.meg.mat'];
    fprintf('\n\nSaving %50s \n\n',fname_out);
    save(fname_out,'data','-v7.3'); clear data prt_virtsens fname_out;
    
    
end
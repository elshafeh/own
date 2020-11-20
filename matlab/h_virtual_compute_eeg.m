function h_virtual_compute_eeg(suj)

cond_main                                           = 'CnD';

fname_in                                            = ['J:/temp/meeg/data/eegvol/' suj '.eegVolElecLead.mat'];
fprintf('\nLoading %50s\n',fname_in);
load(fname_in);

list_filters                                        = [NaN NaN];
window_cov                                          = [-1 2];
window_slct                                         = [-3 3];

for np = 1
    
    fname_in                                        = ['J:/temp/meeg/data/preproc/orig_dwn/' suj '.CnD.eeg.sngl.dwn100.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    % -
    %     cfg                                             = [];
    %     cfg.lpfilter                                    = 'yes';
    %     cfg.lpfreq                                      = 30;
    %     data                                            = ft_preprocessing(cfg,data);
    % -
    
    % -
    cfg                                           	= [];
    cfg.resamplefs                                  = 60;
    cfg.detrend                                     = 'no';
    cfg.demean                                      = 'no';
    data                                            = ft_resampledata(cfg, data);
    % -
    
    data                                            = rmfield(data,'cfg');
    data                                            = rmfield(data,'hdr');
    data                                            = rmfield(data,'grad');
    data                                            = rmfield(data,'elec');
    
    %     elec.label                                      = elec.label(1:54);
    %     elec.elecpos                                    = elec.elecpos(1:54,:);
    %     elec.chanpos                                    = elec.chanpos(1:54,:);
    
    vol.elec                                        = elec;
    data.elec                                       = elec;
    
    for nfilt = 1:size(list_filters,1)
        
        [ext_essai{nfilt},dataica_sep,avg]       	= h_ramaPreprocess(data,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);
        
        dir_data_out                                = 'J:/temp/meeg/data/voxbrain/';
        
        spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);
        
        list_index                                  = {'brain1vox'};
        list_exten                                  = {'brain1vox.dwn60'};
        
        for nindex = 1:length(list_index)
            
            prt_virtsens{nindex,np,nfilt}           = nk_virt_compute(dataica_sep,['../data/' list_index{nindex} '.mat'],spatialfilter);
            
        end
    end
end

clc;

for nindex = 1:length(list_index)
    for nfilt = 1:size(list_filters,1)
        
        name_parts                                  = strsplit(ext_essai{nfilt},'.');
        data                                        = ft_appenddata([],prt_virtsens{nindex,:,nfilt});
        
        fname_out                                   = [dir_data_out suj '.' cond_main '.' list_exten{nindex} '.eeg.mat'];
        fprintf('\n\nSaving %50s \n\n',fname_out);
        
        data                                        = rmfield(data,'cfg');
        
        save(fname_out,'data','-v7.3')
        clc;
        
    end
end
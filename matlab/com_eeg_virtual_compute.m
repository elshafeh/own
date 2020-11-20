clear;

suj_list                                                = [1:4 8:17] ;

for ns = 1:length(suj_list)

    suj                                                 = ['yc' num2str(suj_list(ns))] ;
    cond_main                                           = 'CnD';

    fname_in                                            = ['~/GoogleDrive/eegvol/' suj '.eegVolElecLead.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);

    list_filters                                        = [NaN NaN];
    window_cov                                          = [-1 2];
    window_slct                                         = [-3 3];

    for np = 1

        fname_in                                        = ['/Volumes/heshamshung/alpha_compare/preproc_data/orig_dwn/' suj '.CnD.eeg.sngl.dwn100.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        cfg                                             = [];
        cfg.bpfilter                                    = 'yes';
        cfg.bpfreq                                      = [1 20];
        data                                            = ft_preprocessing(cfg,data);

        data                                            = rmfield(data,'cfg');
        data                                            = rmfield(data,'hdr');
        data                                            = rmfield(data,'grad');

        for nfilt = 1:size(list_filters,1)

            [ext_essai{nfilt},~,avg]                    = h_ramaPreprocess(data,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);

            dir_data_out                                = '../data/lcmv_brain/';

            vol.elec                                    = elec;
            spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);

            [~,dataica_sep,~]                           = h_ramaPreprocess(data,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);

            list_index                                  = {'com_btomeroi_select'};
            list_exten                                  = {'brain.slct.bp'};

            for nindex = 1:length(list_index)

                [roi_list,vox_order,arsenal_list]       = h_ramaPrepareIndex(['../data/template/' list_index{nindex} '.mat'],'../data/template/template_grid_5mm.mat');
                prt_virtsens{nindex,np,nfilt}           = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);

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
end

function h_create_virtual_in_function(suj,data_elan,data_sep,vol,leadfield,list_cnd)

list_filters                                    = [1 20; 50 120];
window_cov                                      = [-0.2 0.8];
window_slct                                     = [-3 3];

for nfilt = 1:size(list_filters,1)
    
    [ext_essai,~,avg]                           = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,[list_cnd{:}]);
    spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);
    
    fname_out                                   = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' ext_essai '.mat'];
    fprintf('\n\nSaving %50s \n\n',fname_out);
    save(fname_out,'spatialfilter','-v7.3')
    
    for xi = 1:length(list_cnd)
        
        [~,dataica_sep,~]                       = h_ramaPreprocess(data_sep{xi},list_filters(nfilt,:),window_cov,window_slct,suj,[list_cnd{:}]);
        
        for index_name = {'broadAudMNIFront'}
            
            [roi_list,vox_order,arsenal_list]   = h_ramaPrepareIndex(['../data/index/' index_name{:} '.mat']);
            
            ext_virt                            = index_name{:};
            
            virtsens                            = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);
            
            name_parts                          = strsplit(ext_essai,'.');
            
            fname_out                           = [suj '.' list_cnd{xi} '.' ext_virt '.' name_parts{4} '.' name_parts{5} 'Cov'];
            
            fprintf('\n\nSaving %50s \n\n',fname_out);
            save(['/Volumes/hesham_megabup/pat22_fieldtrip_data/' fname_out '.mat'],'virtsens','-v7.3')
            
            list_ix_name                        = {'','N','L','R','V','1','N1','L1','R1','V1'};
            list_ix_cue                         = {0:2,0,1,2,1:2,0:2,0,1,2,1:2};
            list_ix_dis                         = {1:2,1:2,1:2,1:2,1:2,1,1,1,1,1};
            list_ix_tar                         = {1:4,1:4,1:4,1:4,1:4,1:4,1:4,1:4,1:4,1:4};
            
            for ncue = 1:length(list_ix_name)
                
                cfg                             = [];
                cfg.trials                      = h_chooseTrial(virtsens,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
                sub_virtsens                    = ft_selectdata(cfg,virtsens);
                
                fname_out                       = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' list_ix_name{ncue} list_cnd{xi} '.' ext_virt '.' name_parts{4} '.' name_parts{5} 'Cov'];
                
                if length(list_ix_cue{ncue}) == 3
                    in_function_computeTFR(sub_virtsens,fname_out,'wavelet','pow','yes',7,4,-3:0.01:3,list_filters(nfilt,1):1:list_filters(nfilt,2)-1,'yes');
                else
                    in_function_computeTFR(sub_virtsens,fname_out,'wavelet','pow','no',7,4,-3:0.01:3,list_filters(nfilt,1):1:list_filters(nfilt,2)-1,'yes');
                end
                
                clear sub_virtsens fname_out
                
            end
            
            clear virtsens name_parts fname_out
            
        end
        
        clear dataica_sep
        
    end
    
    clear roi_list vox_order arsenal_list spatialfilter ext_essai
    
end
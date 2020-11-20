clear; clc;

addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

suj_list                                                = [1:4 8:17] ;

for sb = 1:length(suj_list)
    
    suj                                                 = ['yc' num2str(suj_list(sb))] ;
    cond_main                                           = 'CnD';
    
    fname_in                                            = ['/Volumes/Pat22Backup/meg21_fieldtrip_data_backup/data/all_data/' suj '.VolGrid.0.5cm.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    list_filters                                        = [1 120];
    window_cov                                          = [-0.8 2];
    window_slct                                         = [-1 3];
    
    for prt = 1:3
        
        fname_in                                        = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) '.' cond_main '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        fname_in                                        = ['/Volumes/PAT_MEG2/Fieldtripping/data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        for nfilt = 1:size(list_filters,1)
            
            [ext_essai{nfilt},~,avg]                    = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);
            
            dir_data_out                                = ['../data/sfn_data/' suj '/'];
            
            fname                                       = [dir_data_out ext_essai{nfilt} '.pt' num2str(prt) '.mat'];
            spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);
            fprintf('\n\nSaving %50s \n\n',fname);
            
            [~,dataica_sep,~]                           = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);
            
            list_index                                  = {'MniAtlas90roi'};
            list_exten                                  = {'prep21.Mni90'};
            
            for nindex = 1:length(list_index)
                
                [roi_list,vox_order,arsenal_list]       = h_ramaPrepareIndex(['../data/index/' list_index{nindex} '.mat'],'../data/template/template_grid_0.5cm.mat');
                prt_virtsens{nindex,prt,nfilt}          = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);
                
            end
        end
    end
    
    clc;
    
    for nindex = 1:length(list_index)
        for nfilt = 1:size(list_filters,1)
            
            name_parts      = strsplit(ext_essai{nfilt},'.');
            virtsens        = ft_appenddata([],prt_virtsens{nindex,:,nfilt});
            
            fname_out       = [dir_data_out suj '.' cond_main '.' list_exten{nindex} '.' name_parts{4} '.' name_parts{5} 'Cov.mat'];
            
            fprintf('\n\nSaving %50s \n\n',fname_out);
            
            clc;
            
            cfg             = [];
            cfg.trials      = h_chooseTrial(virtsens,1:2,0,1:4);
            virtsens        = ft_selectdata(cfg,virtsens);
            
            dir_out         = ['../data/sfn_data/' suj '/'];
            py_name_out     = [dir_out  suj '.CnD.' list_exten{nindex} '.1t120Hz.m800p2000msCov'];
            h_field2py_decode(virtsens,py_name_out); clear virtsens;
            
        end
    end
end
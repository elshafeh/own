clear;

h_start('/Users/heshamelshafei/Dropbox/ade_training/fieldtrip-20190127/');

suj_list                                                = [1:4 8:17] ;

for sb = 2:length(suj_list)
    
    suj                                                 = ['yc' num2str(suj_list(sb))] ;
    cond_main                                           = 'CnD';
    
    fname_in                                            = ['/Volumes/PAT_MEG2/Fieldtripping/data/headfield/' suj '.VolGrid.5mm.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    list_filters                                        = [1 20];
    window_cov                                          = [-0.8 2];
    window_slct                                         = [-3 3];
    
    for prt = 1:3
        
        fname_in                                        = ['/Volumes/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) '.' cond_main '.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        fname_in                                        = ['/Volumes/PAT_MEG2/Fieldtripping/data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat'];
        fprintf('\nLoading %50s\n',fname_in);
        load(fname_in);
        
        for nfilt = 1:size(list_filters,1)
            
            [ext_essai{nfilt},~,avg]                    = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);
            
            dir_data_out                                = '../data/conn/';
            
            fname                                       = [dir_data_out ext_essai{nfilt} '.pt' num2str(prt) '.mat'];
            spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);
            fprintf('\n\nSaving %50s \n\n',fname);
            
            [~,dataica_sep,~]                           = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);
            
            list_index                                  = {'eNeuroPaper_AudVis_Index_plus_TDSchaef'};
            list_exten                                  = {'PaperAudVisTD'};
            
            for nindex = 1:length(list_index)
                [roi_list,vox_order,arsenal_list]       = h_ramaPrepareIndex(['../data/' list_index{nindex} '.mat'],'../data/template_grid_0.5cm.mat');
                prt_virtsens{nindex,prt,nfilt}          = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);
                
            end
        end
    end
    
    clc;
    
    for nindex = 1:length(list_index)
        for nfilt = 1:size(list_filters,1)
            
            name_parts                                  = strsplit(ext_essai{nfilt},'.');
            virtsens                                    = ft_appenddata([],prt_virtsens{nindex,:,nfilt});
            
            fname_out                                   = [dir_data_out suj '.' cond_main '.' list_exten{nindex} '.' name_parts{4} '.' name_parts{5} 'Cov.mat'];
            
            fprintf('\n\nSaving %50s \n\n',fname_out);
            
            save(fname_out,'virtsens','-v7.3')
            
            clc;
            
        end
    end
end
clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); clc ;

suj_list                                            = [1:4 8:17];

for sb = 1:length(suj_list)
    
    suj                                             = ['yc' num2str(suj_list(sb))] ;
    cond_main                                       = 'CnD';
    
    fname_in                                        = ['../../PAT_MEG21/pat.field/data/' suj '.VolGrid.0.5cm.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    list_filters                                    = [1 20; 10 50; 50 120];
    window_cov                                      = [-0.8 2];
    window_slct                                     = [-3 3];
    
    for nfilt = 1:size(list_filters,1)
        
        for prt = 1:3
            
            fname_in                                = ['/media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/all_data/' suj '.pt' num2str(prt) '.' cond_main '.mat'];
            fprintf('\nLoading %50s\n',fname_in);
            load(fname_in);
            
            fname_in                                = ['/media/hesham.elshafei/PAT_MEG2/Fieldtripping/data/headfield/' suj '.pt' num2str(prt) '.adjusted.leadfield.5mm.mat'];
            fprintf('\nLoading %50s\n',fname_in);
            load(fname_in);
            
            [ext_essai,~,avg]                       = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);
            
            dir_data_out                            = '../../PAT_MEG21/pat.field/data/';
            
            fname                                   = [dir_data_out ext_essai '.pt' num2str(prt) '.mat'];
            
            spatialfilter                           = h_ramaComputeFilter(avg,leadfield,vol);
            
            fprintf('\n\nSaving %50s \n\n',fname);
            
            save(fname,'spatialfilter','-v7.3')
                        
            [~,dataica_sep,~]                       = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);
            
            list_index                              = {'TD_BU_index','paper_index_aud_occ_averaged','prep21_TDBU_5vox'};
            list_exten                              = {'prep21.TDBU','prep21.AV','prep21.maxTDBU'};
            
            for nindex = 1:length(list_index)
                
                [roi_list,vox_order,arsenal_list]   = h_ramaPrepareIndex(['../data_fieldtrip/index/' list_index{nindex} '.mat']);
                
                prt_virtsens{nindex,prt}            = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);
                
            end
            
        end
        
        clc; 
        
        for nindex = 1:length(list_index)
            
            name_parts                                  = strsplit(ext_essai,'.');
            
            virtsens                                    = ft_appenddata([],prt_virtsens{nindex,:});
            
            fname_out                                   = [dir_data_out suj '.' cond_main '.' list_exten{nindex} '.' name_parts{4} '.' name_parts{5} 'Cov.mat'];
            
            fprintf('\n\nSaving %50s \n\n',fname_out);
            
            save(fname_out,'virtsens','-v7.3')
            
            clc; 
            
            cond_ix_sub                                 = {'N','L','R',''}; %
            cond_ix_cue                                 = {0,1,2,0:2}; %
            cond_ix_dis                                 = {0,0,0,0}; %
            cond_ix_tar                                 = {1:4,1:4,1:4,1:4}; %
            
            for ncue = 1:length(cond_ix_sub)
                
                cfg                                     = [];
                
                cfg.trials                              = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
                
                sub_virtsens                            = ft_selectdata(cfg,virtsens);
                
                sub_virtsens                            = h_removeEvoked(sub_virtsens);
                
                fname_out                               = [dir_data_out suj '.' cond_ix_sub{ncue} cond_main '.' list_exten{nindex} '.' name_parts{4} '.' name_parts{5} 'Cov'];
                
                freq                                    = in_function_computeTFR(sub_virtsens,fname_out,'wavelet','pow','no',7,4,-3:0.01:3,list_filters(nfilt,1):1:list_filters(nfilt,2)-1,'MinEvoked');
                
            end
        end
    end
end
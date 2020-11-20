
clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/')); clc ;

suj_list                                                = [1:4 8:17] ;

for sb = 1:length(suj_list)
    
    suj                                                 = ['yc' num2str(suj_list(sb))] ;
    cond_main                                           = 'CnD';
    
    fname_in                                            = ['/Volumes/Pat22Backup/meg21_fieldtrip_data_backup/data/all_data/' suj '.VolGrid.0.5cm.mat'];
    fprintf('\nLoading %50s\n',fname_in);
    load(fname_in);
    
    list_filters                                        = [1 20; 50 120];
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
            
            dir_data_out                                = '../data/paper_data/';
            
            fname                                       = [dir_data_out ext_essai{nfilt} '.pt' num2str(prt) '.mat'];
            spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);
            fprintf('\n\nSaving %50s \n\n',fname);
            
            %             save(fname,'spatialfilter','-v7.3')
            %             load(['/Volumes/Pat22Backup/meg21_fieldtrip_data_backup/data/all_data/' suj '.pt' num2str(prt) '.CnD.Covariance.50t140Hz.m800p200ms.CF4V.mat'])
            
            [~,dataica_sep,~]                           = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,cond_main);
            
            list_index                                  = {'prep21_maxAudVisMotor'};
            list_exten                                  = {'prep21.maxAVMsepVoxel5per'};
            
            for nindex = 1:length(list_index)
                [roi_list,vox_order,arsenal_list]       = h_ramaPrepareIndex(['../data/index/' list_index{nindex} '.mat']);
                prt_virtsens{nindex,prt,nfilt}          = h_ramaComputeVirtsensSepVoxels(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);
                
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
            
            %             cond_ix_sub                                 = {'N','L','R',''}; %
            %             cond_ix_cue                                 = {0,1,2,0:2}; %
            %             cond_ix_dis                                 = {0,0,0,0}; %
            %             cond_ix_tar                                 = {1:4,1:4,1:4,1:4}; %
            %
            %             for ncue = 1:length(cond_ix_sub)
            %                 cfg                                     = [];
            %                 cfg.trials                              = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
            %                 sub_virtsens                            = ft_selectdata(cfg,virtsens);
            %                 sub_virtsens                            = h_removeEvoked(sub_virtsens);
            %                 fname_out                               = [dir_data_out suj '.' cond_ix_sub{ncue} cond_main '.' list_exten{nindex} '.' name_parts{4} '.' name_parts{5} 'Cov'];
            %                 freq                                    = in_function_computeTFR(sub_virtsens,fname_out,'wavelet','pow','no',7,4,-3:0.05:3,list_filters(nfilt,1):1:list_filters(nfilt,2)-1,'MinEvoked');
            %             end
            
        end
    end
end
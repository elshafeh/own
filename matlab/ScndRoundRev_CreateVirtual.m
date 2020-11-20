clear ; clc ;
addpath('/Users/heshamelshafei/fieldtrip/'); ft_defaults;

global ft_default
ft_default.spmversion = 'spm12';

[~,suj_list,~]              = xlsread('../../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

for sb = 1:21
    
    suj                                         = suj_list{sb};
    
    fprintf('Loading leadfield and headmodel for %s\n',suj);
    
    load(['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.VolGrid.0.5cm.mat']);
    load(['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.adjusted.leadfield.0.5cm.mat']);
    
    list_cnd                                    = {'DIS','fDIS'};
    
    for cnd_cue = 1:length(list_cnd)
        
        fname                                   = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' list_cnd{cnd_cue} '.mat'];
        
        fprintf('\nLoading %20s\n',fname);
        
        load(fname);
        
        cfg                                     = [];
        cfg.latency                             = [-2 2];
        data_elan                               = ft_selectdata(cfg,data_elan);
        data_sep{cnd_cue}                       = data_elan ; clear data_elan fname;
        
    end
    
    if length(data_sep) > 1
        data_elan = ft_appenddata([],data_sep{:}) ;
    else
        data_elan = data_sep{1};
    end
    
    clear cnd_cue
    
    list_filters                                    = [40 120];
    window_cov                                      = [-0.2 0.8];
    window_slct                                     = [-2 2];
    
    for nfilt = 1:size(list_filters,1)
        
        [ext_essai,~,avg]                           = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,[list_cnd{:}]);
        spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);
        
        for xi = 1:length(list_cnd)
            
            [~,dataica_sep,~]                       = h_ramaPreprocess(data_sep{xi},list_filters(nfilt,:),window_cov,window_slct,suj,[list_cnd{:}]);
            
            for index_name = {'AudTPFCAveraged'}
                
                [roi_list,vox_order,arsenal_list]   = h_ramaPrepareIndex(['../../data/index/' index_name{:} '.mat'],'../../data/template/template_grid_0.5cm.mat');
                
                ext_virt                            = index_name{:};
                
                virtsens                            = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);
                
                name_parts                          = strsplit(ext_essai,'.');
                
                fname_out                           = [suj '.' list_cnd{xi} '.' ext_virt '.' name_parts{4} '.' name_parts{5} 'Cov'];
                
                fprintf('\n\nSaving %50s \n\n',fname_out);
                
                dir_out                             = '../../data/scnd_round/';
                
                save([dir_out fname_out '.mat'],'virtsens','-v7.3')
                
            end
        end
        
        clear roi_list vox_order arsenal_list spatialfilter ext_essai
        
    end
    
    clearvars -except sb *suj_list
    
end
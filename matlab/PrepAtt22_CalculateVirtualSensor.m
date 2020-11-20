clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,suj_list,~]              = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','A:B');
suj_list                    = suj_list(2:22,2);

for sb = 1:21
    
    suj                                         = suj_list{sb};
    
    fprintf('Loading leadfield and headmodel for %s\n',suj);
    
    load(['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.VolGrid.0.5cm.mat']);
    load(['/Volumes/heshamshung/new_leadfield/' suj '.adjusted.leadfield.2cm.mat']);
    
    list_cnd                                    = {'nDT'};
    
    for cnd_cue = 1:length(list_cnd)
        
        fname                                   = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/' suj '.' list_cnd{cnd_cue} '.mat'];
        
        fprintf('\nLoading %20s\n',fname);
        
        load(fname);
        
        cfg                                     = [];
        cfg.latency                             = [-3 3];
        data_elan                               = ft_selectdata(cfg,data_elan);
        data_sep{cnd_cue}                       = data_elan ; clear data_elan fname;
        
    end
    
    if length(data_sep) > 1
        data_elan = ft_appenddata([],data_sep{:}) ;
    else
        data_elan = data_sep{1};
    end
    
    clear cnd_cue
    
    list_filters                                    = [0.5 110];
    window_cov                                      = [-0.4 0.8];
    window_slct                                     = [-3 3];
    
    for nfilt = 1:size(list_filters,1)
        
        [ext_essai,~,avg]                           = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,[list_cnd{:}]);
        spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);
        
        for xi = 1:length(list_cnd)
            
            [~,dataica_sep,~]                       = h_ramaPreprocess(data_sep{xi},list_filters(nfilt,:),window_cov,window_slct,suj,[list_cnd{:}]);
            
            for index_name = {'mni2cmWhole'}
                
                [roi_list,vox_order,arsenal_list]   = h_ramaPrepareIndex(['../data/index/' index_name{:} '.mat'],'../data/template/template_grid_2cm.mat');
                
                ext_virt                            = index_name{:};
                
                virtsens                            = h_ramaComputeVirtsensSepVoxels(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);
                
                name_parts                          = strsplit(ext_essai,'.');
                
                fname_out                           = [suj '.' list_cnd{xi} '.' ext_virt '.' name_parts{4} '.' name_parts{5} 'Cov'];
                
                fprintf('\n\nSaving %50s \n\n',fname_out);
                
                dir_out                             = '/Volumes/hesham_megabup/decoding_data/';
                h_fieldtrip2MNI(virtsens,sb,dir_out,ext_virt)
                
            end
        end
        
        clear roi_list vox_order arsenal_list spatialfilter ext_essai
        
    end
    
    clearvars -except sb *suj_list
    
end

%                 save([dir_data fname_out '.mat'],'virtsens','-v7.3')

%                 list_ix_name                        = {'','N','L','R','NL','NR'};
%                 list_ix_cue                         = {0:2,0,1,2,0,0};
%                 list_ix_dis                         = {0,0,0,0,0,0};
%                 list_ix_tar                         = {1:4,1:4,1:4,1:4,[1 3],[2 4]};
%
%                 for ncue = 1:length(list_ix_name)
%
%                     cfg                             = [];
%                     cfg.trials                      = h_chooseTrial(virtsens,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
%                     sub_virtsens                    = ft_selectdata(cfg,virtsens);
%
%                     fname_out                       = ['/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.' list_ix_name{ncue} list_cnd{xi} '.' ext_virt '.' name_parts{4} '.' name_parts{5} 'Cov'];
%
%                     in_function_computeTFR_special(sub_virtsens,fname_out,'wavelet','pow','no',7,4,-3:0.05:3,list_filters(nfilt,1):1:list_filters(nfilt,2)-1,'yes');
%                 end

% clear virtsens name_parts fname_out
clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

suj_group{2}    = {'uc5' 'yc17' 'yc18' 'uc6' 'uc7' 'uc8' 'yc19' 'uc9' ...
  'uc10' 'yc6' 'yc5' 'yc9' 'yc20' 'yc21' 'yc12' 'uc1' 'uc4' 'yc16' 'yc4'};
suj_group{3}    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
  'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{4}    = allsuj(2:15,1);
suj_group{5}    = allsuj(2:15,2);

suj_list        = [suj_group{1};suj_group{2}';suj_group{3}';suj_group{4};suj_group{5}];
suj_list        = unique(suj_list);

for sb = 1:length(suj_list)
    
    suj     = suj_list{sb};
    
    load(['../data/' suj '/field/' suj '.VolGrid.0.5cm.mat']);
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.0.5cm.mat']);
    
    list_cnd = {'CnD'};
    
    for cnd_cue = 1:length(list_cnd)
        fname = ['../data/' suj '/field/' suj '.' list_cnd{cnd_cue} '.mat'];
        fprintf('\nLoading %20s\n',fname);
        load(fname);
        data_sep{cnd_cue} = data_elan ; clear data_elan fname;
    end
    
    if length(data_sep) > 1
        data_elan = ft_appenddata([],data_sep{:}) ;
    else
        data_elan = data_sep{1};
    end
    
    clear cnd_cue
    
    list_filters                            = [50 120];
    window_cov                              = [-0.8 2];
    window_slct                             = [-3 3];
    
    for nfilt = 1:size(list_filters,1)
        
        [ext_essai,~,avg]                   = h_ramaPreprocess(data_elan,list_filters(nfilt,:),window_cov,window_slct,suj,[list_cnd{:}]);
        
        fname                               = ['../data/' suj '/field/' ext_essai '.mat'];
        
        if exist(fname)
            
            fprintf('\nFilter exists Loading %50s \n\n',fname);
            load(fname)
            
        else
            
            spatialfilter                  = h_ramaComputeFilter(avg,leadfield,vol);
            
            fprintf('\n\nSaving %50s \n\n',ext_essai);
            save(['../data/' suj '/field/' ext_essai '.mat'],'spatialfilter','-v7.3')
            
        end
        
        [roi_list,vox_order,arsenal_list]   = h_ramaPrepareIndex('../data_fieldtrip/index/broadman_based_audiovisual_index.mat');
        
        for xi = 1:length(list_cnd)
            
            ext_virt                        = 'broadAreas';
            
            [~,dataica_sep,~]               = h_ramaPreprocess(data_sep{xi},list_filters(nfilt,:),window_cov,window_slct,suj,[list_cnd{:}]);
            
            virtsens                        = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order); clear dataica_sep ;
            
            name_parts                      = strsplit(ext_essai,'.');
            
            fname_out                       = [suj '.' list_cnd{xi} '.' ext_virt '.' name_parts{4} '.' name_parts{5} 'Cov'];
            
            fprintf('\n\nSaving %50s \n\n',fname_out);
            
            save(['../data/' suj '/field/' fname_out '.mat'],'virtsens','-v7.3')
            
            %             list_ix_cue                     = {0:2};
            %             list_ix_tar                     = {1:4};
            %             list_ix_dis                     = {0};
            %             list_ix_name                    = {''};
            %
            %             for ncue = 1:length(list_ix_name)
            %
            %                 cfg                             = [];
            %                 cfg.trials                      = h_chooseTrial(virtsens,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
            %                 sub_virtsens                    = ft_selectdata(cfg,virtsens);
            %
            %                 fname_out                       = [suj '.' list_ix_name{ncue} list_cnd{xi} '.' ext_virt '.' name_parts{4} '.' name_parts{5} 'Cov'];
            %
            %                 in_function_computeTFR(sub_virtsens,suj,fname_out,'wavelet','pow','yes',7,4,-3:0.01:3,list_filters(nfilt,1):1:list_filters(nfilt,2)-1,'')
            %
            %             end
            
            clear virtsens name_parts dataica_sep fname_out dataica avg
            
        end
        
        clear roi_list vox_order arsenal_list spatialfilter ext_essai
        
    end
    
    clearvars -except sb *suj_list
    
end
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:22);

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_list        = allsuj(2:15,1);

clearvars -except suj_list

big_list_cnd = {{'DIS','fDIS'}}; % {'CnD'},{'nDT'}}; % 

for nb = 1:length(big_list_cnd)
    for sb = 5:length(suj_list)
        
        suj         = suj_list{sb};
        
        fprintf('Loading leadfield and headmodel for %s\n',suj);
        
        dir_data    = '/Volumes/hesham_megabup/pat22_fieldtrip_data/';
        
        load([dir_data suj '.VolGrid.0.5cm.mat']);
        load([dir_data suj '.adjusted.leadfield.0.5cm.mat']);
        
        list_cnd = big_list_cnd{nb};
        
        for cnd_cue = 1:length(list_cnd)
            
            fname = [dir_data suj '.' list_cnd{cnd_cue} '.mat'];
            
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
        
        if strcmp(list_cnd{1},'CnD');
            
            window_cov                              = [-0.2 2];
            
        elseif strcmp(list_cnd{1},'nDT');
            
            window_cov                              = [-0.2 0.7];
            
        elseif strcmp(list_cnd{1},'DIS');
            
            window_cov                              = [-0.2 0.7];
            h_wbc_in_func(suj,list_cnd,data_elan,data_sep,leadfield,vol,grid)
            
        end
        
        %         window_slct                                 = [-2 2];
        %
        %         [ext_essai,~,avg]                           = h_ramaPreprocess_pe(data_elan,window_cov,window_slct,suj,[list_cnd{:}]);
        %         spatialfilter                               = h_ramaComputeFilter(avg,leadfield,vol);
        %
        %         fprintf('\n\nSaving %50s \n\n',ext_essai);
        %
        %         for xi = 1:length(list_cnd)
        %
        %             [~,dataica_sep,~]                       = h_ramaPreprocess_pe(data_sep{xi},window_cov,window_slct,suj,[list_cnd{:}]);
        %
        %             for index_name = {'MNIplusAudBroadman'}
        %
        %                 [roi_list,vox_order,arsenal_list]   = h_ramaPrepareIndex(['../data/index/' index_name{:} '.mat']);
        %
        %                 ext_virt                            = index_name{:};
        %
        %                 virtsens                            = h_ramaComputeVirtsens(dataica_sep,spatialfilter,roi_list,arsenal_list,vox_order);
        %
        %                 name_parts                          = strsplit(ext_essai,'.');
        %
        %                 fname_out                           = [suj '.' list_cnd{xi} '.' ext_virt '.' name_parts{4} '.' name_parts{5} 'Cov'];
        %
        %                 fprintf('\n\nSaving %50s \n\n',fname_out);
        %
        %                 save([dir_data fname_out '.mat'],'virtsens','-v7.3')
        %
        %                 clear virtsens name_parts fname_out
        %
        %             end
        %         end
        
        clearvars -except sb *suj_list big_list_cnd nb
        
    end
end
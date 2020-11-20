clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:22);

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_list        = allsuj(2:15,1);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    if ~strcmp(suj(1:2),'fp') % avoid patients :)
        
        load(['../data/' suj '/field/' suj '.adjusted.leadfield.0.5cm.mat']); % load leadfield / head model 
        load(['../data/' suj '/field/' suj '.VolGrid.0.5cm.mat']); % load leadfield / head model
        
        pkg.leadfield   = leadfield;
        pkg.vol         = vol;
        
        clear vol leadfield
        
        list_cond_main      = {'DIS','fDIS'};
        list_filter_name    = {'largeWindowFilter','concWindowFilter'};
        
        for n_ext       = 1:length(list_cond_main)
            
            fname_in        = ['../data/' suj '/field/' suj '.' list_cond_main{n_ext} '.mat'];
            
            fprintf('Loading %s\n',fname_in);
            load(fname_in)
            
            cfg                             = [];
            cfg.latency                     = [-2 2];
            data_elan                       = ft_selectdata(cfg,data_elan);
            
            cfg                             =[];
            
            if strcmp(list_cond_main{n_ext},'CnD')
                cfg.lpfilter                = 'yes';
                cfg.lpfreq                  = 20;
            else
                cfg.bpfilter                = 'yes';
                cfg.bpfreq                  = [0.5 20];
            end
            
            data_elan                       = ft_preprocessing(cfg,data_elan);  % filter data !
            
            data_carrier{n_ext}             = data_elan ; clear data_elan avg;
            
        end
        
        % concatenate if needed
        
        if length(data_carrier) > 1
            data_elan = ft_appenddata([],data_carrier{:});
        else
            data_elan = data_carrier{1};
        end
        
        % create common filter :
        
        pkg.time_of_interest                = [0.08 0.21 0.29 0.39];
        pkg.time_window                     = [0.07 0.08 0.08 0.08];
        pkg.covariance_window               = [0 0.5];
        pkg.lambda                          = '5%';
        
        pkg.suj                             = suj;
        pkg.cond_main                       = list_cond_main{n_ext};
        
        spatial_filter{1}                   = h_create_lcmv_commonFilter_largeWindow(data_elan,pkg);
        %         spatial_filter{2}                   = h_create_lcmv_commonFilter_concWindow(data_elan,pkg);

        pkg.cond_ix_sub                     = {'','V','N','1','V1','N1'};
        
        pkg.cond_ix_cue                     = {0:2,[1 2],0,0:2,[1 2],0};
        pkg.cond_ix_dis                     = {1:2,1:2,1:2,1,1,1};
        pkg.cond_ix_tar                     = {1:4,1:4,1:4,1:4,1:4,1:4};
        
        for nfilt = 1:length(spatial_filter)
            
            pkg.spatialfilter       = spatial_filter{nfilt};            
            
            for ndata = 1:length(data_carrier)
                for ncue = 1:length(pkg.cond_ix_sub)
                    
                    trial_choose                        = h_chooseTrial(data_carrier{ndata},pkg.cond_ix_cue{ncue},pkg.cond_ix_dis{ncue},pkg.cond_ix_tar{ncue});
                    
                    cfg                                 = [];
                    cfg.trials                          = trial_choose;
                    data_slct                           = ft_selectdata(cfg,data_carrier{ndata});
                    
                    pkg.ext_name                        = ['../data/' suj '/field/' suj '.' pkg.cond_ix_sub{ncue} list_cond_main{n_ext} '.' list_filter_name{nfilt}];
                    
                    [source,source_name]                = h_lcmv_separate(data_slct,pkg);
                    
                    clear data_big
                    
                end
            end
        end
    end
end
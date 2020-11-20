clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,allsuj,~]        = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
%
% suj_group{1}        = allsuj(2:15,1);
% suj_group{2}        = allsuj(2:15,2);
%
% % [~,suj_group{3},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% % suj_group{3}        = suj_group{3}(2:22);
%
% suj_list = [];
%
% for n = 1:length(suj_group)
%     suj_list            = [suj_list;suj_group{n}];
% end
%
% suj_list            = unique(suj_list);

suj_list = {'yc2','yc3','yc6','yc8','yc9','yc17','yc20'};

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    list_cond_main  = {'CnD'};
    vox_size        = 0.5;
    
    load(['../data/' suj '/field/' suj '.adjusted.leadfield.' num2str(vox_size) 'cm.mat']);
    load(['../data/' suj '/field/' suj '.VolGrid.' num2str(vox_size) 'cm.mat']);
    
    for nelan = 1:length(list_cond_main)
        
        fname_in         = ['../data/' suj '/field/' suj '.' list_cond_main{nelan} '.mat'];
        
        fprintf('Loading %s\n',fname_in);
        load(fname_in)
        
        cfg                     = [];
        cfg.latency             = [-2.5 2.5];
        data_elan               = ft_selectdata(cfg,data_elan);
        
        pkg.leadfield           = leadfield;
        pkg.vol                 = vol;
        
        clear vol leadfield
        
        %         com_filter              = h_pccComonFilter(suj,data_elan,pkg,[-0.8 2],10,5,[list_cond_main{:}],['wPCCommonFilter' num2str(vox_size) 'cm']);
        
        load(['../data/' suj '/field/' suj '.CnD.5t15Hz.m800p2000.wPCCommonFilter0.5cm.mat']);
        
        cond_ix_sub             = {''};
        cond_ix_cue             = {0:2};
        cond_ix_dis             = {0};
        cond_ix_tar             = {1:4};
        
        for icond = 1:length(cond_ix_sub)
            
            trial_choose    = h_chooseTrial(data_elan,cond_ix_cue{icond},cond_ix_dis{icond},cond_ix_tar{icond});
            
            cfg             = [];
            cfg.trials      = trial_choose ;
            data_sub        = ft_selectdata(cfg,data_elan);
            
            tlist           = [-0.6 0.6];
            twin            = [0.4 0.4];
            tpad            = 0.025;
            
            flist           = [9 13 11];
            fpad            = [2 2 4];
            
            for ntime = 1:length(tlist)
                for nfreq = 1:length(flist)
                    
                    source  = h_pccSeparate(suj,data_sub,tlist(ntime),twin(ntime),tpad,flist(nfreq),fpad(nfreq), ...
                        com_filter,pkg,[cond_ix_sub{icond} list_cond_main{nelan}],['wPCCSource' num2str(vox_size) 'cm'],'no'); % create source
                    
                    clear source
                    
                end
            end
            
            clear data_elan
            
        end
        
        clear data_big
        
    end
    
end
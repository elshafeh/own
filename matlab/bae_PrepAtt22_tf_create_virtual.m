clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
suj_list    = [allsuj(2:15,1);allsuj(2:15,2)];

% suj_group{1}    = allsuj(2:15,1);
% suj_list        = [suj_group{1}; suj_group{2}];
% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list       = suj_list(2:22);
% suj_list            = [suj_group{1};suj_group{2}]; %;suj_group{3}];
% suj_list            = unique(suj_list);
% suj_list = {'yc3','yc6','yc8','yc9','yc17','yc20','yc21'};
% suj_list   = {'yc21'};

for sb = 1:length(suj_list)
    
    suj                     = suj_list{sb};
    
    for cond_main           = {'CnD'}
        
        data_append         = {};
        
        for ext_name        = {'.ComEmergencelowAlpha5Neigh.1t20Hz.m800p2000msCov'} 
            
            fname_in            = ['../data/' suj '/field/' suj '.' cond_main{:} ext_name{:} '.mat'];
            
            fprintf('Loading %s\n',fname_in);
            load(fname_in)            
        end

        %         load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
        
        %         cfg                 = [];
        %         cfg.trials          = sort([trial_array{:}]);
        %         virtsens            = ft_selectdata(cfg,virtsens);
        
        cond_ix_sub         = {'NL','NR','N','L','R',''};
        cond_ix_cue         = {0,0,0,1,2,0:2};
        cond_ix_dis         = {0,0,0,0,0,0};
        cond_ix_tar         = {[1 3],[2 4],1:4,1:4,1:4,1:4};
        
        for ncue = 1:length(cond_ix_sub)
            
            cfg                             = [];
            
            cfg.trials                      = h_chooseTrial(virtsens,cond_ix_cue{ncue},cond_ix_dis{ncue},cond_ix_tar{ncue});
            
            sub_virtsens                    = ft_selectdata(cfg,virtsens);
            
            sub_virtsens                    = h_removeEvoked(sub_virtsens);
            
            fname_out                       = [suj '.' cond_ix_sub{ncue} cond_main{:} ext_name{:}];
            
            freq                            = in_function_computeTFR(sub_virtsens,suj,fname_out,'wavelet','pow','no',7,4,-3:0.05:3,1:20,'MinEvokedAllTrials');

            clear sub_virtsens
            
        end
        
        clear virtsens
        
    end
end

%         load(['../data/' suj '/field/' suj '.CnD.100Slct.RLNRNL.mat']);
%         new_chan_index      = {[1 3 5],[2 4 6],7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33};
%         new_chan_list       = {'audL' 'audR'};
%         new_chan_list       = [new_chan_list virtsens.label(7:33)'];

%         virtsens            = ft_appenddata([],data_append{:});
%         virtsens            = h_transform_data(virtsens,{[1 3],[2 4],[5 7 9],[6 8 10],[11 13 15],[12 14 16]},{'motor_L','motor_R','vis_L','vis_R','aud_L','aud_R'});
%         virtsens            = h_transform_data(virtsens,{[1 3],[2 4]},{'aud_L','aud_R'});
%             load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
%             cfg                         = [];
%             cfg.trials                  = sort([trial_array{:}]);
%             data_append{end+1}          = ft_selectdata(cfg,virtsens);
%             data_append{end+1}          = virtsens;

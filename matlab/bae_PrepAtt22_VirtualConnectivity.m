clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

% [~,suj_list,~] = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list       = suj_list(2:22);
% suj_group{2}    = {'uc5' 'yc17' 'yc18' 'uc6' 'uc7' 'uc8' 'yc19' 'uc9' ...
%     'uc10' 'yc6' 'yc5' 'yc9' 'yc20' 'yc21' 'yc12' 'uc1' 'uc4' 'yc16' 'yc4'};
% suj_group{3}    = {'mg1' 'mg2' 'mg3' 'mg4' 'mg5' 'mg6' 'mg7' 'mg8' 'mg9' ...
%     'mg10' 'mg11' 'mg12' 'mg13' 'mg14' 'mg15' 'mg16' 'mg17' 'mg18' 'mg19'};

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

suj_list        = [suj_group{1};suj_group{2}];
suj_list        = unique(suj_list);

% [~,suj_list,~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:22);

clearvars -except suj_list

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    
    fprintf('Loading Virtual Data For %s\n',suj)
    
    load(['../data/' suj '/field/' suj '.CnD.NewAVBroad.1t20Hz.m800p2000msCov.mat']);
    
    virtsens            = h_transform_data(virtsens,{[1 3 5 2 4 6],[7 9 11 8 10 12]},{'occ_avg','aud_avg'});
    
    data_temp{1}        = virtsens ;
    
    load(['../data/' suj '/field/' suj '.CnD.SchaefTDBU.1t20Hz.m800p2000msCov.mat']);
    
    virtsens            = h_transform_data(virtsens,{[7 8],[21 22],1,2,3,4,5,6,16,17,18,19,20},{'fef_L','fef_R','post1_L','post2_L','post3_L','post4_L','post5_L','post6_L','post1_R','post2_R','post3_R','post4_R','post5_R'});
    
    data_temp{2}        = virtsens ;
    
    data                = ft_appenddata([],data_temp{:}); clear virtsens data_temp ;
    
    %     load(['../data/' suj '/field/' suj '.CnD.100Slct.RLNRNL.mat']);
    %     load(['../data/' suj '/field/' suj '.CnD.AgeContrast80Slct.RLNRNL.mat']);
    %     cfg                 = [];
    %     cfg.trials          = [trial_array{:}];
    %     data                = ft_selectdata(cfg,data);
    
    list_cue            = {''};
    list_ix_cue         = {0:2};
    list_ix_tar         = {1:4};
    list_ix_dis         = {0};
    
    for ncue = 1:length(list_cue)
        
        cfg                 = [];
        cfg.trials          = h_chooseTrial(data,list_ix_cue{ncue},list_ix_dis{ncue},list_ix_tar{ncue});
        new_data            = ft_selectdata(cfg,data);
        
        new_data            = h_removeEvoked(new_data);
        
        cfg                 = [];
        cfg.method          = 'wavelet';
        cfg.output          = 'fourier';
        cfg.toi             = -3:0.05:3;
        cfg.foi             = 1:20;
        cfg.keeptrials      = 'yes';
        freq                = ft_freqanalysis(cfg,new_data);
        
        fprintf('Saving Virtual Frequency For %s\n',suj)
        
        ext_name_out    = 'MinEvoked';
        ext_virt_use    = 'NewAveragedAVSchaef';
        
        save(['../data/' suj '/field/' suj '.' list_cue{ncue} 'CnD.' ext_virt_use '.freqAndCfG_4fucntionalConnectivity' ext_name_out '.mat'],'freq','cfg','-v7.3');
        
        %         load(['../data/' suj '/field/' suj '.' list_cue{ncue} 'CnD.' ext_virt_use '.freqAndCfG_4fucntionalConnectivity' ext_name_out '.mat']);
        
        cfg             = [];
        cfg.method      = 'plv';
        freq_conn       = ft_connectivityanalysis(cfg,freq);
        
        freq_conn.powspctrm = freq_conn.plvspctrm; freq_conn = rmfield(freq_conn,'dof'); freq_conn = rmfield(freq_conn,'cfg'); freq_conn = rmfield(freq_conn,'plvspctrm');
        
        save(['../data/' suj '/field/' suj '.' list_cue{ncue} 'CnD.' ext_virt_use '.plv' ext_name_out '.mat'],'freq_conn','-v7.3'); clear freq_conn
        
        cfg             = [];
        cfg.method      = 'coh';
        cfg.complex     = 'absimag';
        freq_conn       = ft_connectivityanalysis(cfg,freq);
        
        freq_conn.powspctrm = freq_conn.cohspctrm; freq_conn = rmfield(freq_conn,'dof'); freq_conn = rmfield(freq_conn,'cfg'); freq_conn = rmfield(freq_conn,'cohspctrm');
        
        save(['../data/' suj '/field/' suj '.' list_cue{ncue} 'CnD.' ext_virt_use '.coh' ext_name_out '.mat'],'freq_conn','-v7.3'); clear freq_conn
        
        clear freq new_data; clc;
        
    end
    
    clear data ;
    
end
clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');

suj_group{1}    = allsuj(2:end,1);
suj_group{2}    = allsuj(2:end,2);

lst_group       = {'Old','Young'};

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'DIS','fDIS'};
        cond_sub            = {'V1','N1'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                dir_data                = ['/Volumes/hesham_megabup/pat22_fieldtrip_data/']; % '';
                fname_in                = [dir_data suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                tmp{dis_type}           = data_pe;
                
                clear data_pe data_gfp
                
            end
            
            allsuj_data{ngrp}{sb,ncue}          = tmp{1};
            allsuj_data{ngrp}{sb,ncue}.avg      = allsuj_data{ngrp}{sb,ncue}.avg - tmp{2}.avg;
            
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            allsuj_data{ngrp}{sb,ncue}          = ft_timelockbaseline(cfg,allsuj_data{ngrp}{sb,ncue});
            
        end
        
    end
    
    %     for ncue = 1:size(allsuj_data{ngrp},2)
    %         gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    %     end
    
end

clearvars -except *_data cond_sub lst_group;

list_time                   = [0.04 0.08 ; 0.08 0.13 ; 0.2 0.25 ; 0.29 0.34 ;  0.35 0.5];

for ntime = 1:size(list_time,1)
    
    cfg                     = [];
    cfg.latency             = list_time(ntime,:);
    cfg.method              = 'montecarlo';
    cfg.correctm            = 'cluster';
    cfg.clusteralpha        = 0.05;
    cfg.clusterstatistic    = 'maxsum';
    cfg.tail                = 0;
    cfg.clustertail         = 0;
    cfg.alpha               = 0.025;
    cfg.numrandomization    = 1000;
    
    [~,neighbours]          = h_create_design_neighbours(14,allsuj_data{1}{1},'meg','t');
    
    cfg.neighbours          = neighbours;
    cfg.minnbchan           = 2;
    
    [stat{ntime},results_summary{ntime}]  = h_sens_anova(cfg,allsuj_data);
    
end

clearvars -except *_data cond_sub lst_group stat results_summary;

list_component              = {'P50','N1','earlyP3','lateP3','RON'};

for ntime = 1:5
    
    figure;
    
    for ntest = 1:5
        
        stat_to_plot            = h_plotStat(stat{ntime}{ntest},0.000000000000001,0.05);
        
        subplot(1,5,ntest)
        
        cfg                     = [];
        cfg.layout              = 'CTF275.lay';
        cfg.zlim                = [-3 3];
        cfg.marker              = 'off';
        cfg.comment             = 'no';
        ft_topoplotER(cfg,stat_to_plot)
        
        title([list_component{ntime} ' ' results_summary{ntime}{ntest}]);
        
    end
end


% list_channel{1} = {'MLF11', 'MLF12', 'MLF21', 'MLF22', 'MLF23', 'MLF31', 'MLF32', 'MLF33', ...
%     'MLF34', 'MLF41', 'MLF42', 'MLF43', 'MLF44', 'MLF51', 'MLF52', 'MLF53', 'MLF61', 'MRF11', ...
%     'MRF21', 'MRF22', 'MRF31', 'MRF32', 'MRF41', 'MRF42', 'MRF43', 'MRF51', 'MRF52', 'MZF02', 'MZF03'};
%
% list_channel{2} = {'MRT21', 'MRT22', 'MRT23', 'MRT31', 'MRT32', 'MRT33', 'MRT34', 'MRT35', 'MRT41', 'MRT42', 'MRT43', 'MRT44', 'MRT51', 'MRT52', 'MRT53'};
%
% list_channel{3}         = {'MLO12', 'MLO13', 'MLO14', 'MLO22', 'MLO23', 'MLO24', 'MLO32', 'MLO33', ...
%     'MLO34', 'MLO43', 'MLO44', 'MLP41', 'MLP42', 'MLP53', 'MLP54', 'MLP55', 'MLT16', 'MLT26',...
%     'MLT27', 'MLT36', 'MLT37', 'MLT45', 'MLT46', 'MLT47', 'MLT55', 'MLT56', 'MLT57'};
%
% list_channel{4}         = {'MLC15', 'MLC16', 'MLC17', 'MLC23', 'MLC24', 'MLC25', 'MLC31', 'MLC32', ...
% 'MLC41', 'MLC42', 'MLC52', 'MLC53', 'MLC54', 'MLC55', 'MLC61', 'MLC62', 'MLC63', 'MLF56', 'MLF66', ...
%  'MLF67', 'MLO11', 'MLO12', 'MLO13', 'MLO14', 'MLO21', 'MLO22', 'MLO23', 'MLO24', 'MLO31', 'MLO32', ...
% 'MLO33', 'MLO34', 'MLO41', 'MLO42', 'MLO43', 'MLO44', 'MLO53', 'MLP11', 'MLP12', 'MLP21', 'MLP22', ...
%  'MLP23', 'MLP31', 'MLP32', 'MLP33', 'MLP34', 'MLP35', 'MLP41', 'MLP42', 'MLP43', 'MLP44', 'MLP45', ...
%  'MLP51', 'MLP52', 'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT12', 'MLT13', 'MLT14', 'MLT15', ...
%  'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT37', 'MLT47', 'MLT56', 'MLT57', 'MRC41', 'MRC42', 'MRC52', ...
% 'MRC53', 'MRC54', 'MRC55', 'MRC61', 'MRC62', 'MRC63', 'MRO11', 'MRO12', 'MRO21', 'MRO22', ...
% 'MRO31', 'MRO32', 'MRO41', 'MRO42', 'MRP11', 'MRP12', 'MRP21', 'MRP22', 'MRP31', 'MRP32', ...
% 'MRP33', 'MRP41', 'MRP51', 'MRP52', 'MRP53', 'MZC02', 'MZC03', 'MZC04', 'MZO01', 'MZO02', 'MZP01'};
%
%
% for n = 1:4
%     subplot(1,4,n)
%
%     plt_cfg                 = [];
%     plt_cfg.channel         = list_channel{n};
%     plt_cfg.p_threshold     = 0.1;
%     plt_cfg.lineWidth       = 3;
%     plt_cfg.time_limit      = [-0.1 0.6];
%     plt_cfg.z_limit         = [-60 110];
%     plt_cfg.fontSize        = 18;
%
%     h_plotSingleERFstat_selectChannel(plt_cfg,stat{1},ft_timelockgrandaverage([],gavg_data{1,:}),ft_timelockgrandaverage([],gavg_data{2,:}));
%     %     legend({'VDis','NDis'});
%     legend({'Old','Young'});
%
% end
%

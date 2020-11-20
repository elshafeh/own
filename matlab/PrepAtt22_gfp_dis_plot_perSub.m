clear ; clc ; addpath(genpath('../fieldtrip-20151124/'));

% [~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');
% 
% suj_group{1}    = allsuj(2:15,1);
% suj_group{2}    = allsuj(2:15,2);
% lst_group       = {'Old','Young'};

[~,suj_group{1},~]      = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}            = suj_group{1}(2:22);


for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'DIS','fDIS'};
        cond_sub            = {''};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                            = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/' suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                cfg                                 = [];
                cfg.baseline                        = [-0.1 0];
                data_pe                             = ft_timelockbaseline(cfg,data_pe);
                
                %                 cfg                                 = [];
                %                 cfg.method                          = 'amplitude';
                %                 data_gfp                            = ft_globalmeanfield(cfg,data_pe);
                
                tmp{dis_type}                       = data_pe;
                
                clear data_pe data_gfp
                
            end
            
            cfg                                 = [];
            cfg.parameter                       = 'avg';
            cfg.operation                       = 'x1-x2';
            diff                                = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            allsuj_data{ngrp}{sb,ncue}          =  ft_globalmeanfield(cfg,diff);
            
        end
        
        %         allsuj_data{ngrp}{sb,3}                 = ft_timelockgrandaverage([],allsuj_data{ngrp}{sb,1:2});
        
    end
    
end

clearvars -except *_data cond_sub

% for ngroup = 1% :2

grand_average   = ft_timelockgrandaverage([],allsuj_data{:}{:});

plot(grand_average.time,grand_average.avg,'LineWidth',2);
ylim([0 160])
xlim([-0.1 0.35])

% subplot(2,1,ngroup)
% hold on
% for sb = 1:14
%     plot(allsuj_data{ngroup}{sb,3}.time,allsuj_data{ngroup}{sb,3}.avg,'LineWidth',2);
%     ylim([0 160])
%     xlim([-0.2 0.6])
% end
% cfg                     = [];
% cfg.xlim                = [-0.2 1];
% cfg.ylim                = [0 120];
% ft_singleplotER(cfg,gavg_data{ngroup,:});
% legend(cond_sub);
% end
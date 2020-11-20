clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);
lst_group       = {'Old','Young'};

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'DIS','fDIS'};
        cond_sub            = {'V','N'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                tmp{dis_type}                       = data_pe;
                
                clear data_pe data_gfp
                
            end
            
            cfg                                 = [];
            cfg.parameter                       = 'avg';
            cfg.operation                       = 'x1-x2';
            avg_diff                            = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
            
            %             avg_diff                            = tmp{2};
            
            cfg                                 = [];
            cfg.baseline                        = [-0.1 0];
            avg_diff                            = ft_timelockbaseline(cfg,avg_diff);
            
            cfg                                 = [];
            cfg.method                          = 'amplitude';
            data_gfp                            = ft_globalmeanfield(cfg,avg_diff);
            
            allsuj_data{ngrp}{sb,ncue}          = data_gfp;
            
        end
        
    end
    
    for ncue = 1:size(allsuj_data{ngrp},2)
        gavg_data{ngrp,ncue} = ft_timelockgrandaverage([],allsuj_data{ngrp}{:,ncue});
    end
    
end

clearvars -except *_data cond_sub

figure;
hold on;


for ngroup = 1:2
    
    %     subplot(1,2,ngroup)
    
    for cnd = 1:2
        plot(gavg_data{ngroup,cnd}.time,gavg_data{ngroup,cnd}.avg,'LineWidth',2);
        ylim([0 120])
        xlim([-0.2 0.6])
    end
    
    %     cfg                     = [];
    %     cfg.xlim                = [-0.2 1];
    %     cfg.ylim                = [0 120];
    %     ft_singleplotER(cfg,gavg_data{ngroup,:});
    
    
end


legend({'ov','on','yv','yn'});
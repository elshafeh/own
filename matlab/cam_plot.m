clear ; clc ; addpath(genpath('/dycog/Aurelie/DATA/MEG/fieldtrip-20151124/'));

[~,allsuj,~]  = xlsread('../documents/PrepAtt22_Matching4Matlab_n11.xlsx');

[~,suj_group{1},~]  = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_group{1}        = suj_group{1}(2:22);

for ngrp = 1:length(suj_group)
    
    suj_list = suj_group{ngrp};
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        cond_main           = {'DIS.eeg','fDIS.eeg'};
        cond_sub            = {'N'};
        
        for ncue = 1:length(cond_sub)
            
            for dis_type = 1:2
                
                fname_in                            = ['../data/' suj '/field/' suj '.' cond_sub{ncue} cond_main{dis_type} '.bpOrder2Filt0.5t20Hz.pe.mat'];
                
                fprintf('Loading %s\n',fname_in);
                
                load(fname_in);
                
                
                %                 cfg                                 = [];
                %                 cfg.baseline                        = [-0.1 0];
                %                 data_pe                             = ft_timelockbaseline(cfg,data_pe);
                
                tmp{dis_type}                       = data_pe;
                
                clear data_pe data_gfp
                
                
            end
            
            cfg                                 = [];
            cfg.parameter                       = 'avg';
            cfg.operation                       = 'x1-x2';
            data_diff          = ft_math(cfg,tmp{1},tmp{2}); clear tmp ;
            
            for nchan = 1:length(data_diff.label)
                
                cfg                                 = [];
                cfg.channel                         = nchan;
                allsuj_data{ngrp}{sb,ncue,nchan}    = ft_selectdata(cfg,data_diff);
                
            end
        end
    end
end

clearvars -except *_data cond_sub lst_group;

for nchan = 1:7
    
    figure;
    
    for sb = 1:21
        
        subplot(7,3,sb)
        cfg = [];
        cfg.ylim = [-20 20];
        ft_singleplotER(cfg,allsuj_data{1}{sb,1,nchan});
        title(['yc' num2str(sb)])
        
    end
end

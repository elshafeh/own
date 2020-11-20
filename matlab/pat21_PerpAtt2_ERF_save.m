clear ; clc ;dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    for prt =1:3
        
        suj         = ['yc' num2str(suj_list(sb))] ;
        fname_in    = [suj '.pt' num2str(prt) '.CnD'];
        
        fprintf('Loading %50s\n',fname_in);
        load(['../data/elan/' fname_in '.mat'])
        
        tmp{prt} = data_elan ; clear data_elan
        
    end
    
    data_f                  = ft_appenddata([],tmp{:}); clear tmp ;
    
    cfg                     = [];
    cfg.lpfilter            = 'yes';
    cfg.lpfreq              = 20;
    %     cfg.bpfilter            = 'yes';
    %     cfg.bpfreq              = [0.5 20];
    data_f                  = ft_preprocessing(cfg,data_f);
    
    lst_cue                 = {2,1,0,0};
    lst_dis                 = {0,0,0,0};
    lst_tar                 = {1:4,1:4,[2 4],[1 3]};
    
    for cc = 1:length(lst_cue)
        
        itrl                       = h_chooseTrial(data_f,lst_cue{cc},lst_dis{cc},lst_tar{cc});
        cfg                        = [];
        cfg.trials                 = itrl ;
        allsuj{sb,cc}              = ft_timelockanalysis(cfg,data_f);
        allsuj{sb,cc}              = rmfield(allsuj{sb,cc},'cfg');
        
    end
    
    clear data_f cnd_delay itrl cfg
    
end

clearvars -except allsuj ;

save('../data/yctot/gavg/new.1RCnD.2LCnD.3NCnDRT.4NCnDLT.pe.mat','-v7.3');
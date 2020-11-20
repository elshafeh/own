clear ; clc ;dleiftrip_addpath;

suj_list = [1:4 8:17];

for sb = 1:length(suj_list)
    
    for prt =1:3
        
        suj         = ['yc' num2str(suj_list(sb))] ;
        fname_in    = [suj '.pt' num2str(prt) '.bp'];
        
        fprintf('Loading %50s\n',fname_in);
        load(['../data/elan/' fname_in '.mat'])
        
        tmp{prt} = data_elan ; clear data_elan
        
    end
    
    data_f                  = ft_appenddata([],tmp{:}); clear tmp ;
    
    cfg                     = [];
    %     cfg.lpfilter            = 'yes';
    %     cfg.lpfreq              = 20;
    cfg.bpfilter            = 'yes';
    cfg.bpfreq              = [0.5 20];
    data_f                  = ft_preprocessing(cfg,data_f);
    
    for cnd_cue = 1:2
        
        if cnd_cue < 2
            itrl                            = h_chooseTrial(data_f,0:2,0,[3 4]);
        else
            itrl                            = h_chooseTrial(data_f,0:2,0,[1 2]);
        end
        
        cfg                                 = [];
        cfg.trials                          = itrl ;
        allsuj{sb,cnd_cue}                  = ft_timelockanalysis(cfg,data_f);
        allsuj{sb,cnd_cue}                  = rmfield(allsuj{sb,cnd_cue},'cfg');
        
    end
    
    clear data_f cnd_delay itrl cfg
    
end

clearvars -except allsuj ;

save('../data/yctot/gavg/new.1pull2push.bp.pe.mat','-v7.3');
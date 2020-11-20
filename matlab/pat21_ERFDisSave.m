clear ; clc ;

for sb = 1:14
    for c = 1:2
        
        suj_list    = [1:4 8:17];
        suj         = ['yc' num2str(suj_list(sb))] ;
        cnd_list    = {'DIS','fDIS'};
        
        %         for prt = 1:3
        %             fname_in    = [suj '.pt' num2str(prt) '.' cnd_list{c}];
        %             fprintf('Loading %50s\n',fname_in);
        %             load(['../data/elan/' fname_in '.mat'])
        %             tmp{prt}                = data_elan ; clear data_elan ;
        %         end
        %         data_f                  = ft_appenddata([],tmp{:}); clear tmp ;
        
        fname_in    = [suj '.' cnd_list{c} '.eeg'];
        fprintf('Loading %50s\n',fname_in);
        load(['../data/elan/' fname_in '.mat'])
        
        cfg                     = [];
        cfg.bpfilter            = 'yes';
        cfg.bpfreq              = [0.5 20];
        data_f                  = ft_preprocessing(cfg,data_elan);
        
        for cnd_cue = 1:3
            cfg                           = [];
            cfg.trials                    = h_chooseTrial(data_f,0:2,cnd_cue,1:4) ;
            allsuj{sb,c,cnd_cue}          = ft_timelockanalysis(cfg,data_f);
            allsuj{sb,c,cnd_cue}          = rmfield(allsuj{sb,c,cnd_cue},'cfg');
        end
        
        clear data_f
        
    end

    clearvars -except sb allsuj
end

clearvars -except allsuj ;

save('../data/yctot/gavg/123Dis.1.Dis.2.fDis.eeg.pe.mat','-v7.3');
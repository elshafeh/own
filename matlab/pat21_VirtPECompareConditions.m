clear ; clc ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'DIS','fDIS'};
    %     cnd_list = {'nDt'};
    
    for cnd = 1:length(cnd_list)
        
        load(['../data/trialinfo/' suj '.' cnd_list{cnd} '.trialinfo.mat']);
        data_elan.trialinfo = trialinfo ; clear trialinfo ;
        
        for prt = 1:3
            
            fname_out = [suj '.pt' num2str(prt) '.' cnd_list{cnd} '.virtlcmvN1.TimeCourse'];
            
            fprintf('\nLoading %50s \n',fname_out);
            load(['../data/pe/' fname_out '.mat'])
            
            tmp{prt} = virtsens; clear virtsens ;
            
        end
        
        tmp_append = ft_appenddata([],tmp{:});
        
        for cnd_cue = 1:2
            
            cfg = [];
            
            %             cfg.trials = h_chooseTrial(data_elan,cnd_cue-1,1:3,1:4);
            
            if cnd_cue ==2
                cfg.trials = h_chooseTrial(data_elan,0,1:3,1:4);
            else
                cfg.trials = h_chooseTrial(data_elan,[1 2],1:3,1:4);
            end
            
            allsuj{sb,cnd_cue,cnd} = ft_timelockanalysis(cfg,tmp_append);
            
        end
        
    end
    
end

clearvars -except allsuj ;

for cnd = 1:size(allsuj,2)
    
    for cnd_dis = 1:2
        tmp{cnd_dis}            = ft_timelockgrandaverage([],allsuj{:,cnd,cnd_dis});
        cfg                     = [];
        cfg.baseline            = [-0.1 0];
        tmp{cnd_dis}            = ft_timelockbaseline(cfg,tmp{cnd_dis});
    end
    
    cfg                 = [];
    cfg.parameter       = 'avg';
    cfg.operation       = 'subtract';
    gavg{cnd}           = ft_math(cfg,tmp{1},tmp{2});
    
    %     cfg             = [];
    %     cfg.baseline    = [-0.1 0];
    %     gavg{cnd}       = ft_timelockbaseline(cfg,gavg{cnd});
    
end

for chn = 1:length(gavg{1}.label)
    
    subplot(2,2,chn)
    cfg         = [];
    cfg.xlim    = [-0.1 0.6];
    cfg.ylim    = [-5e+10 2e+11];
    cfg.channel = chn;
    ft_singleplotER(cfg,gavg{:});
    %     legend({'VnDT','NnDT'});
    %     legend({'NCue','LCue','RCue'});
    
    legend({'VCue','NCue'});
    
end
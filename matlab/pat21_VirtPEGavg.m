clear ; clc ; 

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    %     cnd_list = {'DIS','fDIS'};
    cnd_list = {'nDt'};
    
    for cnd = 1:length(cnd_list)
        for prt = 1:3
            
            fname_out = [suj '.pt' num2str(prt) '.' cnd_list{cnd} '.virtlcmvN1.TimeCourse'];
            
            fprintf('\nLoading %50s \n',fname_out);
            load(['../data/pe/' fname_out '.mat'])
            
            
            tmp{prt} = virtsens; clear virtsens ;
            
        end
        
        allsuj{sb,cnd} = ft_appenddata([],tmp{:});
        allsuj{sb,cnd} = ft_timelockanalysis([],allsuj{sb,cnd});
    end
    
end

clearvars -except allsuj cnd_list

for cnd = 1:size(allsuj,2)
    
    gavg{cnd}       = ft_timelockgrandaverage([],allsuj{:,cnd});
    cfg             = [];
    cfg.baseline    = [-0.2 -0.1];
    gavg{cnd}       = ft_timelockbaseline(cfg,gavg{cnd});
    
end

for chn = 1:length(gavg{1}.label)
    
    subplot(2,2,chn)
    cfg         = [];
    cfg.xlim    = [-0.1 0.6];
    cfg.ylim    = [-5e+10 1.5e+11];
    cfg.channel = chn;
    ft_singleplotER(cfg,gavg{:});
    legend(cnd_list);
    
end
clear ; clc ; dleiftrip_addpath ; close all;

for t = 1:3
    
    for j = 1:3
        
        for sb = 1:14
            
            suj_list        = [1:4 8:17];
            suj             = ['yc' num2str(suj_list(sb))];
            
            load(['../data/tfr/' suj '.Soma.CohCohImagPLV.AuditoryWithIPSFEF.Bloc' num2str(t) '.mat'])
            
            gavg{t,j}.freq                  = suj_coh{j}.freq;
            gavg{t,j}.label                 = suj_coh{j}.label;
            gavg{t,j}.dimord                = suj_coh{j}.dimord;
            gavg{t,j}.cohspctrm(sb,:,:,:)   = suj_coh{j}.cohspctrm;
            
        end
        
        gavg{t,j}.cohspctrm = squeeze(mean(gavg{t,j}.cohspctrm,1));
        
    end
    
end

clearvars -except gavg ;

for t = 1:3
    
    figure;
    cfg             = [];
    cfg.ylim        = [0 1];
    cfg.xlim        = [1 20];
    ft_connectivityplot(cfg,gavg{t,[1 3 2]});
end


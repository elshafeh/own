clear ; clc ; dleiftrip_addpath ;

ext_data = {'123Dis.1.Dis.2.fDis.eeg.pe.mat','D123.1.Dis.2.fDis.pe.mat'};

for ndata = 1:2
    
    load(['../data/yctot/gavg/' ext_data{ndata}]);
    
    for sb = 1:14
        
        for ndis = 1:2
            tmp{ndis}       = ft_timelockgrandaverage([],allsuj{sb,ndis,:});
        end
        
        new_suj{sb,ndata}       = tmp{1};
        new_suj{sb,ndata}.avg   = tmp{1}.avg - tmp{2}.avg; clear tmp ;
        
        cfg                 = [];
        cfg.latency         = [-0.1 1];
        new_suj{sb,ndata}   = ft_selectdata(cfg,new_suj{sb,ndata});
        
        %         cfg                 = [];
        %         cfg.baseline        = [-0.1 0];
        %         new_suj{sb,ndata}   = ft_timelockbaseline(cfg,new_suj{sb,ndata});
        
        cfg                 = [];
        cfg.method          = 'amplitude';
        new_suj{sb,ndata}   = ft_globalmeanfield(cfg,new_suj{sb,ndata});
        
    end
    
    clear allsuj;
    
end

allsuj = new_suj ; clearvars -except allsuj

for ndata = 1:2
    gavg{ndata} = ft_timelockgrandaverage([],allsuj{:,ndata});
end

% for ndata = 1:2
%     subplot(1,2,ndata)
%     plot(gavg{ndata}.time,gavg{ndata}.avg,'LineWidth',5);
%     xlim([-0.1 1.4]);
%     vline(0,'-k');
%     vline(1.2,'-k');
%     title(lst_data{ndata});
% end

lst_data = {'EEG','MEG'};

% lm1 = find(round(gavg{1}.time,3) == round(-0.1,3));
% lm2 = find(round(gavg{1}.time,3) == round(1.2,3));

data2plot = [gavg{1}.avg*20;gavg{2}.avg(1,1:end-1)];
plot(gavg{1}.time,data2plot,'LineWidth',5);
xlim([-0.1 0.6]);
ylim([0 70])
set(gca,'fontsize',18)
legend(lst_data);
for n = 10:10:65
    hline(n,'--k');
end
vline(0,'-k');

vline(0.6,'--k');
vline(0.8,'--k');
vline(1,'--k');

% forpresentation = data2plot(:,lm1:lm2);
% gavg{1}.time(lm1:lm2);
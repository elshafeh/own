clear ; clc ;

ext_data = {'VN.nDT.eeg.pe.mat','LRNnDT.pe.mat'};

for ndata = 1:2
    load(['../data/yctot/gavg/' ext_data{ndata}]);
    
    for sb = 1:14
        
        new_suj{sb,ndata}   = ft_timelockgrandaverage([],allsuj{sb,:});
        
        cfg                 = [];
        cfg.latency         = [-0.1 1];
        new_suj{sb,ndata}   = ft_selectdata(cfg,new_suj{sb,ndata});
        
        cfg                 = [];
        cfg.baseline        = [-0.1 0];
        new_suj{sb,ndata}   = ft_timelockbaseline(cfg,new_suj{sb,ndata});
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

data2plot = [gavg{1}.avg*10;gavg{2}.avg];
plot(gavg{1}.time,data2plot,'LineWidth',8);
xlim([-0.1 1]);
set(gca,'fontsize',18)
legend(lst_data);
vline(0,'-k');
for n = 5:5:65
    hline(n,'--k');
end

% vline(0.6,'--k');
% vline(0.8,'--k');
% vline(1,'--k');

% forpresentation = data2plot(:,lm1:lm2);
% gavg{1}.time(lm1:lm2);
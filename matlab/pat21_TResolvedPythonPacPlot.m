for sb = 1:14
    
    suj_list    = [1:4 8:17];
    suj         = ['yc' num2str(suj_list(sb))];
    
    list_cues    = {'NCnD','LCnD','RCnD'};
    list_method  = 'ndPAC';
    list_time    = {'m400m200','m200m0','p0p200','p200p400','p400p600','p600p800','p800p1000',...
        'p1000p1200','p1200p1400','p1400p1600','p1600p1800'};
    list_norm    = 'NoNorm';
    list_chan    = {'audL','audR','RIPS'};
    
    for xcue = 1:length(list_cues)
        
        grand_avg{sb,xcue}.avg                    = zeros(length(list_chan),length(list_time));
        grand_avg{sb,xcue}.time                   = -0.4:0.2:1.6;
        grand_avg{sb,xcue}.label                  = list_chan;
        grand_avg{sb,xcue}.dimord                 = 'chan_time';
        
        for xtime = 1:length(list_time)
            
            load(['../data/python_data/' suj '.' list_cues{xcue} '.' list_time{xtime} '.' list_method '.ShuAmp' '.' list_norm '.100perm.mat'])
            
            x1                                     = find(py_pac.vec_amp==60);
            x2                                     = find(py_pac.vec_amp==70);
            y1                                     = find(py_pac.vec_pha==9);
            y2                                     = find(py_pac.vec_pha==10);

            py_pac.xpac                            = squeeze(py_pac.xpac);
            py_pac.xpac                            = squeeze(mean(py_pac.xpac,3));
            py_pac.xpac                            = permute(py_pac.xpac,[3 1 2]);
            
            grand_avg{sb,xcue}.avg(:,xtime)         = mean(squeeze(mean(py_pac.xpac(:,x1:x2,y1:y2),3)),2);
            act                                     = grand_avg{sb,xcue}.avg(:,xtime);
            bsl                                     = grand_avg{sb,xcue}.avg(:,1);
            
            
            grand_avg{sb,xcue}.avg(:,xtime)         = act-bsl;
            
        end
        
    end
end

clearvars -except grand_avg list_*;

for xcue = 1:length(list_cues)
    suj_avg{xcue} = ft_timelockgrandaverage([],grand_avg{:,xcue});
end

clearvars -except suj_avg list_*;

for xchan = 1:length(list_chan)
    subplot(3,1,xchan)
    hold on
    for xcue = 1:3
        plot(suj_avg{xcue}.time,suj_avg{xcue}.avg(xchan,:))
    end
    
    xlim([-0.2 1.6])
    ylim([5 30])
    legend(list_cues)
    title(suj_avg{xcue}.label{xchan})
    
end

figure;

for xcue = 1:length(list_cues)
    
    subplot(3,1,xcue)
    
    hold on
    
    for xchan = 1:length(list_chan)
        plot(suj_avg{xcue}.time,suj_avg{xcue}.avg(xchan,:))
    end
    
    xlim([-0.2 1.6])
    ylim([5 30])
    legend(list_chan)
    title(list_cues{xcue})
    
end
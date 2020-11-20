clear ; clc ; close all ; dleiftrip_addpath ;

ext_list = {'DisExplore.1t20Hz','DisExplore.50t90Hz','DisExplore.1t90Hz'}; %

for cnd_ext = 1:3
    
    ext = ext_list{cnd_ext};
    
    i = 0 ;
    
    for cnd = {'DIS','fDIS'}
        i = i + 1;
        load(['../data/yctot/gavg/virtual' cnd{:} '.' ext 'ExtWav.mat'])
        gavg{i} = allsuj ; clear allsuj ;
    end
    
    for sb = 1:14
        for cnd = 1:size(gavg{1},2)
            allsuj2plot(sb,cnd,:,:,:,cnd_ext,1) = gavg{1}{sb,cnd};
            allsuj2plot(sb,cnd,:,:,:,cnd_ext,2) = gavg{2}{sb,cnd};
        end
    end
    
    clear gavg
    
    f1 = 16;
    f2 = 26;
    
    figure ;
    
    for chan = 1:6
        
        i = 0 ;
        
        for cnd = 13:15
            
            i= i+1;
            
            toplot(i,:) = nanmean(squeeze(nanmean(allsuj2plot(:,cnd,chan,f1:f2,:,cnd_ext),1)),1);
            
            t1 = find(round(template.time,2) == -0.2);
            t2 = find(round(template.time,2) == -0.1);
            
            bsl = nanmean(toplot(i,t1:t2));
            
            toplot(i,:) = (toplot(i,:)-bsl)./bsl;
            
        end
        
        subplot(2,3,chan)
        plot(template.time,toplot)
        title(template.label{chan});
        legend(template.condarrange{13:15});
        vline(0,'-k');
        hline(0,'-k');
        xlim([-0.4 1]);
        
    end
end
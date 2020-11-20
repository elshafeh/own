clear ; clc ; close all ; dleiftrip_addpath ;

% load ../data/yctot/gavg/disexplorematrix.mat

ext_list = {'NewDisExplore.1t20Hz','NewDisExplore.50t90Hz','NewDisExplore.1t90Hz'}; %

for cnd_ext = 1:3
    
    ext = ext_list{cnd_ext};
    
    i = 0 ;
    
    for cnd = {'DIS','fDIS'}
        i = i + 1;
        load(['../data/yctot/gavg/virtual/' cnd{:} '.' ext 'ExtWav.mat'])
        gavg{i} = allsuj ; clear allsuj ;
    end
    
    for sb = 1:14
        for cnd = 1:size(gavg{1},2)
            allsuj2plot(sb,cnd,:,:,:,cnd_ext,1) = gavg{1}{sb,cnd} ;
            allsuj2plot(sb,cnd,:,:,:,cnd_ext,2) = gavg{2}{sb,cnd} ;
        end
    end
    
    clear gavg
    
end


clearvars -except template allsuj2plot

allsuj2plot = squeeze(mean(allsuj2plot,1));
nw_allsuj   = squeeze(allsuj2plot(:,:,:,:,:,1)) - squeeze(allsuj2plot(:,:,:,:,:,2));

allsuj2plot = nw_allsuj; clear nw_allsuj ;

f1 = 12;
f2 = 15;

ext_list = {'NewDisExplore.1t20Hz','NewDisExplore.50t90Hz','NewDisExplore.1t90Hz'}; %

for cnd_ext = [1 3]
    
    figure ;
    
    for chan = 1:4
        
        ext = ext_list{cnd_ext};
        
        i = 0 ;
        
        for cnd = 13:15
            
            i= i+1;
            
            toplot(i,:) = squeeze(nanmean(allsuj2plot(cnd,chan,f1:f2,:,cnd_ext),3));
            
            t1 = find(round(template.time,2) == -0.4);
            t2 = find(round(template.time,2) == -0.2);
            
            %             bsl         = nanmean(toplot(i,t1:t2));
            %             toplot(i,:) = (toplot(i,:)-bsl)./bsl;
            %             toplot(i,:) = toplot(i,:)-bsl;
            %             toplot(i,:) = toplot(i,:) - nanmean(toplot(i,:));
            
        end
        
        subplot(2,2,chan)
        plot(template.time,toplot)
        title([ext ' ' template.label{chan}]);
        legend(template.condarrange{13:15});
        vline(0,'-k');
        hline(0,'-k');
        xlim([-0.5 0.8]);
        
    end
    
end
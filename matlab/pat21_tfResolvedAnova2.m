clear;clc;dleiftrip_addpath;

for sb = 1:14
    
    suj_list    = [1:4 8:17];
    cond = {'RCnD','LCnD','NCnD'};
    suj = ['yc' num2str(suj_list(sb))] ;
    
    for c = 1:3
        
        fname_in = [suj '.' cond{c} '.tfResolved.9&13Hz.m700p1200ms.mat'];
        fprintf('Loading %50s \n',fname_in);
        load(['../data/' suj '/source/' fname_in])
        
        lm1 = find(round(tResolvedAvg.time,2) == -0.6);
        lm2 = find(round(tResolvedAvg.time,2) == -0.2);
        
        bsl = mean(tResolvedAvg.pow(:,:,lm1:lm2),3);
        
        load ../data/template/source_struct_template_MNIpos.mat
        
        for t = 1:20
            tResolvedAvg.pow(:,:,t) = (tResolvedAvg.pow(:,:,t) - bsl) ./ bsl ;
        end
        
        source_avg{sb,c} = tResolvedAvg.pow;
        
        clear tResolvedAvg
        
    end
    
end

clearvars -except source_avg ; clc ;

load ../data/yctot/ArsenalIndex.mat;

roi_list = unique(indx_tot(:,2));

for f = 1:2
    
    for chn = 1:length(roi_list)
        
        ix_t = 0 ;
        
        for t = 1:20;
            
            ix_t = ix_t + 1;
            
            Y   = [];  S = [];
            F1  = []; F2 = [];
            
            for cnd = 1:3
                
                for sb = 1:14
                    
                    ix  = find(indx_tot(:,2)==roi_list(chn));
                    ix  = indx_tot(ix,1);
                    avg = squeeze(source_avg{sb,cnd}(ix,f,t));
                    
                    Y   =   [Y; nanmean(nanmean(avg))];
                    S   =   [S;sb];
                    F1  =   [F1;cnd];
                    F2  =   [F2;1];
                    
                    jud = [Y F1];
                    
                    anovaDataTtest(chn,cnd,f,ix_t,sb) = nanmean(nanmean(avg));
                    
                end
                
                anovaDat(chn,cnd,f,ix_t) = nanmean(jud(jud(:,2)==cnd,1));
                anovaSTD(chn,cnd,f,ix_t) = nanstd(jud(jud(:,2)==cnd,1));
                anovaSEM(chn,cnd,f,ix_t) = anovaSTD(chn,cnd,f,ix_t) / sqrt(14);
                
            end
            
            res                        =   PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','Freq'});
            anovaResults(chn,f,ix_t)   =   res{2,6};
            
            clear Y
            
        end
        
    end
end

clearvars -except anova*

chn_list = {'OccL','OccR','HGL','HGR','STGL','STGR'};
frq_list = {'low','high'};
tm_list  = -0.7:0.1:1.2;
list_cnd = 'RLN';

f   = 2 ;

for chn = 3 ;
    
    for t = 15:17
        
        figure;
        
        subplot(2,2,1);
        
        errorbar(squeeze(anovaDat(chn,:,f,t)),squeeze(anovaSEM(chn,:,f,t)));
        
        set(gca,'Xtick',0:1:4)
        xlim([0 4]);
        ylim([-0.6 0.6]);
        set(gca,'Xtick',0:4,'XTickLabel', {'','RCnD','LCnD','NCnD'})
        
        title([chn_list{chn} ' , ' frq_list{f} ' , ' num2str(tm_list(t)*1000) 'ms']);
        
        cmpr_idx = [1 2; 2 3; 1 3];
        
        for ii = 1:3
            
            X = squeeze(anovaDataTtest(chn,cmpr_idx(ii,1),f,t,:));
            Y = squeeze(anovaDataTtest(chn,cmpr_idx(ii,2),f,t,:));
            
            [h,p] = ttest(X,Y,'Alpha',0.05);
            
            subplot(2,2,ii+1);
            
            boxplot([X Y],'Labels',{list_cnd(cmpr_idx(ii,1)),list_cnd(cmpr_idx(ii,2))});
            ylim([-0.6 0.6]);
            
            title(['p = ' num2str(round(p,4))]);
            
        end
        
        
    end
    
end

% lim_y1 = 0;
% lim_y2 = 0.08;
% 
% for f = 1:2
%     figure;
%     for chn = 1:6
% 
%         subplot(2,3,chn)
% 
%         tm_list = -0.7:0.1:1.2;
% 
%         plot_x = tm_list;
%         plot_y = squeeze(anovaResults(chn,f,:));
%         plot(plot_x,plot_y); ylim([lim_y1 lim_y2]); xlim([-0.7 1.2]);
% 
%         chn_list = {'OccL','OccR','HGL','HGR','STGL','STGR'};
%         frq_list = {'low','high'};
% 
%         title([chn_list{chn} ',' frq_list{f}])
%         vline(0,'--k');
%         vline(1.2,'--k');
%         hline(0.05,'-k');
% 
%     end
% end
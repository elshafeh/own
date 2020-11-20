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
        
        for t = 1:20
            
            Y   = [];  S = [];
            F1  = []; F2 = [];
            
            for cnd = 1:3
                
                for sb = 1:14
                    
                    ix  = find(indx_tot(:,2)==roi_list(chn));
                    ix  = indx_tot(ix,1);
                    avg = source_avg{sb,cnd}(ix,f,t);
                    
                    Y   =   [Y; nanmean(avg)];
                    S   =   [S;sb];
                    F1  =   [F1;cnd];
                    F2  =   [F2;1];
                    
                    jud = [Y F1];
                    
                end
                
                anovaData(chn,cnd,f,t) = nanmean(jud(jud(:,2)==cnd,1));
                
            end
            
            res                        =   PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','Freq'});
            anovaResults(chn,f,t)      =   res{2,6};
            
        end
        
    end
end

clearvars -except anovaData anovaResults

lim_y1 = -0.3;
lim_y2 = 0.7;

for f = 1:2
    
    figure;
    
    for chn = 1:6
        
        subplot(2,3,chn)
        
        tm_list = -0.7:0.1:1.2;
        
        for t = 1:size(anovaResults,3)
            
            if ~isnan(anovaResults(chn,f,t))
                if anovaResults(chn,f,t) < 0.1
                    indx_rect = tm_list(t);
                    rectangle('Position',[indx_rect lim_y1 0.1 abs(lim_y1)+abs(lim_y2)],'FaceColor',[0.7 0.7 0.7]);
                end
            end
            
            hold on;
            clrmap = 'brg';
            
            for cnd = 1:3
                plot_x = tm_list;
                plot_y = squeeze(anovaData(chn,cnd,f,:));
                plot(plot_x,plot_y,clrmap(cnd)); ylim([lim_y1 lim_y2]); xlim([-0.7 1.2]);
            end
            
            chn_list = {'OccL','OccR','HGL','HGR','STGL','STGR'};
            frq_list = {'low','high'};
            
            title([chn_list{chn} ',' frq_list{f}])
            vline(0,'--k');
            vline(1.2,'--k');
            hline(0,'-k');
            
        end
    end
end
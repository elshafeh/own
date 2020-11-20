% 3by2 ANOVA on freq (either virtual , tfresolved or freq)

clear ; clc ; close all ;

load ../data/yctot/ArsenalVirtualSmooth100ms1HzRes.mat % % load ../data/yctot/ArsenalVirtual.mat % load ../data/yctot/ArsenalTfResolved.mat

% Baseline

frq_list    = 5:15;
mini_win    = 0.2 ;
ts      = -0.6:mini_win:2;

for sb = 1:14
    
    for cnd = 1:3
        
        for chn = 1:30
            
            tmp = source_avg{sb,cnd,chn} ;
            
            t1 = find(round(ts,1) == -0.6);
            t2 = find(round(ts,1) == -0.2);
            
            bsl_prt         = repmat(mean(tmp(:,t1:t2),2),1,size(tmp,2));
            
            tmp = (tmp-bsl_prt) ./ bsl_prt;
            
            source_avg{sb,cnd,chn} = tmp;
            
        end
        
    end
    
end

clearvars -except source_avg frq_list tm_list

chn2compare=[15 16;17 18];

frq_list    = 5:15;
mini_win    = 0.2 ;
ts      = -0.6:mini_win:2;

ts = 0.5:0.1:1;

for chn = 1:3
    for f = 1:length(frq_list)
        
        for t=1:8
            
            Y =[]; F1 = [];  F2=[]; S=[];
            
            for lola = 1:2
                
                for cnd =1:3
                    
                    for sb =1:14
                        
                        t1 = find(round(ts,1)==ts(t));
                        
                        anData(sb,cnd,chn) = squeeze(nanmean(source_avg{sb,cnd,chn2compare(chn,lola)}(f,t1)));
                        
                        Y   = [Y;anData(sb,cnd,chn)];
                        F1  = [F1;cnd];
                        F2  = [F2;lola];
                        S   = [S;sb];
                        
                    end
                end
                
                chn_list = {'Occ','HG','STG'};
                
                res                        =   PrepAtt2_rm_anova(Y,S,F1,F2,{'Cue','Acx'});
                anovaResults               =   res{2,6};
                
                figure;
                
                subplot(2,3,1:3)
                boxplot(anData(:,:,chn),'labels',{'RCue','LCue','NCue'})
                title([num2str(ts(t)*1000) ' ms ' chn_list{chn} ' p = ' num2str(round(anovaResults,4))]);
                ylim([-0.6 0.3]);
                
                c_idx = [1 2;1 3; 2 3];
                cnd_i = 'RLN';
                
                for bi = 1:3
                    
                    X = anData(:,c_idx(bi,1),chn);
                    Y = anData(:,c_idx(bi,2),chn);
                    
                    [h,p] = ttest(X,Y,'Alpha',0.05);
                    
                    subplot(2,3,bi+3);
                    boxplot([X Y],'labels',{cnd_i(c_idx(bi,1)),cnd_i(c_idx(bi,2))})
                    ylim([-0.6 0.3]);
                    [h,p] = ttest(X,Y,'Alpha',0.05);
                    title(['p = ' num2str(round(p,4))]);
                    
                end
            end
        end
    end
end
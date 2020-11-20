clear;clc;dleiftrip_addpath;

close all ; 

% load ../data/yctot/ArsenalVirtualSmooth200ms1HzRes.mat
load ../data/yctot/ArsenalTfResolved.mat


frq_list    = [5 8 11 14]; % 5:1:15;
mini_win    = 0.2 ;
tm_list     = -0.6:mini_win:2;

for sb = 1:14
    
    for cnd = 1:3
        
        for chn = 1:30
            
            tmp = source_avg{sb,cnd,chn} ;
            
            t1 = find(round(tm_list,1) == -0.6);
            t2 = find(round(tm_list,1) == -0.2);
            
            bsl_prt         = repmat(mean(tmp(:,t1:t2),2),1,size(tmp,2));
            
            tmp = (tmp-bsl_prt) ./ bsl_prt;
            
            source_avg{sb,cnd,chn} = tmp;
            
            clear tmp
            
        end
        
    end
    
end

clearvars -except source_avg

min_cnd = [1 2; 1 3; 2 3];

for sb = 1:14
    
    for chn = 1:30
        
        for nw_cnd = 1:3
            
            mt1 = source_avg{sb,min_cnd(nw_cnd,1),chn};
            mt2 = source_avg{sb,min_cnd(nw_cnd,2),chn};
            
            source_avg{sb,nw_cnd+3,chn} = mt1 - mt2 ;
            
            clear mt1 mt2
            
        end
    end
end

% 4 = right minus left 5 = right minus unf 6 = left minus unf

clearvars -except source_avg

icnd = 0;
ichn = 0;

for cnd = 4:6
    
    icnd = icnd + 1;
    
    for f = 1:size(source_avg{1,1,1},1)
        
        for chn = [15 17]
            
            ichn = ichn + 1;
            figure ;
            
            for t = 1:8 % size(source_avg{1,1,1},2)
                
                for sb = 1:14
                    
                    X(sb) = source_avg{sb,cnd,chn}(f,t);    % left
                    Y(sb) = source_avg{sb,cnd,chn+1}(f,t);  % right
                    
                end
                
                %                 [h,p] = ttest(X,Y,'Alpha',0.05);
                
                p = permutation_test([X' Y'],1000);
                
                chn_list = {'HG','STG'};
                
                frq_list = [5 8 11 14] ;% 5:15;
                
                cnd_list = {'RmL','RmU','LmU'};
                
                tm_list  = -0.6:0.2:2;
                
                if p < 0.05
                    
                    subplot(4,2,t);
                    boxplot([X' Y'],'Labels',{'L','R'});
                    ylim([-1 1]);
                    
                    title([cnd_list{icnd} ' ' chn_list{ichn} ' ' num2str(frq_list(f)) 'Hz' num2str(round(tm_list(t),2)*1000) ' ' num2str(round(p,4))])
                    
                end
                
            end
            
            saveFigure(gcf,['../plots/virtual_minus_stat/' cnd_list{icnd} ' ' chn_list{ichn} ' ' num2str(frq_list(f)) 'Hz.png']);
            close all;
            
        end
        
        ichn = 0;
        
    end
end

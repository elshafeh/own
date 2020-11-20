clear;clc;dleiftrip_addpath;

close all ; 

load ../data/yctot/ArsenalVirtualSmooth200ms1HzRes.mat

% create minus

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
            
            new_avg(sb,cnd,chn,:,:) = tmp;
            
            clear tmp
            
        end
        
    end
    
end

source_avg = new_avg ;

for hop = 1:2
   
    new(:,1,:,:,:) = source_avg(:,1,:,:,:) - source_avg(:,3,:,:,:);
    new(:,2,:,:,:) = source_avg(:,2,:,:,:) - source_avg(:,3,:,:,:);
    
end

source_avg = new;

clearvars -except source_avg

frq_list    = 5:1:15;
mini_win    = 0.2 ;
tm_list     = -0.6:mini_win:2;

load ../data/yctot/postConnExtWav.mat; clear allsuj note ;

for chn = 18
    
    for f = 6:length(frq_list)
        
        for t = 1:8
            
            X = source_avg(:,1,chn,f,t);
            Y = source_avg(:,2,chn,f,t);
            
            p = permutation_test([X Y],1000);
            
            if p < 0.05 && t < 9
                
                figure;
                
                plot_x = tm_list;
                plot_y = [squeeze(mean(source_avg(:,1,chn,f,:),1)) squeeze(mean(source_avg(:,2,chn,f,:),1))];
                
                fprintf('%10d\n',p);
                
                hold on
                
                rectangle('Position',[tm_list(t) -0.2  0.2 abs(-0.2)+abs(0.2)],'FaceColor',[0.7 0.7 0.7]);
                plot(plot_x,plot_y);
                legend({'Rmu','Lmu'});
                ylim([-0.2 0.2]);
                xlim([-0.6 2]);
                title([template.label{chn} ' ' num2str(frq_list(f)) 'Hz'])
                vline(0,'--k');
                vline(1.2,'--k');
                hline(0,'-k');
                
            end
            
        end
    end
end
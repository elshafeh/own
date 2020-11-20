clear;clc;dleiftrip_addpath;

close all ; 

load ../data/yctot/index/finalArsenalIndex.mat ; clearvars -except arsenal_list
% load ../data/yctot/ArsenalVirtualSmooth200ms1HzRes.mat
load ../data/yctot/ArsenalTfResolved.mat

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
            
            new_source_avg(sb,cnd,chn,:,:) = tmp;
            
            clear tmp
            
        end
        
    end
    
end

source_avg = new_source_avg;

clearvars -except source_avg arsenal_list

frq_list = [5 8 11 14]; % 5:15;
tm_list  = -0.6:0.2:2;

ix_cnd1 = 1;
ix_cnd2 = 3;

chn1 = 'hgL';
chn2 = 'hgR';

ix_chn1 = find(strcmp(arsenal_list,chn1));
ix_chn2 = find(strcmp(arsenal_list,chn2));

cnd_list = {'RCue','LCue','NCue'};

frq = 11 ; f   = find(frq_list==frq);

a = squeeze(mean(source_avg(:,ix_cnd1,ix_chn1,f,:),1))';
b = squeeze(mean(source_avg(:,ix_cnd1,ix_chn2,f,:),1))';
c = squeeze(mean(source_avg(:,ix_cnd2,ix_chn1,f,:),1))';
d = squeeze(mean(source_avg(:,ix_cnd2,ix_chn2,f,:),1))';

tm = 0.4; tm_win = 0.4;

hold on

rectangle('Position',[tm -0.4  tm_win abs(-0.4)+abs(0.4)],'FaceColor',[0.7 0.7 0.7]);

plot(tm_list,[a;b;c;d])
legend({[cnd_list{ix_cnd1} ' ' chn1],[cnd_list{ix_cnd1} ' ' chn2],[cnd_list{ix_cnd2} ' ' chn1],[cnd_list{ix_cnd2} ' ' chn2]})
ylim([-0.4 0.4]);xlim([-0.2 1.3]);
vline(0,'--');
vline(1.2,'--');
hline(0,'--');

% min_cnd = [1 2; 1 3; 2 3];
% 
% 
% for sb = 1:14
%     
%     for chn = 1:30
%         
%         for nw_cnd = 1:3
%             
%             mt1 = source_avg{sb,min_cnd(nw_cnd,1),chn};
%             mt2 = source_avg{sb,min_cnd(nw_cnd,2),chn};
%             
%             source_avg{sb,nw_cnd+3,chn} = mt1 - mt2 ;
%             
%             clear mt1 mt2
%             
%         end
%     end
% end

% 4 = right minus left 5 = right minus unf 6 = left minus unf

% clearvars -except source_avg

% X = [];
% Y = [];
% 
% for sb = 1:14
%     
%     X = [X ;source_avg{sb,cnd,chn}(f,:)];
%     Y = [Y ;source_avg{sb,cnd,chn+1}(f,:)];
%     
% end
% 
% X = mean(X,1) ; Y = mean(Y,1) ;
% 
% to_plot = [X;Y];
% 
% chn_list = {'maxH','maxST','HG','STG'};
% 
% cnd_list = {'','','','RmL','RmU','LmU'};
% 
% 
% figure;
% plot(tm_list,to_plot);legend({'L ACx','R Acx'});
% ylim([-0.6 0.6]);xlim([-0.6 1.3]);
% 
% vline(0,'--');
% vline(1.2,'--');
% hline(0,'--');
% 
% title([cnd_list{cnd} ' ' chn_list{chn} ' ' num2str(frq_list(f)) 'Hz']);
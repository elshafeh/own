clear ; clc ; close ; dleiftrip_addpath ;

load ../data/yctot/postConn&MotorExtWav.mat

% smooth

for sb = 1:size(allsuj,1)
    
    frq_list    = [6 9 12 15];
    mini_win    = 0.2 ;
    ts          = -0.6:mini_win:2;
    
    for cnd = 1:size(allsuj,2)
        
        for chn = 1:length(template.label)
            
            for t = 1:length(ts)
                
                tlm1 = find(round(template.time,2) == round(ts(t),2));
                tlm2 = find(round(template.time,2) == round(ts(t)+mini_win,2));
                
                for f = 1:length(frq_list)
                    
                    tap = 1 ;
                    
                    tf1 = find(round(template.freq) == frq_list(f)-tap);
                    tf2 = find(round(template.freq) == frq_list(f)+tap);
                    
                    source_avg(sb,cnd,chn,f,t) = squeeze(nanmean(nanmean(allsuj{sb,cnd}(chn,tf1:tf2,tlm1:tlm2))));
                    
                end
                
            end
            
        end
        
    end
    
end

clearvars -except source_avg

% for sb = 1:size(source_avg,1)
%     for chn = 1:size(source_avg,3)
%         
%         tmp{sb,1,chn} = source_avg{sb,3,chn};
%         tmp{sb,2,chn} = source_avg{sb,2,chn};
%         tmp{sb,3,chn} = source_avg{sb,1,chn};
%         tmp{sb,4,chn} = source_avg{sb,4,chn};
%         tmp{sb,5,chn} = source_avg{sb,5,chn};
%     end
% end
% 
% source_avg = tmp ; clearvars -except source_avg

save('../data/yctot/Virtual4Anova.mat');
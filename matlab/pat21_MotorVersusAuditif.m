clear ; clc ; close all ;

load('../data/yctot/ArsenalVirtualSmooth200ms1HzRes.mat');

for sb = 1:14
    
    for chn = 3:6
       
        new{sb,chn-2} = source_avg{sb,5,chn};
        
    end
    
end

clearvars -except new

load ../data/yctot/ArsenalMotorSmooth200ms1HzRes.mat

for sb = 1:14
    
    for chn = 1:4
        
        new{sb,chn+4} = source_avg{sb,5,chn};
        
    end
    
end

clearvars -except new

for sb = 1:14
    
    source_avg{sb,1} = new{sb,1};
    source_avg{sb,2} = new{sb,3};
    source_avg{sb,3} = new{sb,5};
    source_avg{sb,4} = new{sb,7};
    source_avg{sb,5} = new{sb,2};
    source_avg{sb,6} = new{sb,4};
    source_avg{sb,7} = new{sb,6};
    source_avg{sb,8} = new{sb,8};
    
end

clearvars -except source_avg

mini_win    = 0.2 ;
tm_list     = -0.6:mini_win:2;

for sb = 1:14
    for chn = 1:8
        
        tmp = source_avg{sb,chn} ;
        
        t1 = find(round(tm_list,1) == -0.6);
        t2 = find(round(tm_list,1) == -0.2);
        
        bsl_prt         = repmat(mean(tmp(:,t1:t2),2),1,size(tmp,2));
        
        tmp = (tmp-bsl_prt) ./ bsl_prt;
        
        new(sb,chn,:,:) = tmp;
        
    end
end

source_avg = new ; clearvars -except source_avg

% tmp = squeeze(mean(source_avg,1));

tm_list     = -0.6:0.2:2;
frq_list    = 5:15;

% source_avg = [];
% 
% source_avg.powspctrm    = tmp ;
% source_avg.time         = tm_list ;
% source_avg.freq         = frq_list ;
% source_avg.label        = {'maxHL','maxSTL','PreCenL','SuMoL','maxHR','maxSTR','PreCenR','SuMoR'};
% source_avg.dimord       = 'chan_freq_time';
% 
% clearvars -except source_avg
% 
% figure ;
% 
% for chn = 1:4
% 
%     cfg = [];
%     cfg.channel = chn; 
%     cfg.xlim = [-0.2 1.2];
%     cfg.ylim = [7 15];
%     cfg.zlim = [-0.2 0.2];
%     subplot(4,1,chn);
%     ft_singleplotTFR(cfg,source_avg);
%     
%     
% end
% 
% 
% figure ;
% 
% for chn = 5:8
% 
%     cfg = [];
%     cfg.channel = chn; 
%     cfg.xlim = [-0.2 1.2];
%     cfg.ylim = [7 15];
%     cfg.zlim = [-0.2 0.2];
%     subplot(4,1,chn-4);
%     ft_singleplotTFR(cfg,source_avg);
%     
%     
% end

ii = 1:2:30;
iy = 2:2:30;

for f = 1:5
    
    chn_labels = {'maxHL','maxSTL','PreCenL','SuMoL','maxHR','maxSTR','PreCenR','SuMoR'};
    
    subplot(5,2,ii(f))
    
    a = squeeze(mean(source_avg(:,1,f,:,1)));
    b = squeeze(mean(source_avg(:,2,f,:,1)));
    c = squeeze(mean(source_avg(:,3,f,:,1)));
    d = squeeze(mean(source_avg(:,4,f,:,1)));
    
    plot(tm_list,[a b c d])
    legend(chn_labels{1:4});
    xlim([-0.2 2])
    ylim([-0.3 0.3])
    title([num2str(frq_list(f)) 'Hz']);
    
    subplot(5,2,iy(f))
    
    a = squeeze(mean(source_avg(:,5,f,:,1)));
    b = squeeze(mean(source_avg(:,6,f,:,1)));
    c = squeeze(mean(source_avg(:,7,f,:,1)));
    d = squeeze(mean(source_avg(:,8,f,:,1)));
    
    plot(tm_list,[a b c d])
    legend(chn_labels{5:8});
    xlim([-0.2 2])
    ylim([-0.3 0.3])
    title([num2str(frq_list(f)) 'Hz']);
    
end
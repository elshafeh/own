close all;
clear ; clc ; dleiftrip_addpath;

load ../data/yctot/RevComeOnExtWav.mat

for cnd = 1:5
    
    for sb = 1:14
        
        cfg = [];
        cfg.baseline                = [-0.6 -0.2];
        cfg.baselinetype            = 'relchange';
        allsuj{sb,cnd}              = ft_freqbaseline(cfg,allsuj{sb,cnd}); clc ;
        
    end
    
    freqGA{cnd} = ft_freqgrandaverage([],allsuj{:,cnd});
    
end

clear allsuj

for cnd = 1:5
   
    figure;
    
    for chn = 1:6
        
        cfg = [];
        cfg.xlim = [-0.5 2];
        cfg.ylim = [7 15];
        cfg.zlim = [-0.15 0.15];
        cfg.channel = chn;
        cfg.colorbar = 'no';
        subplot(3,2,chn)
        ft_singleplotTFR(cfg,freqGA{cnd});
        vline(0,'--k','')
        vline(1.2,'--k','')
        
    end
    
end

% for a = 1:length(freqBsl{1,1}.label)
%     
%     figure;
%     
%     for b = 1:2
%         
%         cfg = [];
%         cfg.xlim = [-0.6 2];
%         cfg.ylim = [-0.5 0.5];
%         cfg.channel = a;
%         cfg.graphcolor    = 'brk';
%         subplot(1,2,b)
%         
%         ft_singleplotER(cfg,freqSlct{:,b});
%         vline(1.2,'--k','Target Onset');
%         hline(0,'--k','');
%         
%     end
%     
% end

% for a = 1:length(freqBsl{1,1}.label)
%     
%     figure;
%     cfg.xlim = [-0.5 2];
%     cfg.ylim = [7 15];
%     cfg.zlim = [-0.1 0.1];
%     cfg.channel = a;
%     cfg.colorbar = 'no';
%     
%     ft_singleplotTFR(cfg,freqBslCnD)
%     vline(0,'--k','')
%     vline(1.2,'--k','')
% end

% t2xcel = zeros(52,4);
% t2xcel(2:52,1) = freqSlct{1,1}.time(51:101);

% for a = 30
%     
%     for b = 1
%         
%         for c = 1:3
%             
%             t2xcel(2:end,c+1) = freqSlct{c,b}.avg(a,51:101);
%             
%         end
%         
%     end
%     
%     
% end

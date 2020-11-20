clear ; clc ; dleiftrip_addpath ;

load ../data/yctot/gavg/VN.CnD.eeg.pe.mat

for sb = 1:14
    for cnd = 1:2
        tmp_allsuj{sb,cnd,1} = allsuj{sb,cnd};
    end
end

clearvars -except tmp_allsuj ; 

load ../data/yctot/gavg/LRN.CnD.pe.mat

for sb = 1:size(allsuj,1)
    
    tmp{2} = allsuj{sb,1};
    tmp{1} = ft_timelockgrandaverage([],allsuj{sb,2},allsuj{sb,3});
    
    for cnd = 1:2
        tmp_allsuj{sb,cnd,2} = tmp{cnd};
    end
    
    clear tmp
    
end

clearvars -except tmp_allsuj ;

allsuj = tmp_allsuj ; clear tmp_allsuj;

for c_cue = 1:2
    for c_data = 1:2
        
        gavg{c_cue,c_data}    = ft_timelockgrandaverage([],allsuj{:,c_cue,c_data});
        cfg                   = [];
        cfg.baseline          = [-0.2 -0.1];
        gavg_bs{c_cue,c_data} = ft_timelockbaseline(cfg,gavg{c_cue,c_data});
        
    end
end

clearvars -except gavg*

for c_cue = 1:2

    cfg                 = [];
    cfg.channel         = {'F3', 'F1', 'Fz', 'F2', 'FC3', 'FC1', 'FCz', 'FC2', 'C3', 'C1', 'Cz', 'C2'};
    cfg.avgoverchan     = 'yes';
    dslct{c_cue}        = ft_selectdata(cfg,gavg_bs{c_cue,1});

end

% % cfg = [];
% % cfg.parameter = 'avg';
% % cfg.operation = 'subtract';
% % gavg_bs{3,1} = ft_math(cfg,gavg_bs{1,1},gavg_bs{2,1});
% % 
% for c_cue = 2
%     cfg                     = [];
%     cfg.layout              = 'elan_lay.mat';
%     cfg.xlim                = [0.7 1.1];
%     cfg.zlim                = [-3 3];
%     cfg.comment             = 'no';
%     cfg.highlightchannel    = {'F3', 'F1', 'Fz', 'F2', 'FC3', 'FC1', 'FCz', 'FC2', 'C3', 'C1', 'Cz', 'C2'};
%     cfg.highlight           = 'on';
%     cfg.highlightsymbol     = '.';
%     cfg.highlightcolor      = [1 0 0];
%     cfg.highlightsize       = 15;
%     figure;
%     ft_topoplotER(cfg,gavg_bs{c_cue,1})
% end
% 
figure;
hold on ;
plot(dslct{1}.time,dslct{1}.avg,'b','LineWidth',5) ; xlim([-0.1 1.4]) ;ylim([-15 15]);
plot(dslct{2}.time,dslct{2}.avg,'r','LineWidth',5) ; xlim([-0.1 1.4]) ;ylim([-15 15]);
vline(0,'--k')
vline(1.2,'--k')
set(gca,'XAxisLocation','origin')
set(gca,'fontsize',18)
set(gca,'FontWeight','bold')
% legend({'INF','UNF'});
% 
load ../data/yctot/gavg/eeg_timelock.mat

for sb = 1:14
    tmp_allsuj{sb,1} = avg{sb};
end

clearvars -except tmp_allsuj ;

load ../data/yctot/gavg/LRN.CnD.pe.mat

for sb = 1:14
    tmp_allsuj{sb,2} = ft_timelockgrandaverage([],allsuj{sb,:});
end

clearvars -except tmp_allsuj ; allsuj = tmp_allsuj ; clear tmp_allsuj;

for c_data = 1:2
    
    gavg{c_data}            = ft_timelockgrandaverage([],allsuj{:,c_data});
    cfg                     = [];
    cfg.baseline            = [-0.2 -0.1];
    cfg.highlightchannel    = {'F3', 'F1', 'Fz', 'F2', 'FC3', 'FC1', 'FCz', 'FC2', 'C3', 'C1', 'Cz', 'C2'};
    gavg_bs{c_data}         = ft_timelockbaseline(cfg,gavg{c_data});
    
end

% % % close all;
% % % 
% % % t_list = 0.6:0.1:1;
% % % i      = 0;
% % % for t = 1:length(t_list)
% % %     i =i +1;
% % %     cfg         = [];
% % %     cfg.layout  = 'elan_lay.mat';
% % %     cfg.xlim    = [t_list(t) t_list(t)+0.1];
% % %     cfg.zlim    = [-3 3];
% % %     cfg.comment = 'no';
% % %     subplot(2,5,i)
% % %     ft_topoplotER(cfg,gavg_bs{1})
% % % end
% % % for t = 1:length(t_list)
% % %     i =i +1;
% % %     cfg         = [];
% % %     cfg.layout  = 'CTF275.lay';
% % %     cfg.xlim    = [t_list(t) t_list(t)+0.1];
% % %     cfg.comment = 'no';
% % %     cfg.zlim    = [-30 30];
% % %     subplot(2,5,i)
% % %     ft_topoplotER(cfg,gavg_bs{2})
% % % end
% % % 
% % % close all;
% % % 
% % % cfg                     = [];
% % % cfg.layout              = 'elan_lay.mat';
% % % cfg.xlim                = [0.7 1.1];
% % % cfg.zlim                = [-3 3];
% % % cfg.comment             = 'no';
% % % cfg.highlightchannel    = {'F3', 'F1', 'Fz', 'F2', 'FC3', 'FC1', 'FCz', 'FC2', 'C3', 'C1', 'Cz', 'C2'};
% % % cfg.highlight           = 'on';
% % % cfg.highlightsymbol     = '.';
% % % cfg.highlightcolor      = [1 0 0];
% % % cfg.highlightsize       = 15;
% % % subplot(1,2,1)
% % % ft_topoplotER(cfg,gavg_bs{1})
% % % cfg                     = [];
% % % cfg.layout              = 'CTF275.lay';
% % % cfg.xlim                = [0.7 1.1];
% % % cfg.comment             = 'no';
% % % cfg.zlim                = [-30 30];
% % % cfg.highlightchannel    = {'MLC17', 'MLC25', 'MLC32', 'MLF67', 'MLO13', 'MLO14', 'MLO24', 'MLP23', 'MLP34', ...
% % %     'MLP35', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT14', 'MLT15', 'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT37' ...
% % %     'MRC16', 'MRC17', 'MRF56', 'MRF66', 'MRF67', 'MRP56', 'MRP57', 'MRT12', 'MRT13', 'MRT14', ... 
% % %     'MRT15', 'MRT22', 'MRT23', 'MRT24', 'MRT33', 'MRT34'};
% % % cfg.highlight           = 'on';
% % % cfg.highlightsymbol     = '.';
% % % cfg.highlightcolor      = [1 0 0];
% % % cfg.highlightsize       = 15;
% % % subplot(1,2,2)
% % % ft_topoplotER(cfg,gavg_bs{2})
% % % 
% % % 
% close all;

% cfg             = [];
% cfg.avgoverchan = 'yes';
% cfg.channel     = {'F3', 'F1', 'Fz', 'F2', 'FC3', 'FC1', 'FCz', 'FC2', 'C3', 'C1', 'Cz', 'C2'};
% eeg_gp = ft_selectdata(cfg,gavg_bs{1});
% 
% % cfg.channel = {'MLC17', 'MLC25', 'MLC32', 'MLF67', 'MLO13', 'MLO14', 'MLO24', 'MLP23', 'MLP34', ...
% %     'MLP35', 'MLP42', 'MLP43', 'MLP44', 'MLP45', 'MLP53', 'MLP54', 'MLP55', 'MLP56', 'MLP57', 'MLT14', 'MLT15', 'MLT16', 'MLT25', 'MLT26', 'MLT27', 'MLT37'};
% % meg_lft = ft_selectdata(cfg,gavg_bs{2});
% % cfg.channel = {'MRC16', 'MRC17', 'MRF56', 'MRF66', 'MRF67', 'MRP56', 'MRP57', 'MRT12', 'MRT13', 'MRT14', ...
% %     'MRT15', 'MRT22', 'MRT23', 'MRT24', 'MRT33', 'MRT34'};
% % meg_rght = ft_selectdata(cfg,gavg_bs{2});
% 
% figure; 
% plot(eeg_gp.time,eeg_gp.avg,'k','LineWidth',6) ; xlim([-0.1 1.4]) ;ylim([-15 15]);
% vline(0,'--k')
% vline(1.2,'--k')
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')
% % saveFigure(gcf,'../../../../Desktop/CNV_eeg.png');
% % close all;
% % figure; 
% % plot(eeg_gp.time,meg_lft.avg,'k','LineWidth',6) ; xlim([-0.1 1.4]) ; ylim([-120 120]);
% % vline(0,'--k')
% % vline(1.2,'--k')
% % set(gca,'XAxisLocation','origin')
% % set(gca,'fontsize',18)
% % set(gca,'FontWeight','bold')
% % saveFigure(gcf,'../../../../Desktop/CNV_megL.png');
% % close all;
% % figure; 
% % plot(eeg_gp.time,meg_rght.avg,'k','LineWidth',6) ; xlim([-0.1 1.4]); ylim([-120 120]);
% % vline(0,'--k')
% % vline(1.2,'--k')
% % set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',18)
% set(gca,'FontWeight','bold')
% saveFigure(gcf,'../../../../Desktop/CNV_megR.png');
% close all;
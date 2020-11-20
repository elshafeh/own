clear; clc ; dleiftrip_addpath ; close all ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'R','L'};
    
    for cnd = 1:length(cnd_list)
        
        ext1    =   cnd_list{cnd};
        ext2    =   'nDT';
        ext3    =   '';
        
        fname_in = ['../data/tfr/' suj '.'  ext1 ext2 ext3  '.all.wav.1t90Hz.m1500p1500.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        
        cfg                 = [];
        cfg.baseline        = [-0.4 -0.2];
        cfg.baselinetype    = 'relchange';
        allsuj{sb,cnd}      = ft_freqbaseline(cfg,freq);
        
        %         powHL  = gavgplot(sb,cnd,1);
        %         powHR  = gavgplot(sb,cnd,2);
        %         powSTL = gavgplot(sb,cnd,3);
        %         powSTR = gavgplot(sb,cnd,4);
        %         latind(sb,cnd,1) = (powHR-powHL) / (mean([powHR powHL]));
        %         latind(sb,cnd,2) = (powSTR-powSTL) / (mean([powSTR powSTL]));
        %         clear pow*
        
    end
end

for i = 1:size(allsuj,2)
    gavg{i}         = ft_freqgrandaverage([],allsuj{:,i});
end

clearvars -except gavg* cnd_list latind

gavgplot = [];

for ii = 1:length(cnd_list)
    cfg                 =   [];
    cfg.frequency       =   [7 15];
    cfg.avgoverfreq     =   'yes';
    tmp                 =   ft_selectdata(cfg,gavg{ii});
    gavgplot(ii,:,:)    =   squeeze(tmp.powspctrm);
    clear tmp
end

x = 0 ;
for i = 1:4
    x = x +1;
    subplot(2,2,x)
    hold on
    plot(gavg{1}.time,squeeze(gavgplot(:,i,:)),'LineWidth',2);
    xlim([-0.2 0.7]);
%     ylim([-0.1 0.1]);
    legend(cnd_list);
    title(gavg{1}.label{i});
    vline(0,'--k');
    hline(0,'--k');
end

% figure;
% boxplot(squeeze(latind(:,:,1)),'labels',cnd_list);ylim([-6 6])
% figure;
% boxplot(squeeze(latind(:,:,2)),'labels',cnd_list);ylim([-6 6])

% cfg                     =   [];
% cfg.frequency           =   [8 11];
% cfg.avgoverfreq         =   'yes';
% cfg.latency             =   [0.2 0.6];
% cfg.avgovertime         =   'yes';
% tmp                     =   ft_selectdata(cfg,allsuj{sb,cnd});
% gavgplot(sb,cnd,:)      =   squeeze(tmp.powspctrm);

% x = 0 ;
% for ii = 1:length(cnd_list)
%     for i = [1 3 2 4]
%         x = x + 1;
%         subplot(length(cnd_list),4,x)
%         cfg         = [];
%         cfg.xlim    = [-0.2 0.6];
%         cfg.ylim    = [30 90];
%         cfg.channel = i;
%         cfg.zlim    = [-0.07 0.07];
%         cfg.colorbar = 'no';
%         ft_singleplotTFR(cfg,gavg{ii});
%         title([cnd_list{ii} 'nDT : ' gavg{ii}.label{i}])
%         vline(0,'--k');
%     end
%     clear i cfg
% end
% 
% % figure;
% % x = 0 ;
% % for ii = 1:length(cnd_list)
% %     for i = [1 3 2 4]
% %         x = x + 1;
% %         subplot(length(cnd_list),4,x)
% %         cfg         = [];
% %         cfg.xlim    = [-0.2 0.6];
% %         cfg.ylim    = [5 15];
% %         cfg.channel = i;
% %         cfg.zlim    = [-0.3 0.3];
% %         cfg.colorbar = 'no';
% %         ft_singleplotTFR(cfg,gavg{ii});
% %         title([cnd_list{ii} 'nDT : ' gavg{ii}.label{i}])
% %         vline(0,'--k');
% %     end
% %     clear i cfg
% % end
% 
% % % gavgplot = [];
% % % 
% % % for ii = 1:length(cnd_list)
% % %     cfg                 =   [];
% % %     cfg.frequency       =   [8 11];
% % %     cfg.avgoverfreq     =   'yes';
% % %     cfg.latency         =   [0.2 0.6];
% % %     cfg.avgovertime     =   'yes';
% % %     tmp                 =   ft_selectdata(cfg,gavg{ii});
% % %     gavgplot(ii,:)      =   squeeze(tmp.powspctrm);
% % %     clear tmp
% % % end
% % 
% % % for ii = 1:length(cnd_list)
% % %     latindx(ii,1)
% % %     
% % % end
% % 
% % 
% % 
% % % % for i = 1:length(gavg{1}.label)
% % % %     subplot(2,1,i)
% % % %     hold on
% % % %         end
% % % % cfg             = [];
% % % % cfg.xlim        = [-0.2 1];
% % % % cfg.ylim        = [5 15];
% % % % cfg.zlim        = [-0.3 0.7];
% % % % cfg.channel     = i;
% % % % ft_singleplotTFR(cfg,gavg{1});
% % % % for i = 1:length(gavg{1}.label)   
% % % %     subplot(1,2,i)
% % % %     hold on
% % % %     for cnd = 1:length(gavg)
% % % %         plot(gavg_slct{cnd}.time,squeeze(gavg_slct{cnd}.powspctrm(i,:,:)))
% % % %         xlim([-0.4 1.4]);
% % % %         ylim([-0.6 0.6])
% % % %         hline(0,'-k')
% % % %         vline(0,'-k')
% % % %     end
% % % %     legend({'1','2','3'})  
% % % % end
% % % % 
% % % % cfg                 = [];
% % % cfg.baseline        = [-0.4 -0.2];
% % % cfg.baselinetype    = 'relchange';
% % % for i = 1:length(gavg{1}.label)
% % %     subplot(2,1,i)
% % %     cfg         = [];
% % %     cfg.xlim    = [-0.2 1];
% % %     cfg.ylim    = [5 15];
% % %     cfg.channel = i;
% % % %             cfg.zlim    = [min(min(min(gavg{1}.powspctrm))) max(max(max(gavg{1}.powspctrm)))];
% % % %     ft_singleplotTFR(cfg,gavg{1});
% % % %     vline(0,'--k');
% % % % end
% % 
% % cfg             = [];
% % cfg.frequency   = [7 15];
% % cfg.avgoverfreq = 'yes';
% % gavg_slct{i}    = ft_selectdata(cfg,gavg{i});
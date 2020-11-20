clear; clc ; dleiftrip_addpath ; close all ;

for sb = 1:14
    
    suj_list = [1:4 8:17];
    suj = ['yc' num2str(suj_list(sb))];
    
    cnd_list = {'1','2','3'};
    
    for cnd = 1:length(cnd_list)
        
        ext3    =   cnd_list{cnd};
        ext2    =   'DIS';
        ext1    =   '';
        
        fname_in = ['../data/tfr/' suj '.'  ext1 ext2 ext3  '.all.wav.1t90Hz.m1500p1500.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        tmp{1}      = freq ; clear freq ;
        
        ext2        =   'fDIS';
        fname_in = ['../data/tfr/' suj '.'  ext1 ext2 ext3  '.all.wav.1t90Hz.m1500p1500.mat'];
        fprintf('\nLoading %50s \n',fname_in);
        load(fname_in)
        tmp{2}      = freq ; clear freq ;
        
        for n =1:2
            cfg                 = [];
            cfg.baseline        = [-0.2 -0.1];
            cfg.baselinetype    = 'relchange';
            tmp{n}              = ft_freqbaseline(cfg,tmp{n});
        end
        
        cfg                 = [];
        cfg.parameter       = 'powspctrm';
        cfg.operation       = '(x1-x2)';
        allsuj{sb,cnd}      = ft_math(cfg,tmp{1},tmp{2});
        
        %         cfg                 = [];
        %         cfg.baseline        = [-0.4 -0.2];
        %         cfg.baselinetype    = 'relative';
        %         allsuj{sb,cnd}      = ft_freqbaseline(cfg,allsuj{sb,cnd});
        
    end
end

for i = 1:size(allsuj,2)
    gavg{i}         = ft_freqgrandaverage([],allsuj{:,i});
end

clearvars -except gavg* cnd_list latind

gavgplot = [];

for ii = 1:length(cnd_list)
    cfg                 =   [];
    cfg.frequency       =   [6 9];
    cfg.avgoverfreq     =   'yes';
    tmp                 =   ft_selectdata(cfg,gavg{ii});
    gavgplot(ii,:,:)    =   squeeze(tmp.powspctrm);
    clear tmp
end

x = 0 ;
for i = [2 4]
    x = x +1;
    subplot(1,2,x)
    hold on
    plot(gavg{1}.time,squeeze(gavgplot(:,i,:)),'LineWidth',2);
    xlim([-0.4 1.2]);
    ylim([-0.6 0.6]);
    legend(cnd_list);
    title(gavg{1}.label{i});
    vline(0,'--k');
    hline(0,'--k');
end

% x = 0 ;
% for ii = 1:length(cnd_list)
%     for i = 1:2
%         x = x + 1;
%         subplot(length(cnd_list),2,x)
%         cfg         = [];
%         cfg.xlim    = [-0.2 0.7];
%         cfg.ylim    = [30 90];
%         cfg.channel = i;
%         cfg.zlim    = [-0.15 0.15];
%         cfg.colorbar = 'no';
%         ft_singleplotTFR(cfg,gavg{ii});
%         title([cnd_list{ii} 'DIS : ' gavg{ii}.label{i}])
%         vline(0,'--k');
%     end
%     clear i cfg
% end

% figure;
% x = 0 ;
% for ii = 1:length(cnd_list)
%     for i = 1:2
%         x = x + 1;
%         subplot(length(cnd_list),2,x)
%         cfg         = [];
%         cfg.xlim    = [-0.2 0.7];
%         cfg.ylim    = [5 15];
%         cfg.channel = i;
%         cfg.zlim    = [-0.3 0.3];
%         cfg.colorbar = 'no';
%         ft_singleplotTFR(cfg,gavg{ii});
%         title([cnd_list{ii} 'DIS : ' gavg{ii}.label{i}])
%         vline(0,'--k');
%     end
%     clear i cfg
% end
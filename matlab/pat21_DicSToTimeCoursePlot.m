clear ; clc ; dleiftrip_addpath ; close all ;

suj_list = [1:4 8:17];

pices    = {'p100p600'};
pci_bsl  = 'm700m200';
pci_frq  = '3t7Hz';

for t = 1:length(pices)
    cnd_time{t,1}   = pci_bsl;
    cnd_time{t,2}   = pices{t};
    cnd_freq{t}     = pci_frq;
end

for sb = 1:length(suj_list)
    
    suj = ['yc' num2str(suj_list(sb))];
    
    for ntest = 1:length(cnd_freq)
        for ix = 1:2
            for cp = 1:3
                
                fname = dir(['../data/source/' suj '.pt' num2str(cp) '.CnD.' cnd_time{ntest,ix} '.' cnd_freq{ntest} '.MinEvokedHanningSource.mat']);
                
                if size(fname,1)==1
                    fname = fname.name;
                end
                
                fprintf('Loading %50s\n',fname);
                load(['../data/source/' fname]);
                
                if isstruct(source);
                    source = source.avg.pow;
                end
                
                src_carr{cp} = source ; clear source ;
                
            end
            
            source_avg(sb,ntest,ix,:)  = mean([src_carr{1} src_carr{2} src_carr{3}],2);
            
            clear src_carr
            
        end
    end
end

clearvars -except source_avg pices; clc ;

source_avg  = squeeze(nanmean(source_avg,1));
bsl         = squeeze(source_avg(1,:))';
actv        = squeeze(source_avg(2,:))';

load ../data/template/source_struct_template_MNIpos.mat; template_source = source ; clear source ;

source.pow      = (actv-bsl)./bsl;
source.pos      = template_source.pos;
source.dim      = template_source.dim;

for iside = 1:3
    lst_side = {'left','right','both'}; 
    lst_view = [-95 1;95,11;0 50];
    
    cfg                     =   [];
    cfg.method              =   'surface'; cfg.funparameter        =   'pow';
%     cfg.funcolorlim         =   [-3 3];
%     cfg.opacitylim          =   [-3 3];
    cfg.opacitymap          =   'rampup';
    cfg.colorbar            =   'off'; cfg.camlight            =   'no';
    cfg.projthresh          =   0.2;
    cfg.projmethod          =   'nearest';
    cfg.surffile            =   ['surface_white_' lst_side{iside} '.mat']; 
    cfg.surfinflated        =   ['surface_inflated_' lst_side{iside} '_caret.mat'];
    ft_sourceplot(cfg, source); view(lst_view(iside,1),lst_view(iside,2))
end


% load('../data/yctot/index/NewSourceAudVisMotor.mat')

% tmp         = indx_arsenal(indx_arsenal(:,2) > 2 & indx_arsenal(:,2) < 7,:);
% tmp(:,2)    = tmp(:,2)*10;
% tmpmtp      = list_arsenal(3:6);
% clear *arsenal*
% 
% load('../data/yctot/index/Frontal.mat')
% 
% indx_arsenal    = indx_arsenal(indx_arsenal(:,2) == 12 | indx_arsenal(:,2) == 16 ...
%     | indx_arsenal(:,2) == 6 | indx_arsenal(:,2) == 9,:);
% 
% list_arsenal    = list_arsenal([6 9 12 16]);
% 
% list_arsenal    = [list_arsenal tmpmtp];
% indx_arsenal    = [indx_arsenal;tmp];
% 
% roi_list        = unique(indx_arsenal(:,2));
% 
% for l = 1:length(roi_list)
%     avg(l,:) = nanmedian(source(indx_arsenal(indx_arsenal(:,2)==roi_list(l),1),:),1);
% end
% 
% % figure;
% % for l = 1:length(list_arsenal)
% %     subplot(5,6,l)
% %     plot(-0.1:0.1:1,avg(l,:))
% %     title(list_arsenal{l});
% %     xlim([-0.1 1]);
% %     ylim([-0.1 0.1])
% % end
% 
% plot(-0.1:0.1:1,avg,'LineWidth',4);
% xlim([-0.1 1]);
% % ylim([0 0.1]);
% legend(list_arsenal)
% vline(0,'--k')
% set(gca,'XAxisLocation','origin')
% set(gca,'fontsize',12)
% set(gca,'FontWeight','bold')
% 
% % hold on;
% % Fs = 600; dt = 1/Fs;
% % StopTime = 1.1;t = (-0.1:dt:StopTime-dt)';
% % Fc = 5;x = cos(2*pi*Fc*t);
% % plot(t,x/10);
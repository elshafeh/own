% posthoc_list_tim = [0.8 0.8 0.6 0.7 0.4];
% poshtoc_list_chn = {'maxHR','maxSTR','hgR','stR','hgL'};
% poshtoc_list_frq = [13 13 13 13 13];
%
% for tt = 1:length(posthoc_list_tim)
%     posthoc_tm(tt)      = find(round(tm_list,2)== posthoc_list_tim(tt));
%     posthoc_chn(tt)     = find(strcmp(template.label,poshtoc_list_chn{tt}));
%     posthoc_frq(tt)     = find(round(frq_list)== poshtoc_list_frq(tt));
% end
%
% posthoc_twin    = [0.2 0.2 0.2 0.2 0.1];
%
% for ph = 1:length(posthoc_chn)
%
%     figure ;
%
%     subplot(2,3,1:3)
%
%     lim_y1 = -0.6 ; lim_y2 = 0.6 ;
%
%     rectangle('Position',[tm_list(posthoc_tm(ph)) lim_y1 posthoc_twin(ph) abs(lim_y1)+abs(lim_y2)],'FaceColor',[0.7 0.7 0.7]);
%
%     hold on
%
%     d2plot = squeeze(mean(anovaData(:,:,posthoc_chn(ph),posthoc_frq(ph),:),1));
%
%     plot(tm_list,d2plot');
%
%     xlim([-0.2 2]); ylim([lim_y1 lim_y2]);
%
%     legend({'RCue','LCue','NCue'});
%
%     title([template.label{posthoc_chn(ph)} ' ' num2str(frq_list(posthoc_frq(ph))) 'Hz']);
%
%     c_idx = [1 2;1 3; 2 3];
%     cnd_i = 'RLN';
%
%     for bo = 1:3
%
%         subplot(2,3,3+bo);
%
%         X = squeeze(mean(anovaData(:,c_idx(bo,1),posthoc_chn(ph),posthoc_frq(ph),posthoc_tm(ph):find(round(tm_list,2)== round(posthoc_list_tim(ph)+posthoc_twin(ph),2))),5));
%         Y = squeeze(mean(anovaData(:,c_idx(bo,2),posthoc_chn(ph),posthoc_frq(ph),posthoc_tm(ph):find(round(tm_list,2)== round(posthoc_list_tim(ph)+posthoc_twin(ph),2))),5));
%
%         boxplot([X Y],'labels',{cnd_i(c_idx(bo,1)),cnd_i(c_idx(bo,2))})
%         ylim([-0.6 0.6]);
%
%         [h,p] = ttest(X,Y,'Alpha',0.05);
%
%         title(['p = ' num2str(round(p,4))]);
%
%     end
%
% end
%
%
% clearvars -except source_avg frq_list tm_list anova* t_list template ; clc ;
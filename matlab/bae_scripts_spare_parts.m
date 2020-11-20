
plimit  = 0.1;
zlim    = 70;
lm_t1   = -0.1;
lm_t2   =2;

% for ngroup = 1:2    
%     for ntest = 1:size(stat,2)
%         
%         i = i + 1;
%         
%         subplot(2,size(stat,2),i)
%         hold on
%         
%         tt_build = [lst_group{ngroup} ' p ='];
%         
%         if isfield(stat{ngroup,ntest},'negclusters')
%             
%             for nclust = 1:length(stat{ngroup,ntest}.negclusters)
%                 if stat{ngroup,ntest}.negclusters(nclust).prob < plimit
%                     
%                     iwhere = find(stat{ngroup,ntest}.negclusterslabelmat==nclust);
%                     
%                     x = stat{ngroup,ntest}.time(iwhere(1));
%                     z = stat{ngroup,ntest}.time(iwhere(end))-stat{ngroup,ntest}.time(iwhere(1));
%                     
%                     rectangle('Position',[x,0,z,zlim],'FaceColor',[0.8 0.8 0.8])
%                     
%                     tt_build = [tt_build ' -' num2str(stat{ngroup,ntest}.negclusters(nclust).prob)];
%                     
%                     clear x z
%                     
%                 end
%             end
%             
%         end
%         
%         if isfield(stat{ngroup,ntest},'posclusters')
%             
%             
%             for nclust = 1:length(stat{ngroup,ntest}.posclusters)
%                 if stat{ngroup,ntest}.posclusters(nclust).prob < plimit
%                     
%                     iwhere = find(stat{ngroup,ntest}.posclusterslabelmat==nclust);
%                     
%                     x = stat{ngroup,ntest}.time(iwhere(1));
%                     z = stat{ngroup,ntest}.time(iwhere(end))-stat{ngroup,ntest}.time(iwhere(1));
%                     
%                     rectangle('Position',[x,0,z,zlim],'FaceColor',[0.8 0.8 0.8])
%                     
%                     tt_build = [tt_build ' ' num2str(stat{ngroup,ntest}.posclusters(nclust).prob)];
%                     
%                     
%                     clear x z
%                     
%                 end
%             end
%             
%         end
%         
%         for cnd = 1:2
%             plot(gavg_data{ngroup,cnd}.time,gavg_data{ngroup,cnd}.avg,'LineWidth',2)
%             xlim([lm_t1 lm_t2])
%             ylim([0 zlim])
%         end
%         
%         legend({cond_sub{ix_test(ntest,1)},cond_sub{ix_test(ntest,2)}})
%         title(tt_build);
%         
%     end
% end

% i = 0 ;
% for ngroup = 1:2
%     for ntest = 1:size(stat,2)
%
%         i = i + 1;
%
%         subplot(2,size(stat,2),i)
%
%         stat{ngroup,ntest}.mask = stat{ngroup,ntest}.prob < plimit;
%         plot(stat{ngroup,ntest}.time,stat{ngroup,ntest}.stat .* stat{ngroup,ntest}.mask,'LineWidth',2)
%         ylim([-4 4]);
%
%     end
% end
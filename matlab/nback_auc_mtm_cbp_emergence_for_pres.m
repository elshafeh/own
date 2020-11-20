clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

load('/project/3015039.05/temp/nback/data/stat/mtm_decode_stat_with_all_chan.mat');

plimit                                          = 0.05;

% summarize
for ns = 1:length(stat)
    
    [min_p(ns),p_val{ns}]                       = h_pValSort(stat{ns});
    stat{ns}.mask                               = stat{ns}.prob < plimit;
    
    stat{ns}                                    = rmfield(stat{ns},'negdistribution');
    stat{ns}                                    = rmfield(stat{ns},'posdistribution');
    
    statplot{ns}                                = h_plotStat(stat{ns},10e-13,plimit,'stat');
    list_unique                                 = h_grouplabel(statplot{ns},'no');
    
    statplot{ns}                                = h_transform_freq(statplot{ns},list_unique(:,2),list_unique(:,1));
    
end

chan_list                                       = statplot{1}.label;
time_list                                       = statplot{1}.time;
freq_list                                       = statplot{1}.freq;

for nc = 1:length(chan_list)
    
    for ns = 1:length(statplot)
        
        avg_over_time(ns,:)                     = nanmean(squeeze(statplot{ns}.powspctrm(nc,:,:)),2);
        avg_over_freq(ns,:)                     = nanmean(squeeze(statplot{ns}.powspctrm(nc,:,:)),1);
        
        avg_over_time(isnan(avg_over_time))     = 0;
        avg_over_freq(isnan(avg_over_freq))     = 0;
        
    end
    
    chk                                         = length(unique(avg_over_time));
    
    if chk>1
        
        nrow=2;
        ncol=4;
        
        figure;
        
        for ns = 1:length(statplot)
            subplot(nrow,ncol,4+ns);
            cfg                                 = [];
            cfg.colormap                        = brewermap(256, '*RdBu');
            cfg.channel                         = nc;
            cfg.parameter                       = 'powspctrm';
            cfg.zlim                            = [-1 1];
            cfg.xlim                            = [0 5.5];
            cfg.colorbar                        = 'no';
            nme                                 = statplot{ns}.label{nc};
            ft_singleplotTFR(cfg,statplot{ns});
            title([nme ' ' list_condition{ns}]);
        end
        
        list_color                              = 'bgm';
        
        subplot(nrow,ncol,3);
        hold on;
        for ns = 1:length(statplot)
            plot(freq_list,avg_over_time(ns,:),['-' list_color(ns)],'LineWidth',2);
            xlabel('freq (hz)');
            ylabel('t value');
            xlim(freq_list([1 end]));
        end
        legend(list_condition);
        
        subplot(nrow,ncol,8);
        hold on;
        for ns = 1:length(statplot)
            plot(time_list,avg_over_freq(ns,:),['-' list_color(ns)],'LineWidth',2);
            xlabel('time (s)');
            ylabel('t value');
            xlim(time_list([1 end]));
        end
        legend(list_condition);
        
        % save figure in full screen
        set(gcf, 'Position', get(0, 'Screensize'));
        saveas(gcf,['../figures/nback/mtm_summary/' nme '.png']);
        close all;
        
    end
end

% plot TF
% for ns = 1:length(statplot)
%     
%     figure;
%     i                                           = 0;
%     
%     for nc = 1:length(statplot{ns}.label)
%         
%         tmp                                     = statplot{ns}.powspctrm(nc,:,:);
%         ix                                      = unique(tmp);
%         ix                                      = ix(ix~=0);
%         ix                                      = ix(~isnan(ix));
%         
%         if ~isempty(ix)
%             
%             i                                   = i + 1;
%             
%             cfg                                 = [];
%             cfg.colormap                        = brewermap(256, '*RdBu');
%             cfg.channel                         = nc;
%             cfg.parameter                       = 'powspctrm';
%             cfg.zlim                            = [-1 1];
%             cfg.xlim                            = [0 5.5];
%             
%             nme                                 = statplot{ns}.label{nc};
%             
%             nrow                                = 3;
%             ncol                                = 3;
%             
%             subplot(nrow,ncol,i)
%             ft_singleplotTFR(cfg,statplot{ns});
%             title([nme ' ' list_condition{ns}]);
%             
%             
%         end
%     end
%     
%     fprintf('%2d\n',i);
%     
% end
% 
% figure;
% i                                   = 0;
% for ns = 1:length(stat)
%     
%     tmp                          	= statplot{ns}.powspctrm(:,:,:);
%     
%     list_time                       = [0.5 1; 2.5 3; 4.5 5;5 5.5];%[0 1; 1 2; 2 3; 3 4; 4 5; 5 6];
%     
%     i = i +1;
%     subplot(3,2,i);
%     hold on;
%     
%     for nt = 1:size(list_time,1)
%         
%         ix1             = find(round(statplot{ns}.time,2) == round(list_time(nt,1),2));
%         ix2             = find(round(statplot{ns}.time,2) == round(list_time(nt,2),2));
%         
%         avg_over_time   = nanmean(nanmean(tmp(:,:,ix1:ix2),1),3);
%         
%         plot(statplot{ns}.freq,avg_over_time,'LineWidth',2);
%         
%         mx_find         = stat{ns}.freq(find(avg_over_time == max(avg_over_time)));
%         mx_val          = max(avg_over_time);
%         
%         title([list_condition{ns}]);
%         xlim(stat{ns}.freq([1 end]));
%         
%     end
%     
%     %     legend({'0-1','1-2','2-3','3-4','4-5','5-6'});
%     
%     avg_over_freq = nanmean(nanmean(tmp,1),2);
%     i = i +1;
%     subplot(3,2,i);
%     plot(stat{ns}.time,squeeze(avg_over_freq),'-k','LineWidth',2);
%     title([list_condition{ns}]);
%     xlim(stat{ns}.time([1 end]));
%     
%     
% end
% 
% figure;
% 
% list_time	= [0 2; 2 4; 4 6];
% 
% i           = 0;
% ncol        = size(list_time,1) * 2;
% nrow        = 3;
% 
% for ns = 1:length(stat)
%     
%     
%     for nt = 1:size(list_time,1)
%         
%         list_name                                   = [num2str(round(list_time(nt,1),2)) '-' num2str(round(list_time(nt,2),2)) 's'];
%         
%         ix1                                         = find(round(statplot{ns}.time,2) == round(list_time(nt,1),2));
%         ix2                                         = find(round(statplot{ns}.time,2) == round(list_time(nt,2),2));
%         
%         avg_over_time                               = nanmean(statplot{ns}.powspctrm(:,:,ix1:ix2),3);
%         avg_over_time(isnan(avg_over_time))         = 0;
%         
%         peak_group_index{1}                         = [];
%         peak_group_index{2}                         = [];
%         
%         for nc = 1:size(avg_over_time,1)
%             
%             vctr                                    = avg_over_time(nc,:);
%             
%             if length(unique(vctr)) > 1
%                 find_mx                          	= statplot{ns}.freq(find(vctr==max(vctr)));
%                 if find_mx < 15
%                     peak_group_index{1}             = [peak_group_index{1}; nc];
%                 else
%                     peak_group_index{2}             = [peak_group_index{2}; nc];
%                 end
%             end
%             
%         end
%         
%         list_diva = {'a peak',' b peak'};
%         list_z      = [0.5 0.5 0.5];
%         
%         for ndiva = 1:2
%             i = i +1;
%             subplot(nrow,ncol,i)
%             hold on;
%             for nc = 1:length(peak_group_index{ndiva})
%                 plot(statplot{ns}.freq,avg_over_time(peak_group_index{ndiva}(nc),:),'LineWidth',2);
%                 ylim([0 list_z(ns)]);
%             end
%             
%             legend(statplot{ns}.label(peak_group_index{ndiva}));
%             title([list_condition{ns} ' ' list_name ' ' list_diva{ndiva}]);
%             
%         end
%     end
% end
% 
% % figure;
% % i                                                   = 0;
% %
% % for ns = 1:length(stat)
% %
% %     list_time                                       = [0.5 5.5];
% %
% %     for nt = 1:size(list_time,1)
% %
% %         i = i +1;
% %         subplot(3,size(list_time,1),i);
% %         hold on;
% %
% %         list_name                                   = [num2str(round(list_time(nt,1),2)) '-' num2str(round(list_time(nt,2),2)) 's'];
% %
% %         plot_indx                                   = [];
% %
% %         ix1                                         = find(round(statplot{ns}.time,2) == round(list_time(nt,1),2));
% %         ix2                                         = find(round(statplot{ns}.time,2) == round(list_time(nt,2),2));
% %
% %         for nc = 1:length(statplot{ns}.label)
% %
% %             avg_over_time                           = nanmean(nanmean(statplot{ns}.powspctrm(nc,:,ix1:ix2),1),3);
% %             avg_over_time(isnan(avg_over_time))     = 0;
% %
% %             if length(unique(avg_over_time)) > 1
% %                 plot(stat{ns}.freq,avg_over_time,'LineWidth',2);
% %                 title([list_condition{ns} ' ' list_name]);
% %                 xlim(statplot{ns}.freq([1 end]));
% %                 plot_indx                           = [plot_indx;nc];
% %             end
% %
% %         end
% %
% %         legend(statplot{ns}.label);
% %
% %     end
% % end
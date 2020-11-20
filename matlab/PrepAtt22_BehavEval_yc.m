clear ; clc ; close all;

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

for ngroup = 1:2
    
    suj_list = suj_group{ngroup};
    
    behav_summary   = [];
    group_evnt      = [];
    
    for sb = 1:length(suj_list)
        
        suj                 = suj_list{sb};
        ngrp                = 1;
        
        sub_event           = [];
        
        load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
        
        for nbloc = 1:size(final_ds_list,1)
            
            fprintf('Handling %s\n',[suj ' b' num2str(nbloc)])
            
            pos_single                      = load(['../data/' suj '/pos/' final_ds_list{nbloc,1} '.code.pos']);
            pos_single                      = PrepAtt22_funk_pos_prepare(pos_single,sb,nbloc,ngrp);
            pos_single                      = PrepAtt22_funk_pos_recode(pos_single);
            [~,behav_single,~,all_evnts]    = PrepAtt22_funk_pos_summary(pos_single);
            
            trl_flg                         = find(behav_single(:,10)==1);
            all_evnts                       = all_evnts(trl_flg);
            all_evnts                       = [all_evnts{:}];
            
            sub_event                       = [sub_event; all_evnts(all_evnts~=0)'];
            
            behav_summary                   = [behav_summary;behav_single];
            
            clear behav_single pos_single
            
        end
        
        group_evnt      = [group_evnt;sub_event];
        
    end
    
    clearvars -except lst_group ngroup suj_group group_evnt; clc ;
    
    %     behav_table                   = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS' ...
    %         ;'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON' ; ...
    %         'disON';'tarON';'CLASS';'idx_group'; 'CD'});
    %     new_table                      = [];
    %     for sb = unique(behav_table.sub_idx)'
    %
    %         suj_table                               = behav_table(behav_table.sub_idx ==sb,:);
    %         before_tukey                            = [table2array(suj_table(suj_table.CORR==1,11)) find((suj_table.CORR==1))];
    %         new_data                                = PrepAtt22_calc_tukey(before_tukey(:,1));
    %
    %         suj_table.CORR(before_tukey(:,2))       = new_data(:,2);
    %         new_table                               = [new_table;suj_table];
    %
    %     end
    %     behav_table_with_Tukey = new_table(new_table.CORR ~= 2,:);
    %
    %     figure;new_funk_evalPlot(behav_summary);
    %     figure;new_funk_evalPlot(table2array(behav_table_with_Tukey));
    
    
    subplot(2,1,ngroup);
    histogram(group_evnt,'BinWidth',10);ylim([0 8]);
    title(num2str(length(group_evnt(group_evnt>-1000))));
    
end

% dist2plot{1}   = behav_table.CT;
% disOne2target  = behav_table(behav_table.DIS==1,:);
% dis2Twotarget  = behav_table(behav_table.DIS==2,:);
% dist2plot{2}   = disOne2target.DT;
% dist2plot{3}   = dis2Twotarget.DT;
%
% clear disOne2target dis2Twotarget
%
% hist_binwidth = 5;
%
% figure;
% for ndist = 1:3
%     subplot(3,1,ndist)
%     histogram(dist2plot{ndist},'BinWidth',hist_binwidth);
%     xlim([0 1300]);
%     vline(min(dist2plot{ndist}),'--k');
%     vline(max(dist2plot{ndist}),'--k');
%     title(['min = ' num2str(min(dist2plot{ndist})) ' max = ' num2str(max(dist2plot{ndist}))])
% end

% writetable(behav_table,'../documents/PrepAtt22_behav_table4R.csv','Delimiter',';')

% for ngroup = unique(behav_table.idx_group)'
%
%     group_table = behav_table(behav_table.idx_group==ngroup,:);
%
%     for sb = unique(group_table.sub_idx)'
%
%         for cue = 1:4
%
%             for dis = 1:3
%
%
%
%                 %                 if cue ==1
%                 %                     suj_table         = group_table(mod(group_table.TAR,2) ~=0 & group_table.sub_idx ==sb & group_table.CUE ==0 & group_table.DIS==dis-1 & group_table.CORR==1,11);
%                 %                 elseif cue == 2
%                 %                     suj_table         = group_table(mod(group_table.TAR,2) ==0 & group_table.sub_idx ==sb & group_table.CUE ==0 & group_table.DIS==dis-1 & group_table.CORR==1,11);
%                 %                 else
%                 %                     suj_table         = group_table(group_table.sub_idx ==sb & group_table.CUE ==cue-2 & group_table.DIS==dis-1 & group_table.CORR==1,11);
%                 %                 end
%
%                 new_data                            = PrepAtt22_calc_tukey(suj_table.RT);
%                 new_data                            = new_data(new_data(:,2) ==0,1);
%                 mtrx(1,ngroup,sb,cue,dis)           = median(suj_table.RT);
%                 mtrx(2,ngroup,sb,cue,dis)           = median(new_data);
%
%                 %                 for j = 2:size(mtrx,1)
%                 %                     mtrx(j,ngroup,sb,cue,dis) = (mtrx(j,ngroup,sb,cue,dis)/mtrx(1,ngroup,sb,cue,dis))*100;
%                 %                 end
%
%             end
%
%         end
%
%     end
%
% end
%
% clearvars -except behav_summary behav_table lst_group mtrx ; close all;
%
% lst_error = {'miss','false alarm','incorrect'};
% lst_cue   = {'NL','NR','L','R'};
% lst_dis   = {'D0','D1','D2'};
%
% i = 0;
%
% for err = 1:size(mtrx,1)
%
% %         figure ;
%
%     for xi = 1:4
%
%                 i = i + 1;
%
%         %         ncue            = squeeze(mtrx(err,xi,:,1,1));
%         %         lcue            = squeeze(mtrx(err,xi,:,2,1));
%         %         rcue            = squeeze(mtrx(err,xi,:,3,1));
%         %
%         %         data1           = ncue;
%         %         data2           = lcue;
%         %         data3           = rcue;
%         %
%         %         [h,p_1(xi,err)] = ttest(data1,data2);
%         %         [h,p_2(xi,err)] = ttest(data1,data3);
%         %         [h,p_3(xi,err)] = ttest(data2,data3);
%
%         subplot(2,4,i)
%
%         hold on
%
%         for cue = 1:4
%
%             data        = squeeze(mtrx(err,xi,:,cue,:));
%             avg         = squeeze(mean(data,1));
%             stndrd      = squeeze(std(data,1));
%             sem         = stndrd/sqrt(14);
%
%             errorbar(avg',sem','LineWidth',2)
%
%         end
%
%         title([lst_group{xi}])
%         legend(lst_cue,'Location', 'Northeast')
%
%         %         legend({'Ncue','LCue','Rcue'},'Location', 'Northeast')
%         %         legend({'Vcue','Ncue'});
%
%         set(gca,'Xtick',0:1:5)
%         xlim([0 4])
%         ylim([200 700])
%         set(gca,'Xtick',0:5,'XTickLabel', {'','NoDis','DIS1','DIS2',''})
%
%         clear data avg sem stndrd
%
%     end
%
% end
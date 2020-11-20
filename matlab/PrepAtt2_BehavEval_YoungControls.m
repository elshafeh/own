clear ; clc ; close all;

[~,suj_list,~]  = xlsread('../documents/New_PrepAtt22_Participant_Index_and_Preprocessing_Progress.xlsx','B:B');
suj_list         = suj_list(2:end);

behav_summary   = [];

for sb = 1:length(suj_list)
    
    if strcmp(suj_list{sb}(1:2),'yc');
        
        suj                 = suj_list{sb};
        
        load(['../data/' suj '/res/' suj '_final_ds_list.mat']);
        
        for nbloc = 1:size(final_ds_list,1)
            
            fprintf('Handling %s\n',[suj ' b' num2str(nbloc)])
            
            pos_single                = load(['../data/' suj '/pos/' final_ds_list{nbloc,1} '.code.pos']);
            pos_single                = PrepAtt22_funk_pos_prepare(pos_single,sb,nbloc,1);
            pos_single                = PrepAtt22_funk_pos_recode(pos_single);
            [~,behav_single,~]        = PrepAtt22_funk_pos_summary(pos_single);
            
            behav_summary             = [behav_summary;behav_single];
            
            clear behav_single pos_single
            
        end
    end
end

clearvars -except behav_summary lst_group ; clc ; close all ;

behav_table                   = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS' ...
    ;'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON' ; ...
    'disON';'tarON';'CLASS';'idx_group'});

for ngroup = unique(behav_table.idx_group)'
    
    group_table = behav_table(behav_table.idx_group==ngroup,:);
    
    for sb = unique(group_table.sub_idx)'
        
        fprintf('Applying Tukey Outlier Exclusion On %s\n',['g' num2str(ngroup) 'sub' num2str(sb)]);
        
        for cue = 1:2
            
            for dis = 1:3
                
                if cue == 1
                    before_tukey      = group_table(group_table.sub_idx ==sb & group_table.CUE ==0 & group_table.DIS==dis-1 & group_table.CORR==1,:);
                else
                    before_tukey      = group_table(group_table.sub_idx ==sb & group_table.CUE ~=0 & group_table.DIS==dis-1 & group_table.CORR==1,:);
                end
                
                new_data          = PrepAtt22_calc_tukey(before_tukey.RT);
                before_tukey.CORR = new_data(:,2);
                
                for j = 1:size(before_tukey,1)
                    
                    if cue == 1
                        ix = find(behav_table.idx_group==ngroup & behav_table.sub_idx ==sb & behav_table.CUE ==0 & behav_table.DIS==dis-1 & behav_table.nbloc==before_tukey.nbloc(j) ...
                            & behav_table.ntrl_blc == before_tukey.ntrl_blc(j));
                    else
                        ix = find(behav_table.idx_group==ngroup & behav_table.sub_idx ==sb & behav_table.CUE ~=0 & behav_table.DIS==dis-1 & behav_table.nbloc==before_tukey.nbloc(j) ...
                            & behav_table.ntrl_blc == before_tukey.ntrl_blc(j));
                    end
                        
                    if behav_table.RT(ix) == before_tukey.RT(j) && length(ix) ==1
                        behav_table.CORR(ix) = before_tukey.CORR(j);
                    else
                        error('something is wrong!')
                    end
                    
                    clear ix
                    
                end
                
                clear before_tukey new_data
                
            end
        end
    end
end

clearvars -except behav_table behav_summary ;

writetable(behav_table,'../documents/PrepAtt22_YoungParticipants_behav_table4R_with.VN.Tukey.csv','Delimiter',';')

% for ngroup = unique(behav_table.idx_group)'
%
%     group_table = behav_table(behav_table.idx_group==ngroup,:);
%
%     for sb = unique(group_table.sub_idx)'
%
%         fprintf('Applying Tukey Outlier Exclusion On %s\n',['g' num2str(ngroup) 'sub' num2str(sb)]);
%
%         for cue = 1:3
%
%             for dis = 1:3
%
%                 before_tukey      = group_table(group_table.sub_idx ==sb & group_table.CUE ==cue-1 & group_table.DIS==dis-1 & group_table.CORR==1,:);
%                 new_data          = PrepAtt22_calc_tukey(before_tukey.RT);
%                 before_tukey.CORR = new_data(:,2);
%
%                 for j = 1:size(before_tukey,1)
%
%                     ix = find(behav_table.idx_group==ngroup & behav_table.sub_idx ==sb & behav_table.CUE ==cue-1 & behav_table.DIS==dis-1 & behav_table.nbloc==before_tukey.nbloc(j) ...
%                         & behav_table.ntrl_blc == before_tukey.ntrl_blc(j));
%
%                     if behav_table.RT(ix) == before_tukey.RT(j) && length(ix) ==1
%                         behav_table.CORR(ix) = before_tukey.CORR(j);
%                     else
%                         error('something is wrong!')
%                     end
%
%                     clear ix
%
%                 end
%
%                 clear before_tukey new_data
%
%             end
%         end
%     end
% end
%
% clearvars -except behav_table behav_summary ;
%
% writetable(behav_table,'../documents/PrepAtt22_YoungParticipants_behav_table4R_with.NLR.Tukey.csv','Delimiter',';')
clear ; clc ;

[~,allsuj,~]    = xlsread('../documents/PrepAtt22_Matching4Matlab.xlsx','A:B');

suj_group{1}    = allsuj(2:15,1);
suj_group{2}    = allsuj(2:15,2);

i               = 0;

for ngroup = 1:length(suj_group)
    
    suj_list = suj_group{ngroup};
    
    list_grp = {'Old','Young'};
    
    for sb = 1:length(suj_list)
        
        i                                               = i + 1;
        suj                                             = suj_list{sb};
        
        fprintf('Handling %s\n',suj);
        
        [~,~,~,~,strial_rt_1]                           = h_behav_exclude(suj,0:2,0,1:4,2000); clc ;
        [~,~,~,~,strial_rt_2]                           = h_behav_eval(suj,0:2,0,1:4); clc ;

        allsuj_behav{i,1}                               = suj;
        allsuj_behav{i,2}                               = length(strial_rt_1);
        allsuj_behav{i,3}                               = length(strial_rt_2);
        allsuj_behav{i,4}                               = length(strial_rt_1) - length(strial_rt_2);
        
    end
end

clearvars -except allsuj_behav

% allsuj_behav{i,1}                               = suj;
% allsuj_behav{i,2}                               = round(min(strial_rt));
% allsuj_behav{i,3}                               = round(max(strial_rt));
%
% pos_orig    = load(['/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.fdis.pos']);
%
% Load Pos Files
% Creates a fourth column with Cue_Side
%
% lock                        = 1 ;
%
% pos_orig(:,4)               = floor(pos_orig(:,2)/1000);
% pos_orig(:,5)               = 0;
%
% excl_trial                  = 0;
%
% for ntrl = 1:length(pos_orig)
%
%     if pos_orig(ntrl,4) == 1 && pos_orig(ntrl,3) == 0
%
%         search_time = pos_orig(ntrl,1) - 600*3;
%         search_pos  = pos_orig(pos_orig(:,1) >= search_time & pos_orig(:,1) < pos_orig(ntrl,1),:);
%
%         if ~isempty(search_pos)
%             excl_trial = excl_trial + 1;
%         end
%     end
% end
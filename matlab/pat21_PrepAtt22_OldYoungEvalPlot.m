clear ; clc ;

suj_list    = dir('../R/new_pos/*pos');
pos_pre_recode_tot     = [];
pos_pst_recode_tot     = [];

for sb = 1:length(suj_list)
    
    nparts              = strsplit(suj_list(sb).name,'.');
    
    suj                 = nparts{1};
    
    fprintf('Processing %s\n',suj);
    
    pos_single          = load(['../R/new_pos/' suj_list(sb).name]);
    
    pos_single          = PrepAtt22_funk_prepare(pos_single,suj);
    
    pos_pre_recode_tot  = [pos_pre_recode_tot;pos_single] ;
    
    pos_single          = PrepAtt22_funk_behav_recode(pos_single);
    
    pos_pst_recode_tot  = [pos_pst_recode_tot;pos_single] ;
    
    clear pos_single
    
end

new_pos       = pos_pst_recode_tot(1,:);
nb_duplicate  = 0;
dup_list      = {};
h = waitbar(0,'Removing Duplicates ...');
for j = 2:size(pos_pst_recode_tot,1)
    waitbar(j/size(pos_pst_recode_tot,1))
    if pos_pst_recode_tot(j,4) ~= pos_pst_recode_tot(j-1,4)
        new_pos = [new_pos;pos_pst_recode_tot(j,:)];
    else
        nb_duplicate = nb_duplicate + 1;
        dup_list{nb_duplicate,1} = [pos_pst_recode_tot(j-1,:);pos_pst_recode_tot(j,:)];
        dup_list{nb_duplicate,2} = pos_pst_recode_tot(j,3);
    end
end
close(h);

[trl_tot,behav_summary]       = PrepAtt22_funk_behav_summary(new_pos);
behav_table                   = array2table(behav_summary,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS' ...
    ;'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON' ; ...
    'disON';'tarON';'CLASS';'idx_group';'ntrl'});

lst_group = {'yc','oc','fp','mg','uc'};

for ix = 1:5
    figure;
    slct_summary    = behav_summary(behav_summary(:,10) == 1 & behav_summary(:,end-1)==ix,:);
    PrepAtt2_funk_evalplot(slct_summary)
    title(lst_group{ix});
end

% no_trgt     = behav_table(behav_table.tarON==0,:);
% chk_no_trgttrl     = trl_tot(no_trgt.ntrl);
% 
% no_dis          = behav_table(behav_table.DIS~=0 & behav_table.disON==0,:);
% chk_no_distrl         = trl_tot(no_dis.ntrl);
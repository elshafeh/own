clear ; clc ; close all;

[~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
suj_list        = suj_list(2:end);

behav_summary = [];

for sb = 1:length(suj_list)
    
    suj                 = suj_list{sb};
    
    if strcmp(suj(1:2),'yc')
        
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

new_table = [];

suj_list = unique(behav_summary(:,1));

for sb = 1:length(suj_list)
    
    suj_table   = behav_summary(behav_summary(:,1) == suj_list(sb),:);
    
    blc_list    = unique(suj_table(:,2));
    
    
    for nb = 1:length(blc_list)
        
        bloc_table = suj_table(suj_table(:,2) == blc_list(nb),:);
        
        for nt = 2:length(bloc_table)
        
            bloc_table(nt,21) = bloc_table(nt-1,5);
            
        end
           
        new_table = [new_table;bloc_table]; clear bloc_table ;
        
    end
end

behav_table                   = array2table(new_table,'VariableNames',{'sub_idx' ;'nbloc'; 'ntrl_blc'; 'code'; 'CUE' ;'DIS' ...
    ;'TAR'; 'XP' ;'REP';'CORR' ;'RT' ;'ERROR' ;'cue_idx'; 'CT' ;'DT' ;'cueON' ; ...
    'disON';'tarON';'CLASS';'idx_group';'nMinusOne'});

clearvars -except behav_table ;


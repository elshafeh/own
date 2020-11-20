clear ; clc ;

cd('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/')

summary = readtable('../documents/PrepAtt22_PosFileTreatmentResults.csv','Delimiter',';');
summary = table2cell(summary);

%for j = 1:length(summary)
len = size(summary);
for j = 1:len(1);
    
    for i = 10:-1:8
        summary{j,i+1} = summary{j,i};
    end
    
    summary{j,8} = 0;
    summary{j,9} = 0;  
end


% [~,suj_list,~]  = xlsread('../documents/PrepAtt2_PreProcessingIndex.xlsx','B:B');
% suj_list        = suj_list(2:end);

suj_list = {'oc6','mg19'};


% suj_list = {'yc10'};

addpath('/mnt/autofs/Aurelie/DATA/MEG/PAT_EXPE22/scripts.m/');

for sb = 1:length(suj_list)
    
    suj             = suj_list{sb};
    
    fprintf('Handling %s\n',suj);
    
    posIn_before    = load(['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.pos']);
    posIn_after     = load(['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.pos']);
    posIn_final     = [];
    
    ntrial_orig     = length(posIn_before(posIn_before(:,2)==255));
    trial_index     = find(posIn_before(:,2)==255);
    
    for xi = 1:length(trial_index)
        
        if xi < length(trial_index)
            trl = posIn_after(trial_index(xi):trial_index(xi+1)-1,:);
        else
            trl = posIn_after(trial_index(xi):end,:);
        end
        
        flg = find(trl(:,3) ~= 0);
        
        if ~isempty(flg)
            trl(:,3) = 23;
        end
        
        posIn_final = [posIn_final; trl]; clear trl
        
    end
    
    posnameout                      = ['../data/' suj '/pos/' suj '.pat22.rec.behav.fdis.bad.epoch.rej.fin.pos'];
    dlmwrite(posnameout,posIn_final,'Delimiter','\t' ,'precision','%10d');
    
    ntrial_before   = length(posIn_before(floor(posIn_before(:,2)/1000)==1 & posIn_before(:,3) ==0,1));
    ntrial_after    = length(posIn_final(floor(posIn_final(:,2)/1000)==1 & posIn_final(:,3) ==0,1));
    
    idx             = find(strcmp(summary(:,1),suj));
    
    
    summary{idx,8}  = ntrial_after;
    summary{idx,9}  = (ntrial_after/summary{idx,2})*100;
    
    %     if summary{idx,7} == ntrial_before
    %     else
    %     error('Something is wrong !!');
    %     end
    
end

clearvars -except summary ;

summary_table                   = array2table(summary,'VariableNames',{'suj' ;'ntot'; 'nmiss'; 'nfa';'ninc'; 'ntte' ;'njump' ...
    ;'artefact';'premain'; 'medRT' ;'meanRT'});

% ix                              = find([summary{:,8}] > 0)';
% summary_table                   = summary_table(ix,:);

writetable(summary_table,'../documents/PrepAtt22_PosFilePostRejection.csv','Delimiter',';')
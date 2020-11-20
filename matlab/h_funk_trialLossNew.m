function summary_table = h_funk_trialLossNew(suj)

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

posIn_orig      = load(['../data/' suj '/pos/' suj '.pat22.rec.pos']);
ntrial_orig     = length(posIn_orig(floor(posIn_orig(:,2)/1000)==1 & posIn_orig(:,3) ==0,1));

summary{1,1}  = suj;
summary{1,2}  = ntrial_orig;
summary{1,3}  = ntrial_after;
summary{1,4}  = (ntrial_after/ntrial_orig)*100;

clearvars -except summary ;

summary_table                   = array2table(summary,'VariableNames',{'suj' ;'original';'artefact';'premain'});
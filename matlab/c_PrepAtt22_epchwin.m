%% c_PrepAtt22_epchwin

% nbsample_pre : number of samples in the pre-stimulus period of the new file.
% nbsample_post : number of samples in the post-stimulus period of the new file.

load('../documents/list_all_suj.mat');
load ../documents/event.mat;

data        = {'eeg','meg'};
event_names = fieldnames(event);

nbsample_pre = num2str(1200);
nbsample_post = num2str(1200);

for sb=2:length(list_all_suj)
    suj = list_all_suj{sb};
    
    for d = 1:length(data) %eeg ou meg
        
        cd(['../data/' suj '/erp/' data{d} '/' event_names{3}]);%cue
        event_list = getfield(event, event_names{3}); %toutes les catégories (ex. CnD CD1 CD2...)
        
        for cat = 1:length(event_list)
            
            epfileIN  = [suj '.pat22.' event_list{cat} '.lb.p'];
            epfileOUT = [suj '.pat22.' event_list{cat} '.lb.old.p'];
            
            ligne = ['mv ' epfileIN ' ' epfileOUT];
            system(ligne)
            
            ligne = ['epchwin ' epfileOUT ' ' epfileIN ' ' nbsample_pre ' ' nbsample_post];
            system(ligne)
            
        end
        
        cd ../../../../../scripts.m
    end
    
    
end
clear; clc;

suj_list         	= [1:33 35:36 38:44 46:51];
list_stim           = [2 3 4 5 7 8 9]; % [1:10];
datacount           = zeros(length(list_stim),1);

for nsuj = 1:length(suj_list)
    
    list_behav   	= {'fast' 'slow'};
    
    for nbehav = 1:2
        
        pow       	= [];
        
        for nstim = 1:length(list_stim)
            
            fname_in 	= ['~/Dropbox/project_me/data/nback/behav_timegen/sub' num2str(suj_list(nsuj)) '.' list_behav{nbehav} ...
                '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.auc.timegen.mat'];
            
            if exist(fname_in)
                datacount(nstim) = datacount(nstim)+1;
            end
            
        end
        
    end
    
end

keep datacount
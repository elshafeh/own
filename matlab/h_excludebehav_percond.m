function [new_data,new_mapping] = h_excludebehav_percond(data,mapping,low_lim,up_lim)

% exclude blocks with perforamnces (>60%) and (<95%)

tot_nb_blocks               = unique(data.nbloc);
goodtrials                  = [];

trial_array                 = [data.nbloc cell2mat([data.repCorrect]) data.task data.cue];

for nb = 1:length(tot_nb_blocks)
    
    chk_per_con           	= 0;
    
    for ntask = 1:2
        
        %block correct task cue
        
        index               = find(trial_array(:,1) == tot_nb_blocks(nb) & ...
            trial_array(:,3) == ntask);
        
        perf                = trial_array(index,2);
        perf                = sum(perf) ./length(perf);
        
        if perf < up_lim && perf > low_lim
            chk_per_con 	= chk_per_con+1;
        end
        
    end
    
    if chk_per_con  == 2
        goodtrials 	= [goodtrials; find(trial_array(:,1) == tot_nb_blocks(nb))];
    end
    
end

new_data         	= data(goodtrials,:);
new_mapping         = mapping(goodtrials,:);

perc_left           = round(length(goodtrials)./length(trial_array),2) * 100;

fprintf('\n%.2f perc of trials kept\n',perc_left)
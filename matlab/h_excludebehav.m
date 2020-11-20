function [new_data,new_mapping] = h_excludebehav(data,mapping,index_bloc,index_correct)

% exclude blocks with perforamnces < 60% and > 95 %

tot_nb_blocks       = table2array(unique(data(:,index_bloc)));
goodtrials          = [];

bloc_array          =  table2array(data(:,index_bloc));
corr_array          =  cell2mat(table2array(data(:,index_correct)));

for nb = 1:length(tot_nb_blocks)
  
    index           = find(bloc_array == tot_nb_blocks(nb));
    perf            = corr_array(index);
    perf            = sum(perf) ./length(perf);
    
    if perf <= 0.95 && perf >= 0.6
        goodtrials  = [goodtrials;index];
    end
    
end


new_data         	= data(goodtrials,:);
new_mapping         = mapping(goodtrials,:);

perc_left           = round(length(goodtrials)./length(corr_array),2) * 100;

fprintf('\n%.2f perc of trials kept\n',perc_left)
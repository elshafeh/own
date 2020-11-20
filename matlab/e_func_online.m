function [data] = e_func_online(log_table)

ix_corr                     = find(strcmp(log_table.code,'correct'));
ix_icor                     = find(strcmp(log_table.code,'incorrect'));

log_table.code(ix_corr)     = {'1'};
log_table.code(ix_icor)     = {'0'};

indx_all                    = find(strcmp(log_table.event_type,'Sound'));

trl.cue                     = str2double(log_table.code(indx_all(1:2:length(indx_all))))/64;
trl.perf                    = str2double(log_table.code(indx_all(2:2:length(indx_all))));

trl.perf(isnan(trl.perf))   = 0;
trl.sum                     = [trl.cue trl.perf];


list_cue                    = {'left','right'};
fprintf('\n');

for ncue = 1:2
    
    data                    = trl.sum(trl.sum(:,1) == ncue,2);
    corr                    = sum(data) ./ length(data);
    
    fprintf('perc correct for %5s is %.2f\n', list_cue{ncue},corr);
    
end




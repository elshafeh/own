clear ;

% in the [dir_zoom] you can put in the directory where the logfiles are
% something like D://data/Users/hesels/log ..
% otherwise the dialogue is open in the directory where the script is

dir_zoom            = '*.log';

[file,path]         = uigetfile(dir_zoom,'Select a file to analyze');
log_table           = struct2table(importPresentationLog([path file])); 

lm_start            = find(strcmp(log_table.code,'instruct'));
lm_end              = find(strcmp(log_table.code,'end'));

log_table           = log_table(lm_start+4:lm_end-1,:);
[data]              = e_func_online(log_table);

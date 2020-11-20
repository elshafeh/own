function [trl,data] = e_func_extract_behav_from_log(log_dir,bloc_order,bloc_length)

file_list           = dir(log_dir);
file_order          = [];

for nf = 1:length(file_list)
    
    
    fname           = [file_list(nf).folder '/' file_list(nf).name];
    
    % reads in file header to sort them by date of creation
    hdr             = readlogheader(fname);
    hdr             = strsplit(hdr{1},' ');
    hdr             = strsplit(hdr{5},':');
    
    file_order      = [file_order; nf bloc_order(nf) str2double(hdr{1})*1000+str2double(hdr{2})];
    
    clear hdr
    
    
end

file_order              = sortrows(file_order,3);

big_table               = [];

for nf  = 1:length(file_order)
    
    i                   = file_order(nf,1);
    fname               = [file_list(i).folder '/' file_list(i).name];
    log_table           = importlog_2(fname);
    
    % determine beginning
    lm_start            = find(strcmp(log_table.Code,'instruct'));
    lm_start            = lm_start+4;
    
    log_table           = log_table(lm_start:end,:);
    
    % determine end
    vct                 = [log_table.Trial];
    lm_end              = find(isnan(vct));lm_end   = lm_end(1);
    
    log_table           = log_table(1:lm_end-1,:);
    
    big_table           = [big_table;log_table];
    
end

[trl,data]              = e_func_pres_to_trl(big_table,file_order(:,2),bloc_length);
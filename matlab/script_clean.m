clear;

file_list               = dir('*mat');

for nf = 1:length(file_list)
    
    fname_in            = file_list(nf).name;
    fname_out           = ['../data/' fname_in];
    
    movefile(fname_in,fname_out);
    
end

keep file_list

new_list               = dir('*mat');

% file_list               = dir('*m');
% 
% for nf = 1:length(file_list)
%     
%     fname_in            = file_list(nf).name;
%     
%     chk1                = strfind(fname_in,'(');
%     chk2                = strfind(fname_in,'copy');
%     
%     if ~isempty(chk1) || ~isempty(chk2)
%         
%         fname_out       = ['_bin/' fname_in];
%         movefile(fname_in,fname_out);
%         
%     end
%     
%     
% end
% 
% keep file_list
% 
% new_list               = dir('*m');
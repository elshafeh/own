clear;

file_list = dir('P:/3015039.05/data/sub*/tf/keeptrl/*_stimloc.mtm.minevoked.full.mat');

for nfile = 1:length(file_list)
    
    suj_name    = strsplit(file_list(nfile).name,'_');
    suj_name    = suj_name{1};
    
    fname_in    = ['P:/3015039.05/data/' suj_name '/preproc/' suj_name '_stimLock_ICAlean_finalrej.mat'];
    fname_out   = ['F:/eyes/' suj_name '_stimLock_ICAlean_finalrej.mat'];
    
    fprintf('moving %s\n',fname_in); tic;
    movefile(fname_in,fname_out); toc;
    
end


% file_list = dir('P:/3015039.05/data/sub*/preproc/sub*_cueLock_ICAlean_finalrej.mat');
% 
% for nfile = 1:length(file_list)
%    
%     fname_in    = [file_list(nfile).folder filesep file_list(nfile).name];
%     fname_out   = ['F:/eyes/' file_list(nfile).name];
%     
%     fprintf('moving %s\n',fname_in);
%     movefile(fname_in,fname_out);
%     
% end
% 
% file_list = dir('P:/3015039.05/data/sub*/eye_data/*edf');
% 
% for nfile = 1:length(file_list)
%    
%     fname_in    = [file_list(nfile).folder filesep file_list(nfile).name];
%     fname_out   = ['F:/eyes/' file_list(nfile).name];
%     
%     fprintf('moving %s\n',fname_in);
%     movefile(fname_in,fname_out);
%     
% end
clear ;

global ft_default
ft_default.spmversion = 'spm12';

suj_list                                        = [1:33 35:36 38:44 46:51];

for ns = 1:length(suj_list)
    
    subjectName                                 = ['sub' num2str(suj_list(ns))];clc;
    
    fname                                       = ['/Volumes/heshamshung/nback/peak/' subjectName '.delthetapeak.itcbased.mat'];
    fprintf('load %s\n\n',fname);
    load(fname);
    
    allpeaks(ns)                                = dt_peak; clear dt_peak;
    
end

keep allpeaks;
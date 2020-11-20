clear ; global ft_default
ft_default.spmversion = 'spm12';

suj_list                                                = [1:33 35:36 38:44 46:51];
peak_check                                              = [];

for nsuj = 1:length(suj_list)
    
    subjectName                                         = ['sub' num2str(suj_list(nsuj))];clc;
    
    fname                                               = ['../data/peak/' subjectName '.alphabetapeak.m1000m0ms.mat'];
    fprintf('loading %s\n\n',fname);
    load(fname);
    
    if ~isnan(bpeak)
        peak_check                                      = [peak_check; suj_list(nsuj) apeak bpeak];
    end
    
    keep peak_check ns suj_list
    
end

suj_list                                                = peak_check(:,1);

keep suj_list;

save suj_list_peak.mat
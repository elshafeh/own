function [good_list,bad_list] = find_nan_peak(suj_list,ext_name)

peak_check                                              = [];
bad_list                                                = [];

for nsuj = suj_list
    
    subjectName                                         = ['sub' num2str(nsuj)];clc;
    
    fname                                               = ['../data/peak/' subjectName '.' ext_name '.mat'];
    fprintf('loading %s\n\n',fname);
    load(fname);
    
    if ~isnan(bpeak)
        peak_check                                      = [peak_check; nsuj apeak bpeak];
    else
        bad_list                                        = [bad_list nsuj];
    end
    
end

good_list                                             	= peak_check(:,1);

save(['../data/list/suj.list.' ext_name '.mat'],'good_list','bad_list');
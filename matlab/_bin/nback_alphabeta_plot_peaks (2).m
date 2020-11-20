clear ; close all; global ft_default
ft_default.spmversion = 'spm12';

load suj_list_peak.mat

for nsuj = 1:length(suj_list)
    
    subjectname         = ['sub' num2str(suj_list(nsuj))];
    
    % load peak
    fname               = ['../../data/peak/' subjectname '.alphabetapeak.m1000m0ms.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    bn_width            = 2;
    dataplot(nsuj,1)    = apeak-bn_width;
    dataplot(nsuj,2)    = apeak+bn_width;
    
    bn_width            = 4;
    dataplot(nsuj,3)    = bpeak-bn_width;
    dataplot(nsuj,4)    = bpeak+bn_width;
    
end

keep dataplot

boxplot(dataplot);

% subplot(1,2,1);plot([dataplot' new_dataplot'],'LineWidth',2);xticks([]);yticks([]);subplot(1,2,2);plot([dataplot';new_dataplot'],'LineWidth',2);xticks([]);yticks([]);
clear ; clc;

if isunix
    project_dir                 = '/project/3015079.01/';
    start_dir                   = '/project/';
else
    project_dir                 = 'P:/3015079.01/';
    start_dir                   = 'P:/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName                 = suj_list{nsuj};
    fname                       = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.' ...
        'm1000m0ms.mat'];
    load(fname);
    
    alpha_peaks(nsuj,1)         = [apeak_orig];
    beta_peaks(nsuj,1)          = [bpeak_orig];
    
end

keep *_peaks

nan_subjects                    = find(isnan(beta_peaks));

beta_peaks(find(isnan(beta_peaks)))     = round(nanmean(beta_peaks));

mean_alpha                      = mean(alpha_peaks);
sem_alpha                       = std(alpha_peaks, [], 1) ./ sqrt(size(alpha_peaks,1));

mean_beta                      = mean(beta_peaks);
sem_beta                       = std(beta_peaks, [], 1) ./ sqrt(size(beta_peaks,1));
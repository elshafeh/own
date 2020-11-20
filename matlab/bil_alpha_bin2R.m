clear ; clc;

if isunix
    project_dir         = '/project/3015079.01/';
else
    project_dir         = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

list_windows_name       = {'preCue1','preTarget','preCue2','preProbe'};
list_cond               = {'all','pre','retro'};

nb_bin                  = '5';

summary_table           = [];
i                       = 0;

for nsuj = 1:length(suj_list)
    subjectName         = suj_list{nsuj};
    for nwin = 1:length(list_windows_name)
        for ncond = 1:length(list_cond)
            
            fname       = [project_dir 'data/' subjectName '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.' ...
                'm1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.' nb_bin 'Bins.1Hz.window.' ...
                list_windows_name{nwin} '.' list_cond{ncond} '.mat'];
            
            fprintf('loading %s\n',fname);
            load(fname);
            
            for nbin = 1:size(bin_summary.bins,2)
                i = i +1;
                summary_table(i).suj    = subjectName;
                summary_table(i).win    = list_windows_name{nwin};
                summary_table(i).cue    = list_cond{ncond};
                summary_table(i).bin    = ['b' num2str(nbin)];
                summary_table(i).rt     = bin_summary.med_rt(nbin);
                summary_table(i).corr 	= bin_summary.perc_corr(nbin);
            end
        end
    end
end

keep summary_table nb_bin

summary_table                           = struct2table(summary_table);
writetable(summary_table,['../doc/bil.alphabinning.' nb_bin 'bins.final.txt']);
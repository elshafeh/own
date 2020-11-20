clear ; close all;

if isunix
    project_dir = '/project/3015079.01/';
else
    project_dir = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

allsuj_list                                         = suj_list(randperm(length(suj_list))); clear suj_list;
list_n                                              = [5 10 15 20 25 33];
i                                                   = 0;

for big_n = 1:length(list_n)
    
    suj_list                                        = allsuj_list(1:list_n(big_n));
    
    for perc = 0.1:0.1:1
        
        for ns = 1:length(suj_list)
            
            subjectName                             = suj_list{ns};
            ext_name                              	= [num2str(perc) 'perc'];
            fname                                   = [project_dir 'data/' subjectName '/tf/' subjectName '.cuelock.alpha.5bin' ext_name '.mat'];
            fprintf('Loading %s\n',fname);
            load(fname);
            
            if perc < 1
                ext_name                         	= ['0' num2str(perc*100) ' %'];
            else
                ext_name                         	= [num2str(perc*100) ' %'];
            end
            
            for nbin = 1:size(bin_summary.bins,2)
                i = i +1;
                
                summary_table(i).suj                = [num2str(list_n(big_n)) subjectName];
                
                if list_n(big_n) < 10
                    summary_table(i).sample_size 	= ['n=0' num2str(list_n(big_n))];
                else
                    summary_table(i).sample_size  	= ['n=' num2str(list_n(big_n))];
                end
                
                summary_table(i).perc_trials      	= ext_name;
                summary_table(i).bin                = ['b' num2str(nbin)];
                summary_table(i).rt                 = bin_summary.med_rt(nbin);
                summary_table(i).corr               = bin_summary.perc_corr(nbin);
            end
            
        end
        
    end
end

keep summary_table

summary_table                                       = struct2table(summary_table);
writetable(summary_table,['../doc/bil.powercalcul.alphabinning.txt']);
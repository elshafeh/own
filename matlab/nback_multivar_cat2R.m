clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                            = [1:33 35:36 38:44 46:51];
allpeaks                            = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                = apeak; clear apeak;
    allpeaks(nsuj,2)                = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)  	= nanmean(allpeaks(:,2));

keep suj_list allpeaks

i                                   = 0;

for nsuj = 1:length(suj_list)
    
    list_band                           = {'alpha' 'beta'};
    list_nback                          = {'1back' '2back'};
    list_stim                         	= {'isfirst' 'istarget'};
    list_width                          = [1 2];
    
    for nstim = 1:length(list_stim)
        for nback = 1:length(list_nback)
            for nband = 1:length(list_band)
                
                list_freq               = round(allpeaks(nsuj,nband)-nband : allpeaks(nsuj,nband)+nband);
                pow                  	= [];
                
                for nfreq = 1:length(list_freq)
                    
                    file_list         	= dir(['J:/nback/sens_level_auc/cond/sub' num2str(suj_list(nsuj)) '.sess*.' list_nback{nback} '.' num2str(list_freq(nfreq)) 'Hz.' ... 
                        list_stim{nstim} '.bsl.dwn70.excl.auc.mat']);
                    
                    if isempty(file_list)
                        error('file not found!');
                    end
                    
                    for nf = 1:length(file_list)
                        fname         	= [file_list(nf).folder filesep file_list(nf).name];
                        fprintf('loading %s\n',fname);
                        load(fname);
                        pow           	= [pow;scores]; clear scores;
                    end
                end
                
                t1                      = find(round(time_axis,2) == round(0.4,2));
                t2                      = find(round(time_axis,2) == round(1,2));

                pow                     = nanmean(pow,1);
                pow                     = mean(pow(:,t1:t2));
                
                
                i                       = i+1;
                data_table(i).sub       = ['sub' num2str(suj_list(nsuj))];
                data_table(i).cond    	= list_nback{nback};
                data_table(i).band  	=  list_band{nband};
                data_table(i).stim  	= list_stim{nstim};
                data_table(i).auc       = pow; clear pow t1 t2
                
                fprintf('\n');
                
            end
        end
    end
end

keep data_table

writetable(struct2table(data_table),'D:/Dropbox/project_me/doc/nback/nback.auc.4anova.txt');
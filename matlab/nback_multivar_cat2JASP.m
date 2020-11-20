clear ; close all;
clc; global ft_default;
ft_default.spmversion = 'spm12';

suj_list                                = [1:33 35:36 38:44 46:51];
allpeaks                                = [];

for nsuj = 1:length(suj_list)
    load(['J:/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.mat']);
    allpeaks(nsuj,1)                    = apeak; clear apeak;
    allpeaks(nsuj,2)                    = bpeak; clear bpeak;
end

allpeaks(isnan(allpeaks(:,2)),2)        = nanmean(allpeaks(:,2));

keep suj_list allpeaks

for nsuj = 1:length(suj_list)
    
    list_band                           = {'alpha' 'beta'};
    list_nback                          = {'1back' '2back'};
    list_stim                         	= {'isfirst' 'istarget'};
    list_width                          = [1 2];
    
    i                                 	= 1;
    
    list_var{1}                         = 'sub';
    
    for nback = 1:length(list_nback)
        for nstim = 1:length(list_stim)
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
                
                pow                         = nanmean(pow,1);
                
                for ntime = 0:0.1:0.9
                    
                    t1                      = find(round(time_axis,2) == round(ntime,2));
                    t2                      = find(round(time_axis,2) == round(ntime+0.1,2));
                    
                    avg                     = mean(pow(:,t1:t2));
                    
                    data_array{nsuj,1}    	= ['sub' num2str(suj_list(nsuj))];
                    
                    i                       = i+1;
                    data_array{nsuj,i}    	= avg; clear avg t1 t2
                    list_var{i}             = [list_nback{nback}(1:2) '_' list_band{nband}(1:2) '_' list_stim{nstim}(3:4) '_' num2str(ntime)];
                    
                end
                
                fprintf('\n');
                
            end
        end
    end
end

keep list_var data_array

data_array                              = cell2table(data_array,'VariableNames',list_var);
writetable(data_array,'D:/Dropbox/project_me/doc/nback/nback.auc.4jasp.withtime.txt');
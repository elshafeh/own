clear;close all;clc;
file_list                                           = dir('../data/preproc/*.fixlock.fin.mat');
i                                                   = 0;

for nf = 1:length(file_list)
    
    subjectName                                     = strsplit(file_list(nf).name,'.');
    subjectName                                     = subjectName{1};
    
    figure;
    nrow                                            = 4;
    ncol                                            = 3;
    i                                               = 0;
    
    for ntarget = [0 1 2 3]
        for nfreq = [1 2 3]
            
            
            i                                       = i+1;
            subplot(nrow,ncol,i)
            hold on;
            
            for nratio  = [1 2 3]
                
                list_percent                        = [60 80 100];
                
                fname                               = ['../data/erf/' subjectName '.freq' num2str(nfreq) '.' num2str(ntarget) 'cycles.'];
                fname                               = [fname num2str(list_percent(nratio)) 'perc.mat'];
                fprintf('loading %s\n',fname);
                load(fname);
                
                chan_interest                       = find(~cellfun('isempty', strfind(avg_comb.label,'O')));
                
                ix1                                 = find(round(avg_comb.time,2) == -0.1);
                ix2                                 = find(round(avg_comb.time,2) == 0);
                
                bsl                                 = mean(avg_comb.avg(:,ix1:ix2),2);
                data                                = mean(avg_comb.avg(chan_interest,:),1) - mean(bsl(chan_interest,:),1);
                
                cfg.linecolor                       = 'kbr';
                
                plot(avg_comb.time,data,cfg.linecolor(nratio),'LineWidth',1);
                xlim([-0.1 5]);
                ylim([0 max(data)]);
                
                title([subjectName ' F' num2str(nfreq) ' ' num2str(ntarget) 'CYC']);
                
            end
            
            legend({'60%','80%','100%'});
            
        end
    end
end
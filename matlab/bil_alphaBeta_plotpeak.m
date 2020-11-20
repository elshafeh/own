clear;clc;

ext_name                                                = 'finalrej';
suj_list                                                = dir(['../data/sub*/preproc/*' ext_name '.mat']);
nb_suj                                                  = length(suj_list);

i                                                       = 0;

for ns = 1:length(suj_list)
    for nc = 1:2
        for nwin = 1:4
            
            list_cond                                   = {'pre','retro'};
            
            suj                                         = suj_list(ns).name(1:6);
            
            nb_bin                                      = 7;
            
            fname                                       = ['../data/' suj  '/tf/' suj '.firstcuelock.freqComb.alphaPeak.m600m0ms.max20chan.p0p200ms.' num2str(nb_bin) 'Bins.1Hz.window' num2str(nwin) '.' list_cond{nc} '.mat'];
            fprintf('loading %s\n',fname);
            load(fname);
            
            
            for nb = 1:nb_bin
                
                i                                       = i + 1;
                sum_table(i).suj                        = suj;
                sum_table(i).bin                        = ['B' num2str(nb)];
                sum_table(i).win                        = ['W' num2str(nwin)];
                sum_table(i).cue                        = list_cond{nc};
                
                sum_table(i).rt                         = bin_summary.med_rt(nb);
                sum_table(i).prc                        = bin_summary.perc_corr(nb);
                
                
            end
        end
    end
end

keep sum_table nb_suj list_cond nb_bin;

sum_table                                               = struct2table(sum_table);

ncol                                                    = 4;
nrow                                                    = 2;
i                                                       = 0;

% -- plot accuracy

for ntar = [6 5]
    
    for nwin = 1:4
        
        for nc = 1:2
            for nb = 1:nb_bin
                vct_to_plot(:,nb,nc)                    = table2array(sum_table(strcmp(sum_table.win,['W' num2str(nwin)]) & strcmp(sum_table.bin,['B' num2str(nb)]) & strcmp(sum_table.cue,list_cond{nc}),ntar));
            end
        end
        
        mean_to_plot                                    = squeeze(mean(vct_to_plot,1));
        sem_to_plot                                     = squeeze(std(vct_to_plot,[],1)/sqrt(nb_suj)); % calculate sem
        
        i                                               = i + 1;
        subplot(nrow,ncol,i)
        hold on
        
        for nc = 1:2
            
            x                                           = [1:nb_bin] + (nc-1)*0.2;
            y                                           = squeeze(mean_to_plot(:,nc));
            z                                           = squeeze(sem_to_plot(:,nc));
            
            errorbar(x,y,z,'LineWidth',2)
        end
        
        list_name                                       = {'b1','b2','b3','b4','b5','b6','b7','b8','b9','b9','b10','b11','b12'};
        list_name                                       = list_name(1:nb_bin);
        
        xticks(0:length(list_name)+1)
        xticklabels([{''} list_name {''}]);
        xlim([0 length(list_name)+1]);
        
        if ntar == 6
            ylim([0.7 1]);
        else
            ylim([0.7 1.2]);
        end
        
        list_window                                     = {'pre-cue1','pre-grat1','pre-cue2','pre-grat2'};
        
        legend(list_cond);
        title(list_window{nwin});
        
    end
end
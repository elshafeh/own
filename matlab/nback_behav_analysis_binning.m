clear;close all;

suj_list                                        = [1:33 35:36 38:44 46:51];

for ns = 1:length(suj_list)
    
    load(['D:/Dropbox/project_me/data/nback/behav_h/sub' num2str(suj_list(ns)) '.behav.mat']);
    
    data_behav                                  = [data_behav [1:length(data_behav)]'];
    index_trials                                = [];
    
    for nback = [4 5 6]
        % take in all trials
        data_sub                                = data_behav(data_behav(:,1) == nback,[9 7]);
        all_rt                                  = data_sub(data_sub(:,2)~=0,:);
        
        all_rt                               	= sortrows(all_rt,2);
        [indx_in]                               = calc_tukey(all_rt(:,2));
        all_rt                               	= all_rt(indx_in,:);
        
        nb_bin                                  = 2;
        bin_size                               	= floor(length(all_rt)/nb_bin);

        for nb = 1:nb_bin
            lm1                                 = 1+bin_size*(nb-1);
            lm2                              	= bin_size*nb;
            
            tmp                                 = all_rt(lm1:lm2,:);
            
            index_trials                        = [index_trials;repmat(nback,length(tmp),1) repmat(nb,length(tmp),1) tmp]; clear tmp lm1 lm2;
        end
    end
    
    save(['D:/Dropbox/project_me/data/nback/rt_bins/sub' num2str(suj_list(ns)) '.rt.' num2str(nb_bin) 'bins.mat'] ,'index_trials');
    
    keep suj_list ns
    
end

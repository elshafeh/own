clear;clc;

suj_list                        = [1:33 35:36 38:44 46:51];
allinfo                         = {};

for nsuj = 1:length(suj_list)
    
    sujname                     = ['sub' num2str(suj_list(nsuj))];
    
    dir_data                    = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                    = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    list_stim                   = [1 2 3 4 5 6 7 8 9];
    data                        = [];
    
    bad_trials                  = [];
    bad_stim                    = [];
    
    auc_high                    = [];
    auc_low                     = [];
    
    for nstim = 1:length(list_stim)
        
        dir_files               = '~/Dropbox/project_me/data/nback/';
        fname                   = [dir_files 'auc/' sujname '.decoding.stim' num2str(list_stim(nstim)) '.nodemean.leaveone.mat'];
        fprintf('\nloading %s\n',fname);
        load(fname,'y_array','yproba_array','time_axis');
        
        % transpose matrices
        y_array                 = y_array';
        yproba_array            = yproba_array';
        
        auc_all                 = h_calc_auc(y_array,yproba_array,1:size(y_array,1));
        
        t1                      = nearest(time_axis,0);
        t2                      = nearest(time_axis,0.5);
        
        auc_max                 = mean(auc_all(t1:t2));
        
        y_mean                  = mean(y_array,2);
        
        trials_with_stim     	= find(y_mean ~= 0);
        trial_with_no_stim      = find(y_mean == 0);
        
        for ntrial = 1:length(trials_with_stim)
            
            a                   = ntrial;
            b                   = length(trials_with_stim);
            
            disp([sujname ' Stim' num2str(list_stim(nstim)) ': trial ' num2str(a) ' / ' num2str(b)]);
            
            index_trials        = [trials_with_stim(ntrial);trial_with_no_stim];
            
            trial_auc         	= h_calc_auc(y_array,yproba_array,index_trials);
            trial_max           = mean(trial_auc(t1:t2));
            
            auc_diff(ntrial,1)  = trials_with_stim(ntrial);
            auc_diff(ntrial,2)  = auc_max - trial_max;
            
            clear tmp_diff tmp_auc
            
        end
        
        auc_sorted              = sortrows(auc_diff,2);
        mean_auc                = mean(auc_sorted(:,2));
        
        index_high              = auc_sorted(auc_sorted(:,2) < mean_auc,1);
        index_low               = auc_sorted(auc_sorted(:,2) > mean_auc,1);
        
        allinfo{nsuj,nstim,1}  	= trialinfo(index_high,:);
        allinfo{nsuj,nstim,2} 	= trialinfo(index_low,:);
        
        index_high           	= [index_high; trial_with_no_stim];
        index_low           	= [index_low; trial_with_no_stim];
        
        auc_high(nstim,:)       = h_calc_auc(y_array,yproba_array,index_high);
        auc_low(nstim,:)        = h_calc_auc(y_array,yproba_array,index_low);
        
        clear index_high index_low auc_sorted mean_auc auc_diff
        
    end
    
    avg                       	= [];
    avg.time                   	= time_axis;
    avg.label                 	= {'decoding stim'};
    avg.dimord                	= 'chan_time';
    
    avg.avg                   	= mean(auc_high,1);
    alldata{nsuj,1}             = avg;
    
    avg.avg                   	= mean(auc_low,1);
    alldata{nsuj,2}             = avg;
    
    keep alldata nsuj suj_list allinfo
    
end

%%

cfg                             = [];
ft_singleplotER([],ft_timelockgrandaverage([],alldata{:,1}), ...
    ft_timelockgrandaverage([],alldata{:,2}))

%%

clc;

for nstim = 1:9
    
    rt_compare                          = [];
    
    for nsuj = 1:size(alldata,1)
        for nboot = [1 2]
            
            rt_vector                   = [];
            
            focus                       = allinfo{nsuj,nstim,nboot};
            
            focus                       = focus(focus(:,2) == 2 & focus(:,5) ~= 0,5);
            %             focus                       = focus(focus(:,4) == 1 | focus(:,4) == 3,5);
            
            rt_vector                   = [rt_vector;focus];
            
            clear focus
            
            rt_compare(nsuj,nboot)      = mean(rt_vector)/1000; clear rt_vector
            
        end
    end
    
    x                               = rt_compare(:,1);
    y                               = rt_compare(:,2);
    [h,p,ci,stats]                  = ttest(x,y);
    
    subplot(3,3,nstim)
    boxplot(rt_compare);
    xticklabels({'high auc' 'low auc'});
    
    title(['t = ' num2str(stats.tstat) '; p = ' num2str(p)]);
        
    clear rt_compare x y
    
end

%%

% for nback = [5 6]
%     
%     for nsuj = 1:size(alldata,1)
%         
%         for nboot = [1 2]
%             
%             rt_vector               = [];
%             
%             for nstim = 1:9
%                 
%                 focus               = allinfo{nsuj,nstim,nboot};
%                 
%                 focus               = focus(focus(:,1) == nback & focus(:,2) == 2 & focus(:,5) ~= 0,:);
%                 focus               = focus(focus(:,4) == 1 | focus(:,4) == 3,5);
%                 
%                 rt_vector           = [rt_vector;focus];
%                 
%                 clear focus
%                 
%             end
%             
%             rt_compare(nsuj,nboot)  = median(rt_vector)/1000; clear rt_vector
%             
%         end
%     end
%     
%     x                               = rt_compare(:,1);
%     y                               = rt_compare(:,2);
%     [h,p,ci,stats]                  = ttest(x,y);
%     
%     subplot(1,2,nback-4);
%     boxplot(rt_compare);
%     xticklabels({'high auc' 'low auc'});
%     
%     title(['p = ' num2str(p)]);
%     
%     ylim([0.2 1]);
%     
% end
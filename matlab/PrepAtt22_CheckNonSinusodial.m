% load Concatenate all data into single variable

clear; clc ; dleiftrip_addpath ; close all ; 

list_cue    = {'NLCnD','NRCnD','LCnD','RCnD'};

for ncue = 1:length(list_cue)
    
    data_concat = [];
    
    for sub = 1:21
        
        suj         = ['yc' num2str(sub)];
        
        fname       = ['../data/new_rama_data/' suj '.' list_cue{ncue} '.NewRama.1t20Hz.m800p2000msCov.audR.mat'];
        fprintf('Loading %30s\n',fname);
        load(fname);
        
        if sub == 1
            
            data_concat = virtsens;
        else
            cfg = [];
            data_concat = ft_appenddata(cfg,data_concat,virtsens);
        end
        
    end
    
    % Calculate the Rise Time: Decay Time for Gratig & Baseline Periods
    
    stats_all       = []; % Variable to hold the output from the t-test
    p_all           = []; % Variable to hold the p-value from the t-test
    count           = 1; % For use within the loop
    figure; 
    
    for phase = 7:13
        
        % Use check_non_sinusoidal_rise_decay function for grating and baseline
        % periods
        
        [ratios_post_grating,time_to_decay_all,time_to_peak_all] = ...
            check_non_sinusoidal_rise_decay(data_concat,[0.2 1],phase);
        [ratios_pre_grating,time_to_decay_all,time_to_peak_all] = ...
            check_non_sinusoidal_rise_decay(data_concat,[-1 -0.2],phase);
        
        % Create two overalapping histograms and add to subplot
        
        subplot(2,4,count); 
        histogram(ratios_post_grating); 
        hold on;
        histogram(ratios_pre_grating);
        xlabel('Time to Peak:Decay'); ylabel('Count');
        legend({'Ratio Post-Cue' 'Ratio Pre-Cue'});
        
        % Do a t-test to check for difference between ratio values pre &
        % post-grating
        [h,p,ci,stats] = ttest(ratios_post_grating,ratios_pre_grating);
        title([num2str(phase)  'Hz ; p = ' num2str(p)]);
        
        % Add this to the varibles outside the loop for all phases
        stats_all{count} = stats;
        p_all(count) = p;
        count = count+1;
        
        disp(['Phase ' num2str(phase)]);
        
    end
end





% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to quantify the non-sinusoidal properties of oscillations.
% Data is concatenated and the rise-time versus decay time 
% of low frequency alpha oscillations is calculated. This ratio is 
% compared between baseline and interest periods.
%
% Originally Written by Robert Seymour, June 2017.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Concatenate all VE data into single variable
% Start loop for all subjects

[~,suj_list,~]                      = xlsread('../documents/PrepAtt22_PreProcessingIndex.xlsx','B:B');
suj_list                            = suj_list(2:22);
    
list_dis                            = {'fDIS','DIS'};

for ndis = 1:length(list_dis)
    for sb = 1:length(suj_list)
        
        suj                         = suj_list{sb};
        
        ext_virt                    = '.BroadAud5perc.50t110Hz.m200p400msCov.transformed.mat';
        
        dir_data                    = ['/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data/' suj '/field/'];
        
        fname_in                    = [dir_data suj '.' list_dis{ndis} ext_virt];
        
        fprintf('Loading %s\n',fname_in);
        
        load(fname_in)
        
        allsuj_data{sb,ndis}        = virtsens; clear virtsens ;
        
    end
    
    gavg_data{ndis}                 = ft_appenddata([],allsuj_data{:,ndis});
    
end

clearvars -except *_data

% Calculate the Rise Time: Decay Time for Gratig & Baseline Periods

for ndis = 1:length(gavg_data)
    
    cfg                             = [];
    cfg.avgoverchan                 = 'yes';
    data                            = ft_selectdata(cfg,gavg_data{ndis});
    
    icount                          = 0;
    
    for nphase  = 60:5:100
        
        icount                      = icount+1;
        [ratios_grating,~,~]        = check_non_sinusoidal_rise_decay(data,[0.1 0.3],nphase,5);
        ratio_all{ndis,icount}      = ratios_grating; clear ratios_grating;
        
    end
end

nplot = 0;

for nphase = 1:size(ratio_all,2)
    
    nplot           = nplot + 1;
    
    subplot(3,3,nplot)
    
    hold on;
    
    trl_array       = PrepAtt2_fun_create_rand_array(1:length(ratio_all{1,nphase}),length(ratio_all{2,nphase}));
    
    ratio_interest  = ratio_all{2,nphase};
    ratio_baseline  = ratio_all{1,nphase}(trl_array);
    
    y_limit         = 500;
    x_limit         = [0.7 1.5];
    
    histogram(ratio_interest); ylim([0 y_limit]); xlim(x_limit);
    histogram(ratio_baseline); ylim([0 y_limit]); xlim(x_limit);
    
    [h,p,ci,stats]  = ttest(ratio_interest,ratio_baseline);
    
    list_phase      = 60:5:100;
    list_chan       = {'left auditory cortex','right auditory cortex'};
    
    title([num2str(list_phase(nphase)) 'Hz  p= ' num2str(round(p,2))]);
    
end

% stats_all       = [];   % Variable to hold the output from the t-test
% p_all           = [];   % Variable to hold the p-value from the t-test
% count           = 1;    % For use within the loop
% figure;                 % Create figure
%
% % Start loop for phases 7-13Hz
%
% % for phase = 7:13
% %
% %     % Use check_non_sinusoidal_rise_decay function for grating and baseline
% %     % periods
% %
% %
% %     [ratios_pre_grating,time_to_decay_all,time_to_peak_all]     = check_non_sinusoidal_rise_decay(VE_V1_concat,[-1.5 -0.3],phase);
% %
% %     % Create two overalapping histograms and add to subplot
% %     subplot(2,4,count); histogram(ratios_post_grating); hold on;
% %
% %     histogram(ratios_pre_grating);
% %
% %     xlabel('Time to Peak:Decay'); ylabel('Count');
% %
% %     legend({'Ratio Pre-Grating' 'Ratio Post-Grating'});
% %
% %     % Do a t-test to check for difference between ratio values pre &
% %     % post-grating
% %
% %     [h,p,ci,stats] = ttest(ratios_post_grating,ratios_pre_grating);
% %
% %     title([num2str(phase)  'Hz ; p = ' num2str(p)]);
% %
% %     % Add this to the varibles outsode the loop for all phases
% %
% %     stats_all{count} = stats;
% %
% %     p_all(count) = p;
% %
% %     count = count+1;
% %
% %     disp(['Phase ' num2str(phase)]);
% %
% % end
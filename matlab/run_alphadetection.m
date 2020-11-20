%%% script project alpha decode
%% clear

clear all
close all
clc
set(0,'DefaultFigureVisible','off') % suppress figure output

%% set the path
cd /Users/luca/Postdoc/PAD/

%% run fft
% 
% clear
% for s = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26]%[4:14 16:18 20:26] % loop over subjects
%     for SOA = [17, 33, 50, 67, 83]
% 
%         % load MNE output of preprocessed, epoched data
%         load(sprintf('data/freq/data_s%d_%dms', s, SOA)) % trials X chans X time
% 
%         % run ft power analysis
%         soa= SOA/1000; %soa=0.083;
%         freq = pad_fft(EEGdata,timepoints,chnames,soa);
% 
%         % save output to disk
%         save(sprintf('data/freq/freq_s%d_%dms', s, SOA),'freq')
%         keep s SOA
%     end
% end
% 
% %% plot output
% 
% clear
% 
% for s = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26]%[4:14 16:18 20:26] % loop over subjects
%     for SOA = [17, 33, 50, 67, 83]
%         
%         % load fft output
%         load(sprintf('data/freq/freq_s%d_%dms', s, SOA),'freq')
%         
%         
%         % plot
%         cfg=[];
%         cfg.grad    = ['/Users/luca/Dropbox/PAD/shared_folder_luca_saskia/data/grad/grad_s' num2str(s) '.mat'];% subject-specific grad file
%         cfg.chansel = 'data/misc/chanselect.mat'; % channel selection from my neuroimage oxford project
%         pad_plot(cfg,freq)
%         
%         % save fig
%         print(gcf,'-dpng',sprintf('figures/freq/testrun_s%d_%dms', s, SOA))
%         keep s SOA
%     end
% end
% 
% %% alpha peak detect

clear
for s = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26]%[4:14 16:18 20:26]% subset of working subjects% [4:14 16:18 21:26]% all% [9 16 17 20 21]% not working% % loop over subjects
    for SOA = [17, 33, 50, 67, 83]
        
        % load fft output
        load(sprintf('data/freq/freq_s%d_%dms', s, SOA),'freq')
        
        % combine mag & planar: rescale & plot to check
        cfg=[];
        cfg.grad    = ['/Users/luca/Dropbox/PAD/shared_folder_luca_saskia/data/grad/grad_s' num2str(s) '.mat'];% subject-specific grad file
        cfg.chansel = 'data/misc/chanselect.mat'; % channel selection from my neuroimage oxford project
        freqcmb = pad_cmb(cfg,freq,s);
        
        % find subject's alpha peak on chansel
        cfg=[];
        cfg.chansel = 'data/misc/chanselect.mat'; % channel selection from my neuroimage oxford project
        alpha = pad_alpha_allch(cfg,freqcmb,s);
        %alpha = pad_alpha(cfg,freqcmb,s);
        % add to plot
        title(['alpha peak: ',num2str(alpha(1)),' Hz'])
        line([alpha(1) alpha(1)], get(gca, 'ylim'),'color','k','linestyle','--');
        % save fig
        print(gcf,'-dpng',sprintf('figures/freq/testrunalpha_s%d_%dms', s, SOA))
        
        % now save alpha peak power per trial
        save(sprintf('data/freq/allch_alpha_s%d_%dms', s, SOA),'alpha') %pad_alpha_allch
        %save(sprintf('data/freq/alpha_s%d_%dms', s, SOA),'alpha') %pad_alpha
        
        keep s SOA
    end
end

clear;clc;

suj_list                                    = [1:33 35:36 38:44 46:51];

for nsuj = 1:length(suj_list)
    
    fname_in                                = ['~/Dropbox/project_me/data/nback/peak/sub' num2str(suj_list(nsuj)) '.alphabeta.peak.package.0back.mat'];
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    allalphapeaks(nsuj,1)                   = apeak;
    allbetapeaks(nsuj,1)                    = bpeak;
    
    allchan{nsuj,1}                         = max_chan;
    
end

mean_beta_peak                              = round(nanmedian(allbetapeaks));
allbetapeaks(isnan(allbetapeaks))          	= mean_beta_peak;

keep suj_list all*

for nsuj = 1:length(suj_list)
    
    dir_data                                = '~/Dropbox/project_me/data/nback/singletrial/';
    fname_in                                = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.fft.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in)
    
    fname_in                                = [dir_data 'sub' num2str(suj_list(nsuj)) '.singletrial.trialinfo.mat'];
    
    fprintf('loading %s\n',fname_in);
    load(fname_in);
    
    ext_stim                                = 'target';
    
    ext_behav                               = 'accuracy'; % accuracy rt
    ext_correlation                         = 'Spearman';
    
    list_band                               = {'alpha' 'beta'};
    
    for nband = 1:length(list_band)
        
        test_band                           = list_band{nband};
        
        switch test_band
            case 'alpha'
                f_focus                     = allalphapeaks(nsuj);
                f_width                     = 1;
            case 'beta'
                f_focus                     = allbetapeaks(nsuj);
                f_width                     = 2;
        end
        
        f1                                  = nearest(freq_comb.freq,f_focus-f_width);
        f2                                  = nearest(freq_comb.freq,f_focus+f_width);
        pow                                 = nanmean(squeeze(freq_comb.powspctrm(:,:,f1:f2)),3);
        
        if strcmp(ext_stim,'target')
            if strcmp(ext_behav,'rt')
                flg_trials   	= find(trialinfo(:,2) == 2 & trialinfo(:,4) ~= 0 & rem(trialinfo(:,5),2) ~=0);
            elseif strcmp(ext_behav,'accuracy')
                flg_trials   	= find(trialinfo(:,2) == 2);
            end
        end
        
        % extract power
        pow                                 = pow(flg_trials,:);
        % normalize
        pow                                 = pow ./ nanmean(pow,1);
        
        
        if strcmp(ext_behav,'accuracy')
            
            behav                           = trialinfo(flg_trials,4);
            behav(behav == 1 | behav == 3)  = 1;
            behav(behav == 2 | behav == 4)  = 0;
            
        elseif strcmp(ext_behav,'rt')
            
            behav                           = trialinfo(flg_trials,5) / 1000;
            behav                           = behav ./ mean(behav);
            
        end
        
        find_chan                           = [];
        for nchan = 1:length(allchan{nsuj})
            find_chan                       = [find_chan; find(strcmp(freq_comb.label,allchan{nsuj}{nchan}))];
        end
        
        pow                                 = nanmean(pow(:,find_chan),2);
        [rho,p]                             = corr(pow,behav , 'type', ext_correlation);
        rho                                 = .5.*log((1+rho)./(1-rho));
        
        alldata(nsuj,nband)              	= rho; clear rho;
        
    end
end

keep alldata list_band ext_*

%%

i                    	= 0;

for nband = [1 2]
    
    x                   = alldata(:,nband);
    y                   = ones(length(x),1);
    
    [h,p,ci,stats]      = ttest(x);
    
    i                   = i + 1;
    subplot(2,2,i);
    hold on;
    scatter(y,x);
    plot(0.8:0.1:1.2,[0 0 0 0 0 ],'--r');
    
    ylim([-1 1]);
    %     yticks([-0.1 0 0.1]);
    
    xlim([0 2]);
    xticks(1);
    xticklabels({'r coefficients'});
    
    grid;
    
    title({[list_band{nband} ' with ' ext_behav ],[' t = ' num2str(round(stats.tstat,2)) ' p = ' num2str(round(p,2))]});
    set(gca,'FontSize',18,'FontName', 'Calibri','FontWeight','normal');
    
end
clear ; clc;

load ../data/bil_goodsubjectlist.27feb20.mat

list_chan               = [];

for nsuj = 1:length(suj_list)
    
    subjectName         = suj_list{nsuj};
    
    if isunix
        subject_folder  = ['/project/3015079.01/data/' subjectName];
    else
        subject_folder  = ['P:/3015079.01/data/' subjectName];
    end
    
    fname               = [subject_folder '/preproc/' subjectName '_firstCueLock_ICAlean_finalrej.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    cfg                	= [];
    cfg.latency       	= [-1 0];
    data_axial       	= ft_selectdata(cfg, dataPostICA_clean); clear dataPostICA_clean;
    data_planar         = h_ax2plan(data_axial);
    
    cfg             	= [] ;
    cfg.output        	= 'pow';
    cfg.method       	= 'mtmfft';
    cfg.keeptrials    	= 'no';
    cfg.foi         	= 1:1:50;
    cfg.taper        	= 'hanning';
    cfg.tapsmofrq   	= 0.1 *cfg.foi;
    freq_planar         = ft_freqanalysis(cfg,data_planar);
    
    cfg                 = [];
    cfg.method          = 'sum';
    freq_comb           = ft_combineplanar(cfg,freq_planar);
    freq_comb           = rmfield(freq_comb,'cfg');
    
    fname_out        	= ['J:/bil/fft/' subjectName '.m1p0sec.1t50Hz.fft.mat'];
    fprintf('saving %s\n',fname_out);
    save(fname_out,'freq_comb','-v7.3');
    
    %     fname_out        	= ['J:/bil/fft/' subjectName '.m1p0sec.1t50Hz.fft.mat'];
    %     fprintf('loading %s\n',fname_out);
    %     load(fname_out,'freq_comb');
    
    avg                 = [];
    avg.time            = freq_comb.freq;
    avg.avg             = freq_comb.powspctrm;
    avg.label           = freq_comb.label;
    avg.dimord          = 'chan_time';
    alldata{nsuj,1}     = avg; clear freq_comb;
    
    % -- load peak
    fname            	= [subject_folder '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    a_peaks(nsuj,1)	= apeak;
    
    fname               = [subject_folder '/tf/' subjectName '.firstcuelock.1overf.orig.alphabetaPeak.m1000m0ms.mat'];
    load(fname);
    b_peaks(nsuj,1) 	= [bpeak_orig]; clear bpeak* apeak*
    
    fname            	= [subject_folder '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_chan           = [list_chan;max_chan];
    
end

list_chan               = unique(list_chan);
b_peaks(find(isnan(b_peaks)))	= round(nanmean(b_peaks));
allpeaks                = [a_peaks b_peaks];

keep alldata allpeaks list_chan

%%

% - - select data for plottinh

for ns = 1:length(alldata)
    cfg                 = [];
    cfg.channel         = list_chan;
    cfg.avgoverchan 	= 'yes';
    data_nw{ns}       	= ft_selectdata(cfg,alldata{ns});
    mtrx_data(ns,:)   	= data_nw{ns}.avg; clc;
end

subplot(2,2,1)
hold on;

list_colors             = [0 0.4470 0.7410;0.6350 0.0780 0.1840];
list_colors             = [0 0.9 0.9;0 0.9 0.9];

% for npeak = 1:2
%     f1                  = round(mean(allpeaks(:,npeak)))-npeak;
%     rectangle('Position',[f1 0 npeak*2 7e-27 ],'FaceColor',list_colors(npeak,:),'EdgeColor',list_colors(npeak,:))
% end

mean_data               = nanmean(mtrx_data,1);
bounds                  = nanstd(mtrx_data, [], 1);
bounds_sem              = bounds ./ sqrt(size(mtrx_data,1));
time_axs                = data_nw{1}.time;
boundedline(time_axs, mean_data, bounds_sem,'-k','alpha'); % alpha makes bounds transparent
xlabel('Frequency (Hz)');

xlim([1 40]);
ylim([0 7e-27]);
yticks([0 7e-27]);

vline(round(mean(allpeaks(:,1))),'--k');
vline(round(mean(allpeaks(:,2))),'--k');

subplot(2,2,2)
hold on;

boxplot(allpeaks);
plot([1 2],allpeaks,'Color', [0.8 0.8 0.8]);
xticklabels({'Alpha Peak','Beta Peak'});
ylabel('Frequency (Hz)');

for npeak = 1:2
    subplot(2,2,2+npeak)
    
    f1                      = round(mean(allpeaks(:,npeak)))-npeak;
    f2                      = round(mean(allpeaks(:,npeak)))+npeak;
    
    avg_plot                = ft_timelockgrandaverage([],alldata{:});
    avg_plot.avg(:)       	= 0;
    
    cfg                     = [];
    cfg.layout              = 'CTF275.lay';
    cfg.ylim                = 'maxabs';
    cfg.marker              = 'off';
    cfg.comment             = 'no';
    cfg.colorbar            = 'no';
    cfg.colormap            = brewermap(256, '*RdBu');
    cfg.highlight           = 'on';
    cfg.highlightchannel    = list_chan;
    cfg.highlightsymbol     = 'x';
    cfg.highlightsize       = 10;
    cfg.xlim                = [f1 f2];
    cfg.ylim                = [-1 1];
    ft_topoplotTFR(cfg,avg_plot);
    
    title([num2str(f1) ' - ' num2str(f2) 'Hz']);
    
end


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
    
    for nbin = 1:5
        fname_out        	= ['I:/hesham/bil/tf/' subjectName '.cuelock.mtmconvolPOW.m2p7s.20msStep.1t100Hz.1HzStep.AvgTrials.preCue1alphasorted.bin' num2str(nbin) '.mat'];
        fprintf('loading %s\n',fname_out);
        load(fname_out);
        
        cfg                 = [];
        cfg.latency         = [-1 0];
        cfg.avgovertime     = 'yes';
        cfg.nanmean         = 'yes';
        tmp                 = ft_selectdata(cfg,freq_comb); clear freq_comb;
        
        avg =[]; avg.time = tmp.freq; avg.label = tmp.label;avg.dimord = 'chan_time';
        avg.avg = tmp.powspctrm;
        alldata{nsuj,nbin}  = avg; clear avg;
        
    end
    
    fname                   = [subject_folder '/erf/' subjectName '.gratinglock.demean.erfComb.max20chan.p0p200ms.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    list_chan               = [list_chan;max_chan];
    
end

keep list_chan alldata;

for ns = 1:size(alldata,1)
    for nb = 1:size(alldata,2)
        cfg                 = [];
        cfg.channel         = list_chan;
        cfg.avgoverchan 	= 'yes';
        data_nw{ns}       	= ft_selectdata(cfg,alldata{ns,nb});
        mtrx_data(ns,nb,:) 	= data_nw{ns}.avg; clc;
    end
end

keep list_chan alldata data_nw mtrx_data

mean_data               = squeeze(nanmean(mtrx_data,1));
bounds                  = squeeze(nanstd(mtrx_data, [], 1));
bounds_sem              = squeeze(bounds ./ sqrt(size(mtrx_data,1)));
time_axs                = alldata{1}.time;

list_color              = 'bckmr';

subplot(2,2,1)
hold on

for nb = 1:size(mean_data,1)
    boundedline(time_axs, mean_data(nb,:), bounds_sem(nb,:), ...
        ['-' list_color(nb)],'alpha'); % alpha makes bounds transparent
    xlim([1 40]);
end

subplot(2,2,3)
hold on

for nb = 1:size(mean_data,1)
    boundedline(time_axs, mean_data(nb,:), bounds_sem(nb,:), ...
        ['-' list_color(nb)],'alpha'); % alpha makes bounds transparent
    xlim([4 15]);
end

subplot(2,2,4)
hold on

for nb = 1:size(mean_data,1)
    boundedline(time_axs, mean_data(nb,:), bounds_sem(nb,:), ...
        ['-' list_color(nb)],'alpha'); % alpha makes bounds transparent
    xlim([14 40]);
end

legend({'' 'lowest bin' '' 'second lowest' '' 'median' '' 'second highest' '' 'highest bin'});
clear ; clc;

if isunix
    project_dir         = '/project/3015079.01/';
else
    project_dir         = 'P:/3015079.01/';
end

load ../data/bil_goodsubjectlist.27feb20.mat

for nsuj = 1:length(suj_list)
    
    subjectName         = suj_list{nsuj};
    
    if isunix
        subject_folder  = ['/project/3015079.01/data/' subjectName];
    else
        subject_folder  = ['P:/3015079.01/data/' subjectName];
    end
    
    fname              	= [subject_folder '/tf/' subjectName '.firstcuelock.5t20Hz.1HzStep.KeepTrials.comb.mat'];
    fprintf('\nloading %s\n',fname);
    load(fname);
    
    erf_ext_name      	= 'gratinglock.demean.erfComb.max20chan.p0p200ms';
    fname            	= [subject_folder '/erf/' subjectName '.' erf_ext_name '.postOnset.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    peak_window       	= [-1 0];

    % -- load peak
    fname            	= [subject_folder '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.m1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.mat'];
    fprintf('loading %s\n',fname);
    load(fname);
    
    cfg               	= [];
    cfg.channel       	= max_chan;
    cfg.frequency       = [apeak-1 apeak+1];
    cfg.avgoverchan     = 'yes';
    cfg.avgoverfreq     = 'yes';
    freq_peak         	= ft_selectdata(cfg,freq_comb);
    
    title_win           = 'preProbe'; % {'preCue1','preTarget','preCue2','preProbe'};
    
    fname               = [subject_folder  '/tf/' subjectName '.firstcuelock.freqComb.alphaPeak.' ...
        'm1000m0ms.gratinglock.demean.erfComb.max20chan.p0p200ms.5Bins.1Hz.window.' title_win '.all.mat'];
    
    fprintf('loading %s\n',fname);
    load(fname);
    
    for nbin = 1:size(bin_summary.bins,2)
        
        indx            = bin_summary.bins(:,nbin);
        
        avg             = [];
        avg.label       = {'occ chan'};
        avg.time        = freq_peak.time;
        avg.avg         = squeeze(freq_peak.powspctrm);
        avg.avg         = mean(avg.avg(indx,:),1);
        avg.dimord      = 'chan_time';
        
        alldata{nsuj,nbin}  = avg; clear avg;
        
    end
end

keep alldata title_win

for ns = 1:size(alldata,1)
    for nb = 1:size(alldata,2)
        mtrx_data(ns,nb,:)   	= alldata{ns,nb}.avg;
    end
end

keep alldata mtrx_data title_win

mean_data               = squeeze(nanmean(mtrx_data,1));
bounds                  = squeeze(nanstd(mtrx_data, [], 1));
bounds_sem              = squeeze(bounds ./ sqrt(size(mtrx_data,1)));
time_axs                = alldata{1}.time;

hold on

list_color              = 'bckmr';

for nb = 1:size(mean_data,1)
    boundedline(time_axs, mean_data(nb,:), bounds_sem(nb,:), ...
        ['-' list_color(nb)],'alpha'); % alpha makes bounds transparent
    xlim([-1 7]);
end

legend({'' 'lowest bin' '' 'second lowest' '' 'median' '' 'second highest' '' 'highest bin'});
title(title_win);